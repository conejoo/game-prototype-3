"""FS001 one-time explicit freeze. Refuses overwrites; never writes source/game.

Reviewed source selection and exact constants belong to FS001. Later tasks audit
these pins; they must not run this tool to silently accept source drift.
"""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path("D:/development/game-prototype-2")
DEST = ROOT / "tools/fishing/reference"


def write(name, value):
    (DEST / name).write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if DEST.exists():
        raise SystemExit("Reference directory exists; refusing repin/overwrite")
    DEST.mkdir()
    catalog = json.loads((SOURCE / "assets/data/gameplay/catalog.json").read_text())
    world = json.loads((SOURCE / "assets/maps/mvp_world.json").read_text())
    layout = json.loads((ROOT / "game/content/maps/alderwake_layout.json").read_text())
    ids = ["fishing_rod", "bluegill", "river_trout", "golden_carp"]
    rules = {
        "schema": 1, "items": [i for i in catalog["items"] if i["id"] in ids],
        "source_areas": world["activityAreas"], "areas": layout["activity_areas"],
        "transform": {"source_origin": [704,576], "units_per_metre":32, "target_origin":[-22,-18], "cell_m":.5, "range_m":12},
        "challenge": {"initial_tension":.5,"wait_min":1.5,"wait_max":3,"danger_grace":.75,"held_rise":.65,"release_fall":.55,"warning_progress":.25,"danger_progress":0,"optimal_progress":1,"priority":["danger","landed","exhausted"],
            "tiers":{"easy":{"optimal":[.3,.7],"danger":[.1,.9],"struggle":[[.12,2]]},"medium":{"optimal":[.35,.65],"danger":[.15,.85],"struggle":[[.22,1.35]]},"hard":{"optimal":[.4,.6],"danger":[.2,.8],"struggle":[[.22,1.9],[.10,.8]]}}},
        "boundaries":{"areas":"rectangle closed; polygon edges included using source-unit predicate epsilon 1e-6","map":"left/top included; right/bottom excluded","range":"cell-center horizontal <=12m","water_y":.015,"deck_physics_y":0,"deck_visual_y":.022},
        "rng":{"encounter":"finite uniform [0,1), sorted source IDs, one roll only when matching profiles exist","wait":"independent finite [0,1), 1.5+1.5*roll; source helper clamps but target rejects out-of-domain","no_area":"immediate, no challenge, no reward","miss":"normal waiting then no_bite"},
        "cancellation":{"explicit":["F","right_click","Cancel"],"esc":"cancel then existing pause","lifecycle":["focus_loss","pause_or_modal","room_or_session_replacement","retry_or_death","combat_engagement","rod_or_capability_invalidated"],"exit":"invalidate token, clear held controls, require fresh input; no reward; no saved attempt"},
    }
    write("rules.json", rules)
    membership=[]
    for a in rules["areas"]:
        if a["shape"]["kind"] == "rectangle":
            l,t,w,h=a["shape"]["rect_xz_m"]
            for name,p,inside in [("left-top",[l,t],True),("right-bottom",[l+w,t+h],True),("outside-left",[l-.0001,t],False),("outside-right",[l+w+.0001,t+h],False)]:
                membership.append({"label":a["id"]+"-"+name,"area":a["id"],"point":p,"inside":inside})
        else:
            v=a["shape"]["vertices_xz_m"]
            for i,(p,q) in enumerate(zip(v,v[1:]+v[:1])):
                for name,point in [("vertex",p),("edge",[(p[0]+q[0])/2,(p[1]+q[1])/2])]:
                    membership.append({"label":a["id"]+f"-{name}-{i}","area":a["id"],"point":point,"inside":True})
            membership.append({"label":a["id"]+"-outside","area":a["id"],"point":[-21,-17],"inside":False})
    distributions=[
        {"label":"dock","point":[-4.75,20.25],"probabilities":{"bluegill":.3,"river_trout":.1},"miss":.6},
        {"label":"channel","point":[10.25,17.25],"probabilities":{"bluegill":.12,"golden_carp":.03,"river_trout":.3},"miss":.55},
        {"label":"reeds-dock","point":[3.25,22.25],"probabilities":{"bluegill":(.3+.08*2)/3,"golden_carp":.4/3,"river_trout":(.1+.22*2)/3},"miss":1-(.4+1)/3},
        {"label":"reeds-channel","point":[6.25,22.25],"probabilities":{"bluegill":(.12+.08*2)/3,"golden_carp":(.03+.2*2)/3,"river_trout":(.3+.22*2)/3},"miss":1-(.45+1)/3},
        {"label":"no-area","point":[-12.75,20.25],"probabilities":{},"miss":1},
    ]
    # Reeds is contained in dock/channel union. Do not invent a solo reeds site.
    rolls=[]
    for d in distributions:
        threshold=0.0
        pairs=list(d["probabilities"].items())
        for index,(item,p) in enumerate(pairs):
            rolls.append({"label":d["label"]+"-"+item+"-start","point":d["point"],"roll":threshold,"expected":item})
            threshold+=p
            rolls.append({"label":d["label"]+"-"+item+"-before-end","point":d["point"],"roll":threshold-1e-10,"expected":item})
            rolls.append({"label":d["label"]+"-"+item+"-end","point":d["point"],"roll":threshold,"expected":pairs[index+1][0] if index+1<len(pairs) else "miss"})
        rolls.append({"label":d["label"]+"-high-roll","point":d["point"],"roll":.999999,"expected":"miss" if pairs else "no_area"})
    vectors={"membership":membership,"distributions":distributions,"rolls":rolls,"waits":[{"roll":0,"seconds":1.5},{"roll":.5,"seconds":2.25},{"roll":.999999,"seconds":2.9999985}],
        "sites":[{"id":"dock-shallows","foot":[-7,0,18],"target":[-4.75,.015,20.25],"areas":["fishing-dock-shallows"]},{"id":"lake-channel","foot":[10,0,13],"target":[10.25,.015,17.25],"areas":["fishing-lake-channel"]},{"id":"sunken-reeds-dock","foot":[3,0,13],"target":[3.25,.015,22.25],"areas":["fishing-dock-shallows","fishing-sunken-reeds"]},{"id":"sunken-reeds-channel","foot":[6,0,13],"target":[6.25,.015,22.25],"areas":["fishing-lake-channel","fishing-sunken-reeds"]}],
        "negative_points":[{"label":"dry-dock","point":[-7,18],"kind":"deck"},{"label":"dry-bridge","point":[98,-.5],"kind":"bridge"},{"label":"shoreline-dry","point":[10,13],"kind":"dry_land"},{"label":"out-of-map","point":[125,62],"kind":"out_of_map"},{"label":"no-area-water","point":[-12.75,20.25],"kind":"no_area"}]}
    write("behavior_vectors.json",vectors)
    selection={
        "assets/data/gameplay/catalog.json":None,"assets/maps/mvp_world.json":None,
        "lib/game/fishing/fishing_challenge.dart":[(78,335)],
        "lib/game/activities/activity_outcome_resolver.dart":[(37,104)],
        "lib/game/items/item_targeting.dart":[(64,185)],
        "lib/world_map/world_map.dart":[(623,734)],
        "lib/game/cozy_adventure_game.dart":[(641,811)],
        "lib/game/items/item_definition.dart":None,
        "lib/ui/fishing_hud_overlay.dart":None,
        "lib/game/input/desktop_input_adapter.dart":None,
        "test/game/fishing/fishing_challenge_test.dart":None,
        "test/game/activities/activity_outcome_resolver_test.dart":None,
        "test/game/items/item_targeting_test.dart":None,
        "test/ui/fishing_hud_overlay_test.dart":None,
        **{f"assets/images/items/{id}.png":None for id in ids},
    }
    source_records=[]
    excerpts=[]
    for path,ranges in selection.items():
        original=SOURCE/path
        source_records.append({"path":path,"bytes":original.stat().st_size,"sha256":sha(original)})
        if ranges:
            lines=original.read_text(encoding="utf-8").splitlines()
            for start,end in ranges:
                excerpts.append({"source":path,"lines":[start,end],"text":"\n".join(lines[start-1:end])+"\n"})
    write("source_excerpts.json",excerpts)
    baseline_paths=["game/content/maps/alderwake_layout.json","game/world/map_candidate/water_blockers.gd","game/world/map_candidate/dock_surfaces.gd","game/world/map_candidate/crossings.gd","game/world/map_candidate/elevation_surfaces.gd","game/world/map_candidate/river.gdshader"]
    local_artifacts=[{"path":p,"sha256":sha(ROOT/p)} for p in baseline_paths]+[{"path":str(p.relative_to(ROOT)).replace("\\","/"),"sha256":sha(p)} for p in sorted(DEST.glob("*.json"))]
    git=lambda root,*args:subprocess.check_output(["git","-c",f"safe.directory={root}","-C",str(root),*args],text=True).strip()
    write("manifest.json",{"schema":1,"task":"FS001","target_entry_head":git(ROOT,"rev-parse","HEAD"),"entry_dirty":"?? docs/fishing/ (user-authored instructions preserved)","source_head":git(SOURCE,"rev-parse","HEAD"),"source_status":git(SOURCE,"status","--short"),"source_files":source_records,"local_artifacts":local_artifacts,"historical_map_sha256":"af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f","reconciliation":"Live map differs; only fishing area transforms/profiles match. No geography regeneration.","runtime_dependency":False})
    print("FS001 frozen references created; audit before acceptance")


if __name__ == "__main__":
    main()
