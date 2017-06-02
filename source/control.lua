
require "libs.all"
require "libs.prototypes.all"
require "libs.control.functions"

require "constants"

require "control.belt-sorter"
require "control.belt-sorter-gui"
require "control.belt-sorter-config"

-- global data used:
-- beltSorter.version = $version

---------------------------------------------------
-- Init
---------------------------------------------------

local function migration()
	local bs = global.beltSorter
	local previousVersion = bs.version
	if bs.version < "0.3.7" then
		bs.version = "0.3.7"
	end
	if bs.version ~= previousVersion then
		info("Previous version: "..previousVersion.." migrated to "..bs.version)
	end
end

local function init()
	if not global.beltSorter then global.beltSorter = {} end
	local bs = global.beltSorter
	if not bs.version then bs.version = modVersion end
	
	entities_init()
	gui_init()
	migration()
end

script.on_init(init)
script.on_configuration_changed(init)


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
-- Others
---------------------------------------------------

script.on_event(defines.events.on_entity_settings_pasted, function(event)
	entities_settings_pasted(event)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	entities_marked_for_deconstruction(event)
end)

