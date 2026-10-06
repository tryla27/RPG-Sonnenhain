# Map 0 Terrain Rework – 2026-10-06

Map 0 keeps its existing 56×82 logical grid, routes, buildings, doors, collisions and gameplay. The visual floor is replaced by a dedicated 32px terrain family layer inspired by the new village-house and arena art.

New visual families: village grass, moss grass, forest ground, garden path, village path, village stone, old cobble rework, plaza stone, building apron, arena entry stone, arena border and arena ground. The renderer also owns sparse deterministic overlays, supported material transitions and visual-only plaza/arena height accents.

`map0_ground_plan_32.gd` remains authoritative for logical placement. `terrain_offer_32.gd` translates logical materials into context-sensitive visual families; selectors are deterministic so reloads and multiplayer clients resolve the same visual variant. No collision, navigation, save, quest, NPC, combat or multiplayer rule is changed by this pass.


## Production atlas size
The Map 0 visual kit now provides 640 exact 32×32 slots: 192 ground tiles (12 families × 16 deterministic variants), 256 supported transition slots, 128 sparse overlay slots and 64 visual height/step slots. Large surfaces therefore no longer cycle through a four-tile pattern.
