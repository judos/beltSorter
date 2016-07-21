
-- Item
local beltSorter = deepcopy(data.raw["item"]["wooden-chest"])
overwriteContent(beltSorter, {
	name = "belt-sorter",
	order = "z[belt-sorter]",
	subgroup = "inserter",
	place_result = "belt-sorter-v2",
	icon = "__beltSorter__/graphics/icons/belt-sorter.png",
	fuel_value = "0MJ"
})
data:extend({	beltSorter })

-- Recipe
data:extend({
	{
		type = "recipe",
		name = "belt-sorter",
		enabled = false,
		ingredients = {
			{"iron-chest", 1},
			{"iron-plate", 10},
			{"basic-circuit-board", 10}
		},
		result = "belt-sorter"
	}
})

-- Helpers
local noPicture = {
	filename="__beltSorter__/graphics/entity/empty.png",
	width = 0,
	height = 0,
	shift = {0, 0}
}

-- Entity
local beltSorter = deepcopy(data.raw["lamp"]["small-lamp"])
overwriteContent(beltSorter, {
	name = "belt-sorter-v2",
	icon = "__beltSorter__/graphics/icons/belt-sorter.png",
	energy_usage_per_tick = "50KW",
	light = {intensity = 0, size = 0},
	picture_off = {
		filename="__beltSorter__/graphics/entity/belt-sorter-off.png",
		width = 46,
		height = 33,
		shift = {0.3, 0}
	},
	picture_on = {
		filename="__beltSorter__/graphics/entity/belt-sorter-on-patch.png",
		width = 46,
		height = 33,
		shift = {0.3, 0}
	}
})
beltSorter.minable.result = "belt-sorter"
data:extend({	beltSorter })

-- fake lamp for wire connection
local beltSorterLamp = deepcopy(data.raw["lamp"]["small-lamp"])
overwriteContent(beltSorterLamp, {
	name = "belt-sorter-lamp",
	order = "zzz",
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{0, 0}, {0, 0}},
	energy_usage_per_tick = "0W",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	light = {intensity = 0, size = 0},
	flags = {"placeable-off-grid", "not-repairable", "not-on-map"},
	picture_off= noPicture,
	picture_on= {
		filename="__beltSorter__/graphics/entity/belt-sorter-on-patch.png",
		width = 46,
		height = 33,
		shift = {0.3, 0}
	}
})

data:extend({	beltSorterLamp })

-- Technology

addTechnologyUnlocksRecipe("logistics","belt-sorter")
