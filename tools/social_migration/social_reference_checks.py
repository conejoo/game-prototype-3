"""Read-only G001 reference audit, not a runtime social acceptance suite.

Default mode validates immutable references and the recorded bounded baseline.
--check-g001-baseline additionally compares selected current files to the G001
audit. Do not use that historical comparison after authorized feature changes.
Nothing here refreshes pins, converts content, starts Godot or accesses saves.
"""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "tools/social_migration/reference"
NPC_REF = ROOT / "tools/npc_migration/reference"
REVISION = "60c20eb2816e7271fb84afaba286af006ebe3ccf"
ROSTER = ["npc-01", "npc-02", "npc-03", "npc-04", "npc-06", "npc-07", "npc-08", "npc-14"]
FACTS = ["moonflower-preference", "moonflower-pressing", "decorative-knots",
         "shore-birds", "pressed-flowers", "knotwork", "woodcarving", "quilting"]
SOURCE_PATHS = {
    "lib/game/dialogue/dialogue_choice_eligibility.dart", "lib/game/dialogue/dialogue_model.dart",
    "lib/game/dialogue/dialogue_repository.dart",
    "lib/game/state/runtime_game_controller.dart", "lib/game/state/runtime_game_state.dart",
    "lib/game/state/player_event_journal.dart", "lib/game/state/people_snapshot.dart",
    "lib/ui/people_journal_overlay.dart", "lib/ui/dialogue_overlay.dart",
    "lib/game/npc/npc_content.dart", "assets/data/gameplay/catalog.json",
    "test/game/dialogue/dialogue_choice_eligibility_test.dart",
    "test/game/state/runtime_game_controller_test.dart", "test/game/state/runtime_game_state_test.dart",
    "test/game/state/presentation_snapshots_test.dart", "test/game/state/player_event_journal_test.dart",
    "test/ui/people_journal_overlay_test.dart",
}


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def bounded_path(base, relative):
    path = (base / relative).resolve()
    require(path.is_relative_to(base.resolve()), "path outside reference: " + relative)
    return path


def packages():
    return [(read(NPC_REF / f"assets/data/npcs/{npc}/runtime.json"),
             read(NPC_REF / f"assets/data/npcs/{npc}/dialogue.json")) for npc in ROSTER]


def expected_policy():
    """Exact approved overlay, derived from public immutable packages only."""
    coverage = read(NPC_REF / "coverage.json")
    rules, choices, nodes, recipients = [], [], [], []
    for (runtime, graph), suffix in zip(packages(), FACTS):
        npc = runtime["id"]
        rule = runtime["acceptedGiftRules"][0]
        require(runtime["acceptedGiftRules"] == [{"id": npc + "-moonflower-gift",
                "itemId": "moonflower", "requiredFactId": npc + "-" + suffix,
                "affinityDelta": 1, "acceptanceCap": 2}], "eight exact gift rules")
        relationship = runtime["relationship"]
        require(relationship["levelOneAffinity"] == 3 and relationship["levelOneLabel"] == "Acquaintance", "threshold/label")
        require(("levelOneMilestone" in relationship) == (npc == "npc-01"), "Edric-only milestone")
        rules.append({"npc_id": npc, "id": rule["id"]})
        gift_choices = []
        targets = []
        for node in graph["nodes"]:
            for choice in node.get("choices", []):
                require(choice.get("affinityDelta", 0) >= 0, "selected pin signed-history assumption")
                if not choice.get("giftRuleId"):
                    continue
                require(choice["giftRuleId"] == rule["id"], "gift choice rule binding")
                require(not choice.get("oneTime", False) and not choice.get("oneTimeRewardFlag"), "repeatable gifts")
                require(choice.get("affinityDelta", 0) == 0 and not choice.get("addedFlags"), "current gift choice effects")
                require(not choice.get("conditions") and not choice.get("endsConversation", False), "current gift choice gates/transitions")
                choices.append({"npc_id": npc, "node_id": node["id"], "id": choice["id"]})
                gift_choices.append({"node_id": node["id"], "choice": choice})
                if choice["targetNodeId"] not in targets:
                    targets.append(choice["targetNodeId"])
        require(len(gift_choices) == (2 if npc in ROSTER[:2] else 1), "exact ten gift choices")
        if npc == "npc-01":
            require(relationship["levelOneMilestone"] == {
                "dialogueNodeId": "npc-01-level-1-milestone", "seenFlagId": "relationshipLevel1Seen"}, "milestone metadata")
            targets.append(relationship["levelOneMilestone"]["dialogueNodeId"])
        recipient_nodes = []
        for node_id in targets:
            node = next(n for n in graph["nodes"] if n["id"] == node_id)
            require(not node.get("choices") and not node.get("continueTargetId"), "all nine outgoing transitions terminal")
            incoming = [{"node_id": n["id"], "choice_id": c["id"]}
                        for n in graph["nodes"] for c in n.get("choices", []) if c.get("targetNodeId") == node_id]
            require(not any(n.get("continueTargetId") == node_id for n in graph["nodes"]), "no hidden continue incoming edge")
            recipient_nodes.append({"node": node, "entry_index": graph["entryNodeIds"].index(node_id)
                    if node_id in graph["entryNodeIds"] else None, "incoming_choices": incoming,
                    "outgoing": {"choices": [], "continue_target_id": None, "terminal_action": "Close"}})
            nodes.append({"npc_id": npc, "id": node_id})
        disclosure = [n for n in graph["nodes"] if rule["requiredFactId"] in n.get("revealedFactIds", [])]
        require(len(disclosure) == 1, "gift fact single authored disclosure")
        intro = next(n for n in graph["nodes"] if any(c.get("oneTimeRewardFlag") for c in n.get("choices", [])))
        require(sorted(c.get("affinityDelta", 0) for c in intro["choices"]) == [0, 1], "positive/neutral introductions")
        recipients.append({"npc_id": npc, "display_name": runtime["displayName"], "pronouns": runtime["pronouns"],
                           "relationship": relationship, "gift_rule": rule, "gift_choices": gift_choices,
                           "gift_fact_disclosure_node": disclosure[0], "introduction_node": intro,
                           "activated_nodes": recipient_nodes})
    enabled = {(r["npc_id"], kind, r["id"]) for kind, rows in
               [("gift_rule", rules), ("choice", choices), ("node", nodes)] for r in rows}
    require(len(rules) == 8 and len(choices) == 10 and len(nodes) == 9, "activation totals")
    for key in enabled:
        require(any((r["npc_id"], r["kind"], r["id"]) == key and r["status"] == "deferred" for r in coverage), "only deferred items activated")
    deferred = [r for r in coverage if r["status"] == "deferred" and r["kind"] in ("node", "choice", "fact")
                and (r["npc_id"], r["kind"], r["id"]) not in enabled]
    require([sum(r["kind"] == k for r in deferred) for k in ("node", "choice", "fact")] == [3, 6, 3], "retained deferred boundaries")
    return {"schema_version": 1, "policy_id": "social-60c20eb2-g001", "base_snapshot_id": "villagers-60c20eb2-n001",
            "source_revision": REVISION, "selected_ids": ROSTER, "activation_task": "G004",
            "source_item_mapping": {"moonflower": "item-moonflower"},
            "enable": {"gift_rule": rules, "choice": choices, "node": nodes},
            "recipients": recipients, "preserve_deferred": deferred,
            "expected_enabled_totals": {"node": 67, "choice": 48, "fact": 21, "gift_rule": 8},
            "application": "Overlay current generated availability only. Preserve all source fields, existing Della adaptation, portraits, placements and immutable NPC coverage. G001 does not activate production content."}


def expected_vectors(policy):
    """Reference expectations for downstream tests; these do not execute Godot."""
    sequences = []
    for person in policy["recipients"]:
        npc = person["npc_id"]
        for intro in person["introduction_node"]["choices"]:
            initial = intro.get("affinityDelta", 0)
            affinity = [initial, initial + 1, initial + 2]
            sequences.append({"id": npc + ":" + intro["id"], "npc_id": npc,
                "introduction_choice_id": intro["id"], "gift_choice_ids": [r["choice"]["id"] for r in person["gift_choices"]],
                "precondition": "Actual entered preference node and two owned Moonflowers; introduction accepted once.",
                "affinity_after_intro_and_each_gift": affinity, "level_after_intro_and_each_gift": [int(a >= 3) for a in affinity],
                "remaining_from_two_owned_after_each_gift": [1, 0], "item_gifted_counts": [1, 2],
                "third_gift": "acceptanceCapReached", "milestone_entry_count": int(npc == "npc-01" and initial == 1),
                "seen_flag": "relationshipLevel1Seen" if npc == "npc-01" and initial == 1 else None})
    return {"schema_version": 1, "policy_id": policy["policy_id"],
        "evidence_kind": "Reviewed reference expectations; not executed source tests or target runtime acceptance.",
        "source_sequences": sequences,
        "eligibility_cases": [
            {"case": "allowed", "conditions": True, "rule": True, "giftable": True, "owned": 1, "fact": True, "gift_count": 0, "reason": None},
            {"case": "second deliberate gift", "conditions": True, "rule": True, "giftable": True, "owned": 1, "fact": True, "gift_count": 1, "reason": None},
            {"case": "conditions first", "conditions": False, "rule": False, "giftable": False, "owned": 0, "fact": False, "gift_count": 2, "reason": "conditions"},
            {"case": "missing rule", "conditions": True, "rule": False, "giftable": True, "owned": 1, "fact": True, "gift_count": 0, "reason": "missingGiftRule"},
            {"case": "unknown or non-giftable item", "conditions": True, "rule": True, "giftable": False, "owned": 1, "fact": True, "gift_count": 0, "reason": "itemNotGiftable"},
            {"case": "missing item", "conditions": True, "rule": True, "giftable": True, "owned": 0, "fact": True, "gift_count": 0, "reason": "missingItem"},
            {"case": "missing learned fact", "conditions": True, "rule": True, "giftable": True, "owned": 1, "fact": False, "gift_count": 0, "reason": "missingRequiredFact"},
            {"case": "cap boundary", "conditions": True, "rule": True, "giftable": True, "owned": 1, "fact": True, "gift_count": 2, "reason": "acceptanceCapReached"}],
        "eligibility_precedence": ["missingRelationship (controller)", "conditions", "missingGiftRule", "itemNotGiftable", "missingItem", "missingRequiredFact", "acceptanceCapReached", "available"],
        "gift_events_in_order": [{"kind": "itemGifted", "subjectId": "moonflower", "targetId": "<npc_id>"},
                                 {"kind": "dialogueChoiceSelected", "subjectId": "<npc_id>", "targetId": "<choice_id>"}],
        "event_time": "Both events use the same activePlaySeconds; distinct consecutive sequence numbers.",
        "transition_order": ["choice effects/one-time guard", "gift affinity delta with clamping", "level crossing/milestone candidate",
                             "endsConversation wins", "milestone or authored next", "entry seen IDs/facts/milestone flag", "gift event", "choice event", "publish state", "observers/quest callback"],
        "shared_cap": [{"npc_id": p["npc_id"], "choice_ids": [r["choice"]["id"] for r in p["gift_choices"]],
                        "counts_after_alternating_choices": [1, 2], "next_choice_rejected": True} for p in policy["recipients"][:2]],
        "selection": [{"owned_before": 2, "owned_after": 1, "active_after": "item-moonflower"},
                      {"owned_before": 1, "owned_after": 0, "active_after": None}],
        "generic_source_boundaries": [
            {"case": "signed_clamp", "before": 0, "delta": -1, "after": 0},
            {"case": "upper_clamp", "before": 2147483647, "delta": 1, "after": 2147483647},
            {"case": "endsConversation crossing", "milestone_candidate": True, "next_dialogue": None, "milestone_flag_on_entry": False},
            {"case": "normal entry to Edric milestone", "flag_on_entry": "relationshipLevel1Seen"},
            {"case": "seen flag then decline/re-cross", "milestone_injection": False}],
        "people": {"initial": [], "met_gate": "seenDialogueIds is not empty",
            "name_sort": [p["npc_id"] for p in sorted(policy["recipients"], key=lambda p: p["display_name"])],
            "fact_sort": ["category", "label"], "facts": "Only authored facts whose IDs occur in learnedFactIds",
            "primary_portrait": "official-neutral, else first valid authored portrait",
            "level_zero_label": None, "level_one_label": "Acquaintance", "progress": "affinity / levelOneAffinity (3); no level2",
            "opening_or_selection_mutations": [], "proximity_or_title_disclosure": [],
            "edric_after_hint_facts": ["npc-01-moonflower-preference"], "della_after_intro_facts": ["npc-14-public-role"],
            "undisclosed_fact_ids": [r["id"] for r in policy["preserve_deferred"] if r["kind"] == "fact"]},
        "target_strengthening_not_source_proof": ["stale/double-click token rejection", "foreign NPC/node/instance rejection",
            "inventory revision rejection", "event exhaustion rollback", "reentrancy rejection", "invalid target rollback",
            "detached caller mutation isolation", "save gift/choice count and milestone derivation"],
        "ordinary_supply": {"flower_node_ids": ["moonflower-01", "moonflower-02", "moonflower-03"], "total": 3,
            "possible": "Positive Edric introduction + two gifts + one different recipient gift",
            "all_eight_cap_coverage": "Synthetic fixtures or independent fresh runs; never free items/respawn"}}


def audit(source=None, current_baseline=False):
    manifest = read(REF / "manifest.json")
    require(manifest["schema_version"] == 1 and manifest["source_revision"] == REVISION and manifest["selected_ids"] == ROSTER, "social manifest identity")
    require(manifest["source_worktree_status"] == "" and manifest["source_head"] == REVISION, "recorded clean source")
    require(len(manifest["source_inputs"]) == len(SOURCE_PATHS) and
            {r["source_path"] for r in manifest["source_inputs"]} == SOURCE_PATHS, "exact bounded public source allowlist")
    require([r["path"] for r in manifest["artifacts"]] ==
            ["social_activation.json", "behavior_vectors.json", "target_baseline.json"], "exact social artifacts")
    expected_files = {"manifest.json", *[r["path"] for r in manifest["artifacts"]],
                      *[r["snapshot_path"] for r in manifest["source_inputs"]]}
    require({p.relative_to(REF).as_posix() for p in REF.rglob("*") if p.is_file()} == expected_files,
            "no extra snapshots/private profiles/people")
    for row in manifest["npc_reference_files"]:
        require(sha(bounded_path(NPC_REF, row["path"]).read_bytes()) == row["sha256"], "historical NPC pin changed: " + row["path"])
    npc_manifest = read(NPC_REF / "manifest.json")
    require(npc_manifest["source_revision"] == REVISION and npc_manifest["selected_ids"] == ROSTER, "NPC pin identity")
    for row in npc_manifest["inputs"]:
        if row.get("snapshot_path"):
            data = bounded_path(NPC_REF, row["snapshot_path"]).read_bytes()
            require(sha(data) == row["sha256"] and len(data) == row["bytes"], "NPC snapshot bytes/hash")
        if source:
            require(sha(bounded_path(source, row["source_path"]).read_bytes()) == row["sha256"], "live NPC source drift: " + row["source_path"])
    for row in npc_manifest["generated"]:
        require(sha(bounded_path(NPC_REF, row["path"]).read_bytes()) == row["sha256"], "NPC generated reference hash")
    fragments = {}
    for row in manifest["source_inputs"]:
        require(row["source_revision"] == REVISION, "source input revision")
        artifact = bounded_path(REF, row["snapshot_path"])
        require(sha(artifact.read_bytes()) == row["snapshot_sha256"], "bounded source snapshot changed")
        snapshot = read(artifact)
        require(snapshot["source_path"] == row["source_path"], "snapshot provenance")
        require(all(x["start_line"] >= 1 and x["end_line"] >= x["start_line"] for x in snapshot["excerpts"]), "line bounds")
        for x in snapshot["excerpts"]:
            require(len(x["text"].splitlines()) == x["end_line"] - x["start_line"] + 1 and sha(x["text"].encode()) == x["sha256"], "excerpt bounds/hash")
        fragments[row["source_path"]] = "\n".join(x["text"] for x in snapshot["excerpts"])
        if source:
            data = bounded_path(source, row["source_path"]).read_bytes()
            require(sha(data) == row["sha256"] and len(data) == row["bytes"], "live social source drift: " + row["source_path"])
            lines = data.decode("utf-8-sig").splitlines()
            for x in snapshot["excerpts"]:
                require("\n".join(lines[x["start_line"]-1:x["end_line"]]) + "\n" == x["text"], "live excerpt drift")
    for row in manifest["artifacts"]:
        require(sha(bounded_path(REF, row["path"]).read_bytes()) == row["sha256"], "social artifact drift: " + row["path"])
    expected = expected_policy()
    require(read(REF / "social_activation.json") == expected, "activation must equal exact approved overlay")
    require(read(REF / "behavior_vectors.json") == expected_vectors(expected), "reference behavioral vector drift")
    controller = fragments["lib/game/state/runtime_game_controller.dart"]
    gift = controller[controller.index("DialogueChoiceTransition? _applyGiftChoice"):]
    ordered = ["choice.applyTo(", "applyAffinityDelta(", "final milestone = _milestoneFor(", "choice.endsConversation",
               "_relationshipEnteringNode(relationship, nextDialogue)", "kind: PlayerEventKind.itemGifted", "kind: PlayerEventKind.dialogueChoiceSelected", "_setState(", "onQuestActions?.call"]
    offsets = [gift.index(token) for token in ordered]
    require(offsets == sorted(offsets), "source gift event/transition/publication order")
    eligibility = fragments["lib/game/dialogue/dialogue_choice_eligibility.dart"]
    offsets = [eligibility.index(token, eligibility.index("  DialogueChoiceEligibility evaluate")) for token in
               ["choice.conditions.matches", "if (!choice.isGift)", "if (giftRule == null)", "itemCatalog.findById", "inventoryCounts[", "final requiredFactId", "journal.count("]]
    require(offsets == sorted(offsets), "source eligibility precedence")
    people = fragments["lib/game/state/people_snapshot.dart"]
    for token in ["relationship.seenDialogueIds.isEmpty", "relationship.learnedFactIds.contains(fact.id)", "left.category.compareTo", "left.label.compareTo", "['official-neutral']", "left.displayName.compareTo", "List.unmodifiable"]:
        require(token in people, "People reference semantics: " + token)
    require("next.flags.contains(milestone.seenFlagId)" in controller and "?milestoneSeenFlagId" in controller, "milestone guard/entry")
    baseline = read(REF / "target_baseline.json")
    require(baseline["schema_version"] == 7 and baseline["content_version"] == 1, "recorded versions")
    require(baseline["enabled_counts"] == {"node": 58, "choice": 38, "fact": 21, "gift_rule": 0}, "recorded baseline availability")
    require(baseline["item_type_ids"] == ["item-fishing-rod", "item-moonflower"] and baseline["inventory_slot_capacity"] == 20, "two types, twenty-slot capacity")
    require(baseline["flower_node_ids"] == ["moonflower-01", "moonflower-02", "moonflower-03"] and baseline["event_key_count"] == 40, "baseline supply/events")
    for row in baseline["owners"]:
        for x in row["excerpts"]:
            require(sha(x["text"].encode()) == x["sha256"], "bounded target excerpt hash")
        if current_baseline:
            require(sha(bounded_path(ROOT, row["path"]).read_bytes()) == row["sha256"], "G001-only baseline differs: " + row["path"])
    if source:
        args = ["git", "-c", "safe.directory=" + source.as_posix(), "-C", str(source)]
        require(subprocess.check_output(args + ["rev-parse", "HEAD"], text=True).strip() == REVISION, "live source HEAD differs; do not repin")
        require(not subprocess.check_output(args + ["status", "--porcelain"], text=True).strip(), "live source dirty; reconcile, do not repin")
    docs = ROOT / "docs/gifts-friendship-people-journal"
    link_count = 0
    for path in [*docs.glob("*.md"), ROOT / "tools/social_migration/README.md"]:
        for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                require((path.parent / link.split("#")[0]).exists(), "broken link: " + str(path) + " -> " + link)
                link_count += 1
    return {"people": 8, "gift_rules": 8, "gift_choices": 10, "activated_nodes": 9,
            "remaining_deferred": {"nodes": 3, "choices": 6, "facts": 3}, "source_inputs": len(manifest["source_inputs"]),
            "sequence_vectors": 16, "local_links": link_count, "current_g001_baseline_compared": current_baseline,
            "live_source_compared": source is not None, "runtime_acceptance": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, help="Read-only source HEAD/hash/excerpt comparison; never repins")
    parser.add_argument("--check-g001-baseline", action="store_true", help="G001 only: compare selected current owner hashes")
    args = parser.parse_args()
    print("SOCIAL_REFERENCE PASS " + json.dumps(audit(args.source, args.check_g001_baseline), sort_keys=True))


if __name__ == "__main__":
    main()
