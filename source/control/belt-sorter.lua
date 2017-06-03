require "libs.classes.BeltFactory"

-- Registering entity into system
local beltSorter = {}
entities["belt-sorter1"] = beltSorter
entities["belt-sorter2"] = beltSorter
entities["belt-sorter3"] = beltSorter

-- Constants
local searchPriority = {{0,-1},{-1,0},{1,0},{0,1}}
local rowIndexToDirection = {
	[1]=defines.direction.north,
	[2]=defines.direction.west,
	[3]=defines.direction.east,
	[4]=defines.direction.south
}
local minimalUpdateTicks = 80


---------------------------------------------------
-- entityData
---------------------------------------------------

-- Used data:
-- {
--   lamp = LuaEntity(fake lamp),
--	 config = LuaEntity(fake constant combinator to store settings)
--   filter[$itemName] = { $row1, $row2, ... }
--   guiFilter[$row.."."..$slot] = $itemName
-- }

--------------------------------------------------
-- Global data
--------------------------------------------------

-- This helper file uses the following global data variables:
-- global.gui.playerData[$playerName].beltSorterGuiCopy = $guiFilter

---------------------------------------------------
-- build and remove
---------------------------------------------------

beltSorter.build = function(entity)
	scheduleAdd(entity, TICK_ASAP)
	local data = {}

	local pos = {x = entity.position.x, y=entity.position.y}
	local lvl = tonumber(entity.name:sub(-1))
	local lamp = entity.surface.create_entity({name="belt-sorter-lamp"..lvl,position=pos,force=entity.force})
	lamp.operable = false
	lamp.minable = false
	lamp.destructible = false
	lamp.get_or_create_control_behavior().circuit_condition = {
		condition = {
			comparator = "=",
			first_signal = {type="item", name="iron-plate"},
			second_signal = {type="item", name="iron-plate"}
		}
	}
	entity.connect_neighbour{wire=defines.wire_type.green,target_entity=lamp}
	
	-- find config combinator and load it's config
	local entities = entity.surface.find_entities_filtered{
		area={{pos.x-0.5,pos.y-0.5},{pos.x+0.5,pos.y+0.5}}, 
		name="entity-ghost", 
		force=entity.force
	}
	local config = nil
	for i = 1,#entities do
		if entities[i].ghost_name == "belt-sorter-config-combinator" then
			config = entities[i]
			break
		end
	end
	if config then
		info("built belt-sorter and found config for it")
		_,data.config = config.revive()
		beltSorter_LoadFilterFromConfig(data)
	else
		info("built belt-sorter but no config was found")
		data.config = entity.surface.create_entity({
			name = "belt-sorter-config-combinator",
			position = {pos.x,pos.y+0.2},
			force = entity.force
		})
		data.config.operable = false
		data.config.minable = false
		data.config.destructible = false
	end
	
	overwriteContent(data,{
		config = data.config,
		lamp = lamp,
		filter = data.filter or {},
		guiFilter = data.guiFilter or {}
	})
	return data
end

beltSorter.remove = function(data)
	if data.lamp and data.lamp.valid then
		data.lamp.destroy()
	end
	if data.config and data.config.valid then
		data.config.destroy()
	end
end

beltSorter.copy = function(source,srcData,target,targetData)
	info(target.name:sub(1,11))
	if not target.name:sub(1,11) == "belt-sorter" then
		return
	end
	info("adv Copy entity: "..serpent.block(srcData).." target: "..serpent.block(targetData))

	targetData.guiFilter = deepcopy(srcData.guiFilter)
	beltSorter_RebuildFilterFromGui(targetData)
	local playersWithGuiOfTarget = gui_playersWithOpenGuiOf(target)
	for _,player in pairs(playersWithGuiOfTarget) do
		beltSorter_RefreshGui(player,target)
	end
end


beltSorter.tick = function(beltSorter,data)
	if not data then
		err("Error occured with beltSorter: "..idOfEntity(beltSorter))
		return 0,nil
	end
	if data.condition == nil or data.nextConditionUpdate == nil or data.nextConditionUpdate <= game.tick then
		beltSorter_UpdateCircuitCondition(beltSorter,data)
		if data.condition == false then
			return minimalUpdateTicks,nil
		end
	end

	local energyPercentage = math.min(beltSorter.energy,2666) / 2666
	local nextUpdate
	if energyPercentage < 12/minimalUpdateTicks then
		nextUpdate = minimalUpdateTicks
	else
		nextUpdate = math.floor(12 / energyPercentage)
		beltSorter_SearchInputOutput(beltSorter,data)
		beltSorter_DistributeItems(beltSorter,data)
		data.input = nil
		data.output = nil
	end
	return nextUpdate,nil
end


---------------------------------------------------
-- Helper methods
---------------------------------------------------


beltSorter_UpdateCircuitCondition = function(beltSorter,data)
	-- check circuit
	local behavior = beltSorter.get_or_create_control_behavior()
	local conditionTable = behavior.circuit_condition
	if conditionTable.condition.first_signal.name ~= nil then
		data.condition = conditionTable.fulfilled
	else
		data.condition = true
	end
	
	-- check logistic condition
	if data.condition and behavior.connect_to_logistic_network then
		conditionTable = behavior.logistic_condition
		if conditionTable.condition.first_signal.name ~= nil then
			data.condition = conditionTable.fulfilled
		else
			data.condition = true
		end
	end
	
	local lampCondition = {
		condition = {
			comparator= (data.condition and "=" or ">"),
			first_signal={type="item", name="iron-plate"},
			second_signal={type="item", name="iron-plate"}
		}
	}
	data.lamp.get_control_behavior().circuit_condition = lampCondition
	data.nextConditionUpdate = game.tick + 60
end

beltSorter_DistributeItems = function(beltSorter,data)
	-- Search for input (only loop if items available), mostly only 1 input
	for inputSide,inputAccess in pairs(data.input) do
		if not inputAccess:isValid() then
			data.input[inputSide] = nil
		else
			for itemName,_ in pairs(inputAccess:get_contents()) do
				local sideList = data.filter[itemName]
				if sideList then
					beltSorter_DistributeItemToSides(data,inputAccess,itemName,sideList)
				else -- item can go nowhere, check rest filter
					sideList = data.filter["belt-sorter-everythingelse"]
					if sideList then
						beltSorter_DistributeItemToSides(data,inputAccess,itemName,sideList)
					end
				end
			end
		end
	end
end


beltSorter_DistributeItemToSides = function(data,inputAccess,itemName,sideList)
	local itemStack = {name=itemName,count=1}
	for side,outputOnLanes in pairs(sideList) do
		local outputAccess = data.output[side]
		if outputAccess then
			if not outputAccess:isValid() then
				data.output[side] = nil
			else
				beltSorter_InsertAsManyAsPossible(inputAccess,outputAccess,itemStack,outputOnLanes)
			end
		end
	end
end

beltSorter_InsertAsManyAsPossible = function(inputAccess,outputAccess,itemStack,outputOnLanes)
	local curPos = 0.13
	while curPos <= 1 do
		if outputOnLanes[1] and outputAccess:can_insert_on_at(false,curPos) then
			local result = inputAccess:remove_item(itemStack)
			if result == 0 then	return end
			outputAccess:insert_on_at(false,curPos,itemStack)
		end
		if outputOnLanes[2] and outputAccess:can_insert_on_at(true,curPos) then
			local result = inputAccess:remove_item(itemStack)
			if result == 0 then	return end
			outputAccess:insert_on_at(true,curPos,itemStack)
		end
		curPos = curPos + 0.29
	end
	
end

beltSorter_SearchInputOutput = function(beltSorter,data)
	local surface = beltSorter.surface
	local x = beltSorter.position.x
	local y = beltSorter.position.y
	-- search for input and output belts
	data.input = {}
	data.output = {}
	for rowIndex = 1, 4 do
		data.input[rowIndex] = nil -- [side] => BeltAccess or SplitterAccess objects
		data.output[rowIndex] = nil -- [side] => BeltAccess or SplitterAccess objects
		local searchPos = searchPriority[rowIndex]
		local searchPoint = { x = x + searchPos[1], y = y + searchPos[2] }
		for _,searchType in pairs(BeltFactory.supportedTypes) do
			local candidates = surface.find_entities_filtered{position = searchPoint, type= searchType}
			for _,entity in pairs(candidates) do
				local access = BeltFactory.accessFor(entity,searchPoint,beltSorter.position)
				if access:isInput() then
					data.input[rowIndex] = access
				else
					data.output[rowIndex] = access
				end
			end
		end
	end
end
