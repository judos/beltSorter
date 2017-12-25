
-- Item
data:extend({
	{
		type = "item-group",
		name = "beltSorter-filters",
		order = "g",
		icon_size = 64,
		icon = "__beltSorter__/graphics/item-groups/belt-sorter-filters.png",
	},
	{
		type = "item-subgroup",
		name = "beltSorter-filters",
		group = "beltSorter-filters",
		order = "a"
	},
	{
		type = "item",
		name = "belt-sorter-everythingelse",
		order = "z[belt-sprter-everythingelse]",
		icon_size = 32,
		icon = "__beltSorter__/graphics/icons/belt-sorter-everythingelse.png",
		subgroup = "beltSorter-filters",
		stack_size = 1,
		flags = {"goes-to-main-inventory"}
	}
})