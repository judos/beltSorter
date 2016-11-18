require "libs.classes.BeltFactory"
require "libs.itemSelection.control"

-- Registering entity into system
local beltSorter = {}
entities["belt-sorter-advanced"] = beltSorter

-- Constants
local searchPriority = {{0,-1},{-1,0},{1,0},{0,1}}
local rowIndexToDirection = {
	[1]=defines.direction.north,
	[2]=defines.direction.west,
	[3]=defines.direction.east,
	[4]=defines.direction.south
}
local guiSlotsAvailable = 2
local minimalUpdateTicks = 80

local m = {} --methods

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
	
	local lamp = entity.surface.create_entity({name="belt-sorter-advanced-lamp",position=pos,force=entity.force})
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
		m.loadFilterFromConfig(data)
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
	targetData.guiFilter = deepcopy(srcData.guiFilter)
	m.beltSorterRebuildFilterFromGui(targetData)
	local playerWithGuiOfTarget = gui_playersWithOpenGuiOf(target)
	for _,player in pairs(playerWithGuiOfTarget) do
		m.beltSorterRefreshGui(player,target)
	end
end

---------------------------------------------------
-- gui actions
---------------------------------------------------

gui["belt-sorter-advanced"]={}
gui["belt-sorter-advanced"].open = function(player,entity)
	local frame = player.gui.left.add{type="frame",name="beltSorterGui",direction="vertical",caption={"belt-sorter-title"}}
	frame.add{type="label",name="description",caption={"belt-sorter-advanced-description"}}	
	frame.add{type="table",name="table",colspan=5}	

	local labels={"up","left","right","down"}
	for i,label in pairs(labels) do
		frame.table.add{type="label",name="title"..i,caption={"",{label},":"}}
		for j=1,guiSlotsAvailable do
			frame.table.add{type="sprite-button",name="beltSorter.slot."..i.."."..j,style="slot_button_style",sprite=""}
			local sides = frame.table.add{type="table",name="sides."..i.."."..j,colspan=1}
			local caption = {"left","right"}
			for side = 1,2 do
				sides.add{type="checkbox",name="beltSorter.side."..i.."."..j.."."..side,caption={caption[side]},state=false}
			end
		end
	end
	frame.add{type="table",name="settings",colspan=2}
	frame.settings.add{type="button",name="beltSorter.copy",caption={"copy"}}
	frame.settings.add{type="button",name="beltSorter.paste",caption={"paste"}}
	m.beltSorterRefreshGui(player,entity)
end

gui["belt-sorter-advanced"].close = function(player)
	if player.gui.left.beltSorterGui then
		player.gui.left.beltSorterGui.destroy()
	end
	itemSelection_close(player)
end

gui["belt-sorter-advanced"].click = function(nameArr,player,entity)
	local fieldName = table.remove(nameArr,1)
	if fieldName == "slot" then
		local box = player.gui.left.beltSorterGui.table["beltSorter.slot."..nameArr[1].."."..nameArr[2]]
		if box.sprite == "" then
			itemSelection_open(player,function(itemName)
				m.beltSorterSetSlotFilter(entity,nameArr,itemName,{true,true})
				m.beltSorterRefreshGui(player,entity)
			end)
		else
			m.beltSorterSetSlotFilter(entity,nameArr,nil,nil)
			m.beltSorterRefreshGui(player,entity)
		end
	elseif fieldName == "side" then
		local data = global.entityData[idOfEntity(entity)]
		local key = nameArr[1].."."..nameArr[2]..".sides"
		if not data.guiFilter[key] then data.guiFilter[key] = {} end
		local side = tonumber(nameArr[3])
		data.guiFilter[key][side] = not data.guiFilter[key][side]
		m.beltSorterRebuildFilterFromGui(data)
		m.beltSorterRefreshGui(player,entity)
	elseif fieldName == "copy" then
		if global.gui.playerData[player.name] == nil then global.gui.playerData[player.name] = {} end
		local data = global.entityData[idOfEntity(entity)]
		global.gui.playerData[player.name].beltSorterGuiCopy = deepcopy(data.guiFilter)
	elseif fieldName == "paste" then
		local playerData = global.gui.playerData[player.name]
		if playerData ~= nil and playerData.beltSorterGuiCopy ~= nil then
			local data = global.entityData[idOfEntity(entity)]
			data.guiFilter = playerData.beltSorterGuiCopy
			m.beltSorterRefreshGui(player,entity)
			m.beltSorterRebuildFilterFromGui(data)
		end
--	else --may happen if you click a table or some button which is not defined yet
--		info("unknown gui clicked: "..nameArr)
	end
end

m.beltSorterRefreshGui = function(player,entity)
	local data = global.entityData[idOfEntity(entity)]
	if not data then
		err("no data found for beltSorter "..idOfEntity(entity)..". Remove it and place it again!")
		gui["belt-sorter-advanced"].close(player)
		return
	end
	if data.guiFilter == nil then return end
	local frame = player.gui.left.beltSorterGui
	for row = 1,4 do
		for slot = 1,guiSlotsAvailable do
			local itemName = data.guiFilter[row.."."..slot]
			local element = frame.table["beltSorter.slot."..row.."."..slot]
			if itemName then
				local tip = game.item_prototypes[itemName].localised_name
				element.sprite = "item/"..itemName
				element.tooltip = tip
			else
				element.sprite = ""
				element.tooltip = ""
			end
			for side = 1,2 do
				element = frame.table["sides."..row.."."..slot]["beltSorter.side."..row.."."..slot.."."..side]
				local sideFilter = data.guiFilter[row.."."..slot..".sides"]
				if sideFilter and sideFilter[side] then
					element.state = true
				else
					element.state = false
				end
			end
		end
	end
end

---------------------------------------------------
-- data handling
---------------------------------------------------

m.beltSorterSetSlotFilter = function(entity,nameArr,itemName,sides)
	local data = global.entityData[idOfEntity(entity)]
	if data.guiFilter == nil then data.guiFilter = {} end
	data.guiFilter[nameArr[1].."."..nameArr[2]] = itemName
	data.guiFilter[nameArr[1].."."..nameArr[2]..".sides"] = sides
	m.beltSorterRebuildFilterFromGui(data)
end

m.beltSorterRebuildFilterFromGui = function(data)
	data.filter = {}
	for row = 1,4 do
		for slot = 1,guiSlotsAvailable do
			local itemName = data.guiFilter[row.."."..slot]
			if itemName then
				if data.filter[itemName] == nil then data.filter[itemName] = {} end
				local sides = data.guiFilter[row.."."..slot..".sides"]
				data.filter[itemName][row] = sides
			end
		end
	end
	info(data.filter)
	m.storeConfigToCombinator(data)
end

m.storeConfigToCombinator = function(data)
	local behavior = data.config.get_or_create_control_behavior()
	local param = behavior.parameters
	for row = 1,4 do
		for slot = 1,guiSlotsAvailable do
			local index = (row-1)*guiSlotsAvailable + slot
			local sides = data.guiFilter[row.."."..slot..".sides"]
			local slotConfig = { count = 0, index = index, signal = {type="item"}}
			slotConfig.signal.name = data.guiFilter[row.."."..slot]
			if sides then
				slotConfig.count = (sides[1] and 1 or 0) + (sides[2] and 2 or 0)
			end
			param.parameters[index] = slotConfig
		end
	end
	behavior.parameters = param
end

m.loadFilterFromConfig = function(data)
	local params = data.config.get_or_create_control_behavior().parameters.parameters
	info(params)
	if not data.guiFilter then data.guiFilter = {} end
	for row = 1,4 do
		for slot = 1,guiSlotsAvailable do
			local index = (row-1)*guiSlotsAvailable + slot
			if params[index].signal.name then
				data.guiFilter[row.."."..slot] = params[index].signal.name
				info(tostring(index).." "..tostring(params[index].signal.name))
				local count = params[index].count
				if params[index].signal.name == nil then
					count = 0
				end
				data.guiFilter[row.."."..slot..".sides"] = { bit.band(count,1)>0, bit.band(count,2)>0}
				info(data.guiFilter[row.."."..slot..".sides"])
			end
		end
	end
	m.beltSorterRebuildFilterFromGui(data)
end

---------------------------------------------------
-- update tick
---------------------------------------------------

beltSorter.tick = function(beltSorter,data)
	if not data then
		err("Error occured with beltSorter: "..idOfEntity(beltSorter))
		return 0,nil
	end
	if data.condition == nil or data.nextConditionUpdate == nil or data.nextConditionUpdate <= game.tick then
		m.beltSorterUpdateCircuitCondition(beltSorter,data)
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
		m.beltSorterSearchInputOutput(beltSorter,data)
		m.beltSorterDistributeItems(beltSorter,data)
		data.input = nil
		data.output = nil
	end
	return nextUpdate,nil
end

m.beltSorterUpdateCircuitCondition = function(beltSorter,data)
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

m.beltSorterDistributeItems = function(beltSorter,data)
	-- Search for input (only loop if items available), mostly only 1 input
	for inputSide,inputAccess in pairs(data.input) do
		if not inputAccess:isValid() then
			data.input[inputSide] = nil
		else
			for itemName,_ in pairs(inputAccess:get_contents()) do
				local sideList = data.filter[itemName]
				if sideList then
					m.distributeItemToSides(data,inputAccess,itemName,sideList)
				else -- item can go nowhere, check rest filter
					sideList = data.filter["belt-sorter-everythingelse"]
					if sideList then
						m.distributeItemToSides(data,inputAccess,itemName,sideList)
					end
				end
			end
		end
	end
end


m.distributeItemToSides = function(data,inputAccess,itemName,sideList)
	local itemStack = {name=itemName,count=1}
	for side,outputOnLanes in pairs(sideList) do
		local outputAccess = data.output[side]
		if outputAccess then
			if not outputAccess:isValid() then
				data.output[side] = nil
			else
				m.insertAsManyAsPossible(inputAccess,outputAccess,itemStack,outputOnLanes)
			end
		end
	end
end

m.insertAsManyAsPossible = function(inputAccess,outputAccess,itemStack,outputOnLanes)
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

m.beltSorterSearchInputOutput = function(beltSorter,data)
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
