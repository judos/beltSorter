require "libs.prototypes.all"


-- Technology
data:extend({
	{
		type = "technology",
		name = "belt-sorter1",
		icon = "__beltSorter__/graphics/technology/belt-sorter1.png",
		icon_size = 128,
		prerequisites = {"electronics"},
		effects = {},
		unit = {
			count = 50,
			ingredients = {
				{"science-pack-1", 3},
			},
			time = 15
		},
		order = "_belt-sorter1"
	},
	{
		type = "technology",
		name = "belt-sorter2",
		icon = "__beltSorter__/graphics/technology/belt-sorter2.png",
		icon_size = 128,
		prerequisites = {"belt-sorter1", "advanced-electronics" },
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
	},
	{
		type = "technology",
		name = "belt-sorter3",
		icon = "__beltSorter__/graphics/technology/belt-sorter3.png",
		icon_size = 128,
		prerequisites = {"belt-sorter2", "advanced-electronics-2" },
		effects = {},
		unit = {
			count = 20,
			ingredients = {
				{"science-pack-1", 6},
				{"science-pack-2", 4},
				{"science-pack-3", 2},
			},
			time = 15
		},
		order = "_belt-sorter3"
	}
})

addTechnologyUnlocksRecipe("belt-sorter1","belt-sorter1")
addTechnologyUnlocksRecipe("belt-sorter2","belt-sorter2")
addTechnologyUnlocksRecipe("belt-sorter3","belt-sorter3")