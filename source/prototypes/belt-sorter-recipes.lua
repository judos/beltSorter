data:extend({
	{
		type = "recipe",
		name = "belt-sorter1",
		enabled = false,
		ingredients = {
			{"steel-chest", 1},
			{"steel-plate", 5},
			{"electronic-circuit", 4}
		},
		result = "belt-sorter1",
		icon_size = 32
	},
	{
		type = "recipe",
		name = "belt-sorter2",
		enabled = false,
		ingredients = {
			{"belt-sorter1", 1},
			{"advanced-circuit", 4}
		},
		result = "belt-sorter2",
		icon_size = 32
	},
	{
		type = "recipe",
		name = "belt-sorter3",
		enabled = false,
		ingredients = {
			{"belt-sorter2", 1},
			{"processing-unit", 4}
		},
		result = "belt-sorter3",
		icon_size = 32
	}
})