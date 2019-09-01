
-- Pictures helpers
local noPicture = {
	filename="__beltSorter__/graphics/entity/empty.png",
	width = 1,
	height = 1,
	shift = {0, 0}
}
local function picture(lvl,mode)
	return {
		filename="__beltSorter__/graphics/entity/belt-sorter"..lvl.."-"..mode..".png",
		width = 64,
		height = 64,
		shift = {0, 0},
		hr_version = {
			filename="__beltSorter__/graphics/entity/belt-sorter"..lvl.."-hr-"..mode..".png",
			width = 128,
			height = 128,
			scale = 0.5
		}
	}
end

function createBeltSorterPrototype(i, energy)


	local beltSorter = deepcopy(data.raw["lamp"]["small-lamp"])
	overwriteContent(beltSorter, {
		name = "belt-sorter"..i,
		icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png",
		energy_usage_per_tick = tostring(energy).."W",
		light = {intensity = 0, size = 0},
		picture_off = picture(i,"off"),
		picture_on = picture(i,"on")
	})
	beltSorter.minable.result = "belt-sorter"..i
	beltSorter.circuit_connector_sprites = nil
	data:extend({	beltSorter })

	-- Entity: fake lamp for wire connection
	local beltSorterLamp = deepcopy(data.raw["lamp"]["small-lamp"])
	overwriteContent(beltSorterLamp, {
		name = "belt-sorter-lamp"..i,
		icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png",
		order = "zzz",
		collision_box = {{0, 0}, {0, 0}},
		selection_box = {{0, 0}, {0, 0}},
		energy_usage_per_tick = tostring(energy).."W",
		light = {intensity = 0, size = 0},
		flags = {"placeable-off-grid", "not-repairable", "not-on-map"},
		picture_off= noPicture,
		picture_on = picture(i,"on")
	})
	beltSorterLamp.circuit_connector_sprites = nil
	
	print(x(settings.startup['beltSorter-usePower']))
	if not settings.startup['beltSorter-usePower'].value then
		beltSorterLamp.energy_source.type = "void"
		beltSorter.energy_source.type = "void"
	end
	
	data:extend({	beltSorterLamp })
end



function createBeltSorterItemPrototype(i)
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