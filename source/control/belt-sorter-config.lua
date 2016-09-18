
local minimalUpdateTicks = 60

-- Registering entity into system
local ghost = {}
entities["entity-ghost"] = ghost

ghost.build = function(entity)
	if entity.ghost_name == "belt-sorter-config-combinator" then
		scheduleAdd(entity,TICK_SOON)
		return {}
	end
	return nil
end

ghost.tick = function(entity,data)
	if not data.beltSorter then
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			area={{pos.x-0.05,pos.y-0.25},{pos.x+0.05,pos.y-0.15}}, 
			name="entity-ghost",
			force=entity.force
		}
		local beltSorter
		for i=1,#entities do
			if entities[i].ghost_name == "belt-sorter-advanced" then
				data.beltSorter = entities[i]
				break
			end
		end
	end
	if not data.beltSorter or not data.beltSorter.valid then
		entities_remove(idOfEntity(entity))
		entity.destroy()
		return nil,nil
	end
	return 1,nil
end


ghost.premine = function(entity,data,player)
	if entity.ghost_name == "belt-sorter-advanced" then
		local pos = entity.position
		local entities = entity.surface.find_entities_filtered{
			area={{pos.x-0.05,pos.y+0.15},{pos.x+0.05,pos.y+0.25}}, 
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
