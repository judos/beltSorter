
-- Pictures helpers
local noPicture = {
	filename="__beltSorter__/graphics/entity/empty.png",
	width = 0,
	height = 0,
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

-- Entity
local energy = {25,50,100}

for i=1,3 do
	local beltSorter = deepcopy(data.raw["lamp"]["small-lamp"])
	
	overwriteContent(beltSorter, {
		name = "belt-sorter"..i,
		icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png",
		energy_usage_per_tick = tostring(energy[i]).."KW",
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
		energy_usage_per_tick = "1J",
		energy_source = {
			type = "electric",
			usage_priority = "primary-input"
		},
		light = {intensity = 0, size = 0},
		flags = {"placeable-off-grid", "not-repairable", "not-on-map"},
		picture_off= noPicture,
		picture_on = picture(i,"on")
	})
	beltSorterLamp.circuit_connector_sprites = nil
	data:extend({	beltSorterLamp })
end