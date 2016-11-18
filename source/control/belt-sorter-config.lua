
local minimalUpdateTicks = 20

-- Registering entity into system
local ghost = {}
entities["entity-ghost"] = ghost

ghost.build = function(entity)
	if entity.ghost_name == "belt-sorter-config-combinator" then
		scheduleAdd(entity,TICK_SOON)
		info("Added ghost config entity")
		return {}
	end
	return nil
end

ghost.tick = function(entity,data)
	info("tick ghost entity")
	if not data.beltSorter then
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			area={{pos.x-0.5,pos.y-0.5},{pos.x+0.5,pos.y+0.5}}, 
			name="entity-ghost",
			force=entity.force
		}
		local beltSorter
		for i=1,#entities do
			if entities[i].ghost_name == "belt-sorter-advanced" then
				data.beltSorter = entities[i]
				info("found belt-sorter")
				break
			end
		end
	end
	if not data.beltSorter or not data.beltSorter.valid then
		info("removed ghost entity, because beltSorter doesn't exist or became invalid")
		entities_remove(idOfEntity(entity))
		entity.destroy()
		return nil,nil
	end
	return minimalUpdateTicks,nil
end


ghost.premine = function(entity,data,player)
	if entity.ghost_name == "belt-sorter-advanced" then
		info("removed belt-sorter ghost")
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			area={{pos.x-0.5,pos.y-0.5},{pos.x+0.5,pos.y+0.5}}, 
			name="entity-ghost",
			force=entity.force
		}
		for i=1,#entities do
			if entities[i].ghost_name == "belt-sorter-config-combinator" then
				info("found and removed belt-sorter config")
				entities[i].destroy()
				break
			end
		end
	end
	return true
end
