# Painted coastal storybook look specification

AD001, 2026-10-11 UTC. Look authority: [selected image](../../art/direction/2026-10-10/01-painted-coastal-storybook.png), SHA256 `57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a`; provenance: [prompts](../../art/direction/2026-10-10/prompts.json). Geometry and behavior authority remain current project files and original source pins. [BASELINE](BASELINE.md) records actual Godot appearance and reproducible views; this document defines future art targets, not already implemented art.

## Palette and value hierarchy

Reference pixels show cream plaster, muted blue roofs, brown timber, warm apricot paths, yellow-sage grass, grouped green foliage and turquoise water. Use the following starting **authoring sRGB swatches**, selected by visual interpretation rather than claiming exact sampled material colors from a lit image. Calibrate their actual in-engine appearance in the fixed baseline views before changing global lighting.

| Family | Starting hex | Intended role |
| --- | --- | --- |
| Plaster | `#DCC49A` | Warm light facade, broad quiet plane |
| Slate | `#465F83` | Muted indigo roof; separate from plaster without bright tile noise |
| Timber | `#735033` | Warm structural beams, counter and dock; deeper joins `#48362A` |
| Path | `#E7B16E` | Apricot navigation ribbon, light but below cream highlights |
| Meadow | `#929C4C` | Sage/olive floor; dark variation `#727D3D` |
| Foliage | `#738C36` | Grouped canopy masses; shade `#4F662E`, restrained highlight `#A7B34C` |
| Water | `#3B9C93` | Sea green; sparse soft highlights `#87C7B7` |
| Sand / stone | `#DCC38C` / `#8B8C7B` | Warm shore, neutral low walls/plaza |
| Window / lamp | `#E7AD58` | Local warm emission at night, tiny area only |
| Role cues | Existing cyan hero, purple ally, teal guardian/vessel | Preserve semantic distinction and feedback timing; AD013 tunes finish |

Measure display-weighted luma `Y' = .2126 R' + .7152 G' + .0722 B'` on rendered 0-255 sRGB pixels, excluding HUD and cast shadows. Day starting bands: timber/joins 45-100, slate 65-115, grass/foliage 90-155, paths 155-205, plaster 175-225. Bands are guidance for representative midtones, not clipping limits or a reason to remove natural shadows. Roof and plaster median separation should be at least 35 luma steps in the pilot; main actor/needed interaction silhouette should separate by at least 20 steps from adjacent floor over most of its edge, or by a clear role hue/outline when values overlap. Inspect actual contact pixels in both projections. Night must keep party/route/required prompt readable without making all surfaces emissive. Existing canopy cutout and semantic feedback take precedence over palette conformity.

Keep environment calmer than useful actors, forage, equipment and interactions. Large structures provide wayfinding through material/value groups; accents occupy small areas. No global outlines, uniform bright highlights, or crisp black texture detail across every ground tile. HUD remains readable over bright ground and dark forest; AD017 owns panel/font presentation.

## Brush scale, density and coverage

At 960x640, orthographic size 18 and zoom1, nominal unforeshortened vertical scale is about 35.6 pixels/metre; visible ground scale depends on camera angle. Judge brush marks in actual gameplay captures, not just a texture editor.

| Surface | Initial density | Low-frequency marks at world scale |
| --- | --- | --- |
| Plaster, roofs, wood, stone modules | 64 texels/metre, acceptable 48-96 | 0.15-0.5m patches, about 3-18 screen pixels depending on orientation |
| Ground / shore world-space sampling | 32 texels/metre, acceptable 24-48 | 0.25-1.0m variation; suppress isolated high-contrast one-pixel speckles |
| Canopy / trunk | 32-64 texels/metre | 0.4-1.5m canopy groups; broader facets, readable vertical trunk stroke |
| Small props | 64-128 texels/metre when visible | Simplify marks that collapse below 2 screen pixels; share atlas space |
| Existing villagers | Up to 128 texels/metre for readable parts within existing atlas cap | Broad clothing/skin groups; retain face/costume/portrait identity |

Use density as a starting allocation, not a mandate to increase mesh density or add unique textures. Record chosen UV density against known mesh metres in each task. Repeat/mirror reusable material patches intentionally; preserve orientation of timber/planks. All front/back/side/top visible faces need deliberate UV coverage. Inspect gameplay zoom1 plus 0.8 and 1.15, both projections, and a close diagnostic view. Broad brushwork should survive mips without seams, obvious repetition or palette multiplication.

Default shared 1024x1024 albedo atlases: plaster/timber/slate, foliage/bark, ground/stone/shore; reuse town families for rooms and props where practical. This is a recipe proposal, not a requirement to generate all atlases in AD002. Use 16 native texels of dilated gutter between incompatible regions, reserve edge padding and test mip bleed at gameplay distance. Additional 2048 atlases require documented density and measured memory justification. No baked directional sun shadow: use restrained contact darkening under eaves/joins, leaving moving sun and pooled lamps to Godot.

Albedo is sRGB; masks are linear/data. Opaque matte defaults, roughness roughly 0.8-1.0; preserve justified metallic/emission semantics on existing guardian, vessel and lamps. Record import compression, mipmaps, filter/repeat, texture dimensions and actual runtime memory. 1024 RGBA8 is 4MiB before mipmaps, about 5.33MiB for a full mip chain; 2048 is 16MiB/21.33MiB. These are uncompressed estimates, not GLB file sizes. Default mipmapped linear filtering; repeat only for designed tiled/world-space textures, clamp atlas edges. Inspect imported shader/material sampling and vertex color together: a painted atlas must not receive the previous palette tint twice.

## Preservation and budgets

Keep current 24 town structures/16 town definitions+modules, 395 trees/21 variants, five landmark modules, fixed semantic ground/water/elevation, exact source bases/heights and stable IDs. Preserve current wrapper feet/colliders/navigation, Maris counter/gear fact gates, door/station anchors, eight villagers/rigs/portraits/actions, capsule party, combat rules and schema8/content1. Counts here identify the existing recipe scope; authoritative IDs and pins are in BASELINE and current mappings.

Keep chunked tree MultiMesh and party cutout with intact shadow pass; no per-instance material creation. Reuse surface resources and existing sun/weather/indoor profiles. Maximum eight pooled unshadowed exterior emitters including fades. No dense modeled leaves/roof tiles, grass carpet, GI/SSR/volumetric fog/expensive blur dependency. NPC caps: 12,000 triangles, 32 bones, three material surfaces and one 1024 RGBA atlas per person (4MiB before mips). Static/environment texture work must retain original silhouette/physics guarantees; texture changes do not authorize new rooms, characters or gameplay.

Full AD019 target: Compatibility, 960x640, orthographic zoom1, VSync0/max_fps0; 10s warmup, three60s runs per town/dense-forest/bridge/ford under clear day and storm/night. Whole-frame p95<=16.67ms, p99<=25ms, draw p95<=500, process memory<=2GiB; growth<=64MiB after two warmup round trips plus ten more and10s idle with stable counts. Declare hardware/driver and paired settings. AD001 short paused samples are observations only and cannot satisfy this gate.

## Acceptance method for future appearance changes

Use BASELINE fixed poses/settings and actual Godot PNGs. First check camera/crop and preserved geometry/UV coverage; then tune material hue/value/brush scale; only AD007 adjusts shared lighting. Never conceal incorrect shape, texture mapping or readability through overexposure/fog/glow. Compare median family luma, roof/plaster contrast, role visibility and seams alongside direct pixel inspection. Preserve original pins and append narrow material-policy adaptations to affected tests. Blender/imagegen outputs provide authoring evidence only; the running Godot view accepts the look. Pilot AD008 and integrated AD018 own overall visual acceptance; this brief does not declare the reference achieved.
