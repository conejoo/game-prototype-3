# Local item art kit

`game/world/foraging_item_visual.gd` is the editable source and runtime mesh kit.
It creates low-poly five-petal moonflowers with two leaves, and horizontal rods with
cork grip, three teal bindings and a reel. No external art/runtime dependency.
SVG icons in this directory are editable local vector sources matching those forms.

VisualRoot stays separate from PrototypeInteractable identity/actions and committed
facts. No collision, navigation, animation timer or saved state. Materials use mild
emission for night readability and create no lights. Rod fits the existing validated
1.0 x 0.14 x 0.44 metre clearance box (visual bottom 0.03m above supported foot).
Moonflower stem starts at ground; bloom top 0.505m. Existing labels remain billboarded
with dark outlines. Geography and physics stay authoritative.
