
for i=1,3 do
	local beltSorter = deepcopy(data.raw["item"]["wooden-chest"])
	overwriteContent(beltSorter, {
		name = "belt-sorter"..i,
		order = "z[belt-sorter]"..i,
		subgroup = "inserter",
		place_result = "belt-sorter"..i,
		icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png",
		fuel_value = "0MJ"
	})
	data:extend({	beltSorter })
end