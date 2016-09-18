
local minimalUpdateTicks = 60

-- Registering entity into system
local config = {}
entities["entity-ghost"] = config


config.premine = function(entity,data,player)
	if entity.ghost_name == "belt-sorter-advanced" then
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			position={pos.x+1,pos.y}, 
			name="entity-ghost",
			force=entity.force
		}
		for i=1,#entities do
			if entities[i].ghost_name == "belt-sorter-config-combinator" then
				entities[i].destroy()
				break
			end
		end
	end
	return true
end