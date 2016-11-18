
require "libs.functions"
require "libs.control.controlFunctions"
require "libs.control.functions"

require "constants"

require "control.belt-sorter"
require "control.belt-sorter-advanced"
require "control.belt-sorter-config"

-- global data used:
-- beltSorter.version = $version

---------------------------------------------------
-- Init
---------------------------------------------------
script.on_init(function()
	if not global.beltSorter then global.beltSorter = {} end
	local bs = global.beltSorter
	if not bs.version then bs.version = modVersion end
	
	entities_init()
	gui_init()
	
end)

script.on_load(function()
	info(global)
end)

script.on_configuration_changed(function()
	local bs = global.beltSorter
	local previousVersion = bs.version
	if bs.version < "0.2.2" then
		entities_init() --does migration
		bs.version = "0.2.2"
	end
	if bs.version < "0.3.0" then
		bs.version = "0.3.0"
		entities_init() --does migration
	end
	if bs.version < "0.3.4" then
		bs.version = "0.3.4"
	end
	if bs.version ~= previousVersion then
		info("Previous version: "..previousVersion.." migrated to "..bs.version)
	end
end)


---------------------------------------------------
-- Tick
---------------------------------------------------
script.on_event(defines.events.on_tick, function(event)
	entities_tick()
	gui_tick()
end)

---------------------------------------------------
-- Building Entities
---------------------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
	--info(event.created_entity.type)
	entities_build(event)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
	entities_build(event)
end)

---------------------------------------------------
-- Removing entities
---------------------------------------------------
script.on_event(defines.events.on_robot_pre_mined, function(event)
	entities_pre_mined(event)
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	entities_pre_mined(event)
end)

---------------------------------------------------
-- Removing entities
---------------------------------------------------

script.on_event(defines.events.on_entity_settings_pasted, function(event)
	entities_settings_pasted(event)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	entities_marked_for_deconstruction(event)
end)

