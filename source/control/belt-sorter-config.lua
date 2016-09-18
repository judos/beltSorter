
local minimalUpdateTicks = 60

-- Registering entity into system
local ghost = {}
entities["entity-ghost"] = ghost

local config = {}
entities["belt-sorter-config-combinator"] = config

ghost.premine = function(entity,data,player)
	if entity.ghost_name == "belt-sorter-advanced" then
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			area={{pos.x-0.05,pos.y+0.15},{pos.x+0.05,pos.y+0.25}}, 
			name="entity-ghost",
			force=entity.force
		}
		info("found entities: "..#entities)
		
		for i=1,#entities do
			if entities[i].ghost_name == "belt-sorter-config-combinator" then
				entities[i].destroy()
				break
			end
		end
	end
	return true
end


config.orderDeconstruct = function(entity,data,player)
	entity.cancel_deconstruction(player.force)
end
