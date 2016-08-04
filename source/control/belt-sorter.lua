require "libs.classes.BeltFactory"
require "libs.itemSelection.control"

-- Registering entity into system
local beltSorter = {}
entities["belt-sorter-v2"] = beltSorter

-- Constants
local searchPriority = {{0,-1},{-1,0},{1,0},{0,1}}
local rowIndexToDirection = {
	[1]=defines.direction.north,
	[2]=defines.direction.west,
	[3]=defines.direction.east,
	[4]=defines.direction.south
}

---------------------------------------------------
-- entityData
---------------------------------------------------

-- Used data:
-- {
--   lamp = LuaEntity(fake lamp)
--   filter[$itemName] = { $row1, $row2, ... }
--   guiFilter[$row.."."..$slot] = $itemName
--   nextSearchDir = $index (which direction to search next)
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

	local pos = {x = entity.position.x, y=entity.position.y}
	
	local lamp = entity.surface.create_entity({name="belt-sorter-lamp",position=pos,force=entity.force})
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

	return {
		lamp = lamp,
		filter = {}
	}
end

beltSorter.remove = function(data)
	if data.lamp and data.lamp.valid then
		data.lamp.destroy()
	end
end

beltSorter.copy = function(source,srcData,target,targetData)
	targetData.guiFilter = deepcopy(srcData.guiFilter)
	beltSorterRebuildFilterFromGui(targetData)
	local playerWithGuiOfTarget = gui_playersWithOpenGuiOf(target)
	for _,player in pairs(playerWithGuiOfTarget) do
		beltSorterRefreshGui(player,target)
	end
end

---------------------------------------------------
-- gui actions
---------------------------------------------------

gui["belt-sorter-v2"]={}
gui["belt-sorter-v2"].open = function(player,entity)
	local frame = player.gui.left.add{type="frame",name="beltSorterGui",direction="vertical",caption={"belt-sorter-title"}}	
	frame.add{type="table",name="table",colspan=5}	

	local labels={"north","west","east","south"}
	for i,label in pairs(labels) do
		frame.table.add{type="label",name="title"..i,caption={"",{label},":"}}
		for j=1,4 do
			frame.table.add{type="sprite-button",name="beltSorter.slot."..i.."."..j,style="slot_button_style",sprite=""}
		end
	end
	frame.add{type="table",name="settings",colspan=2}
	frame.settings.add{type="button",name="beltSorter.copy",caption={"copy"}}
	frame.settings.add{type="button",name="beltSorter.paste",caption={"paste"}}
	beltSorterRefreshGui(player,entity)
end

gui["belt-sorter-v2"].close = function(player)
	if player.gui.left.beltSorterGui then
		player.gui.left.beltSorterGui.destroy()
	end
	itemSelection_close(player)
end

gui["belt-sorter-v2"].click = function(nameArr,player,entity)
	local fieldName = table.remove(nameArr,1)
	if fieldName == "slot" then
		local box = player.gui.left.beltSorterGui.table["beltSorter.slot."..nameArr[1].."."..nameArr[2]]
		if box.sprite == "" then
			itemSelection_open(player,function(itemName)
				local tip = game.item_prototypes[itemName].localised_name
				box.sprite = "item/"..itemName
				box.tooltip = tip
				beltSorterSetSlotFilter(entity,nameArr,itemName)
			end)
		else
			box.sprite = ""
			box.tooltip = ""
			beltSorterSetSlotFilter(entity,nameArr,nil)
		end
	elseif fieldName == "copy" then
		if global.gui.playerData[player.name] == nil then global.gui.playerData[player.name] = {} end
		local data = global.entityData[idOfEntity(entity)]
		global.gui.playerData[player.name].beltSorterGuiCopy = deepcopy(data.guiFilter)
	elseif fieldName == "paste" then
		local playerData = global.gui.playerData[player.name]
		if playerData ~= nil and playerData.beltSorterGuiCopy ~= nil then
			local data = global.entityData[idOfEntity(entity)]
			data.guiFilter = playerData.beltSorterGuiCopy
			beltSorterRefreshGui(player,entity)
			beltSorterRebuildFilterFromGui(data)
		end
	end
end

function beltSorterRefreshGui(player,entity)
	local data = global.entityData[idOfEntity(entity)]
	if data.guiFilter == nil then return end
	for row = 1,4 do
		for slot = 1,4 do
			local itemName = data.guiFilter[row.."."..slot]
			local element = player.gui.left.beltSorterGui.table["beltSorter.slot."..row.."."..slot]
			
			if itemName then
				local tip = game.item_prototypes[itemName].localised_name
				element.sprite = "item/"..itemName
				element.tooltip = tip
			else
				element.sprite = ""
				element.tooltip = ""
			end
		end
	end
end

function beltSorterSetSlotFilter(entity,nameArr,itemName)
	local data = global.entityData[idOfEntity(entity)]
	if data.guiFilter == nil then data.guiFilter = {} end
	data.guiFilter[nameArr[1].."."..nameArr[2]] = itemName
	beltSorterRebuildFilterFromGui(data)
end

function beltSorterRebuildFilterFromGui(data)
	data.filter = {}
	for row = 1,4 do
		for slot = 1,4 do
			local itemName = data.guiFilter[row.."."..slot]
			if itemName then
				if data.filter[itemName] == nil then data.filter[itemName] = {} end
				table.insert(data.filter[itemName],row)
			end
		end
	end
end

---------------------------------------------------
-- update tick
---------------------------------------------------

beltSorter.tick = function(beltSorter,data)
	if data.condition == nil or data.nextConditionUpdate == nil or data.nextConditionUpdate <= game.tick then
		beltSorterUpdateCircuitCondition(beltSorter,data)
		if data.condition == false then
			return 60,nil
		end
	end

	local energyPercentage = math.min(beltSorter.energy,800) / 800
	local nextUpdate
	if energyPercentage < 0.1 then
		nextUpdate = 80
	else
		nextUpdate = math.floor(8 / energyPercentage)
		beltSorterSearchInputOutput(beltSorter,data)
		beltSorterDistributeItems(beltSorter,data)
		data.input = nil
		data.output = nil
	end
	return nextUpdate,nil
end

function beltSorterUpdateCircuitCondition(beltSorter,data)
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

function beltSorterDistributeItems(beltSorter,data)
	-- Search for input (only loop if items available), mostly only 1 input
	for inputSide,inputAccess in pairs(data.input) do
		if not inputAccess:isValid() then
			data.input[inputSide] = nil
		else
			for itemName,_ in pairs(inputAccess:get_contents()) do
				local sideList = data.filter[itemName]
				if sideList then
					for _,side in pairs(sideList) do
						local outputAccess = data.output[side]
						if outputAccess then
							if not outputAccess:isValid() then
								data.output[side] = nil
							else
								if outputAccess:can_insert_at_back() then
									local itemStack = {name=itemName,count=1}
									local result = inputAccess:remove_item(itemStack)
									if result>0 then
										outputAccess:insert_at_back(itemStack)
									else
										break -- check other items
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function beltSorterSearchInputOutput(beltSorter,data)
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
	data.nextSearchDir = nil
end
