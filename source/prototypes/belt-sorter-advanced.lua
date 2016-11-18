
-- Item
local beltSorter = deepcopy(data.raw["item"]["belt-sorter"])
overwriteContent(beltSorter, {
	name = "belt-sorter-advanced",
	order = "z[belt-sorter]2",
	place_result = "belt-sorter-advanced",
	icon = "__beltSorter__/graphics/icons/belt-sorter-advanced.png",
	fuel_value = nil
})
data:extend({	beltSorter })

-- Recipe
data:extend({
	{
		type = "recipe",
		name = "belt-sorter-advanced",
		enabled = false,
		ingredients = {
			{"belt-sorter", 2},
			{"steel-plate", 4},
			{"electronic-circuit", 4}
		},
		result = "belt-sorter-advanced"
	}
})

-- Entity
local beltSorter = deepcopy(data.raw["lamp"]["belt-sorter-v2"])
overwriteContent(beltSorter, {
	name = "belt-sorter-advanced",
	icon = "__beltSorter__/graphics/icons/belt-sorter-advanced.png",
	energy_usage_per_tick = "150KW"
	})
beltSorter.picture_off.filename = "__beltSorter__/graphics/entity/belt-sorter-advanced-off.png"
beltSorter.picture_on.filename="__beltSorter__/graphics/entity/belt-sorter-advanced-on.png"
beltSorter.minable.result = "belt-sorter-advanced"
data:extend({	beltSorter })


-- Entity: fake lamp for wire connection
local beltSorterLamp = deepcopy(data.raw["lamp"]["belt-sorter-lamp"])
overwriteContent(beltSorterLamp, {
	name = "belt-sorter-advanced-lamp",
	icon = "__beltSorter__/graphics/icons/belt-sorter-advanced.png",
})
beltSorterLamp.picture_on.filename = "__beltSorter__/graphics/entity/belt-sorter-advanced-on.png"
data:extend({	beltSorterLamp })


-- Technology
data:extend({
	{
		type = "technology",
		name = "belt-sorter-2",
		icon = "__beltSorter__/graphics/technology/belt-sorter.png",
		icon_size = 128,
		prerequisites = {"belt-sorter" },
		effects = {},
		unit = {
			count = 20,
			ingredients = {
				{"science-pack-1", 5},
				{"science-pack-2", 3},
			},
			time = 15
		},
		order = "_belt-sorter2"
	}
})
addTechnologyUnlocksRecipe("belt-sorter-2","belt-sorter-advanced")