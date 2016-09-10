local belt = deepcopy(data.raw["transport-belt"]["transport-belt"])
belt.name = "beltSorter-connection-belt"
belt.collision_box = {{0, 0}, {0, 0}}
belt.selection_box = {{0, 0}, {0, 0}}
belt.minable = nil
belt.speed = 0
belt.order = "_zz"
belt.flags = {"placeable-off-grid", "not-on-map", "not-repairable"}
belt.animations = {
	width = 1,
	height = 1,
	frame_count = 32,
	direction_count = 12,
	filename = "__beltSorter__/graphics/transport-belt.png",
}

data:extend({
	belt
})
