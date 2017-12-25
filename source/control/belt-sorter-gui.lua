
---------------------------------------------------
-- Initialize and register
---------------------------------------------------

beltSorterGui = {
	slotsAvailable = {2,3,4} -- basic/average/advanced version
}

gui["belt-sorter1"]=beltSorterGui
gui["belt-sorter2"]=beltSorterGui
gui["belt-sorter3"]=beltSorterGui

---------------------------------------------------
-- Gui events
---------------------------------------------------

beltSorterGui.open = function(player,entity)
	local lvl = tonumber(entity.name:sub(-1))
	local frame = player.gui.left.add{type="frame",name="beltSorterGui",direction="vertical",caption={"belt-sorter-title"}}
	frame.add{type="label",name="description",caption={"belt-sorter-advanced-description"}}
	local colspans = {3,7,13}	
	frame.add{type="table",name="table",colspan=colspans[lvl], column_count=3}	

	local labels={"up","left","right","down"}
	for i,label in pairs(labels) do
		frame.table.add{type="label",name="title"..i,caption={"",{label},":"}}
		for j=1,beltSorterGui.slotsAvailable[lvl] do
			frame.table.add{type="choose-elem-button",name="beltSorter.slot."..i.."."..j,elem_type="item"}
			if lvl>1 then
				local sides = frame.table.add{type="table",name="sides."..i.."."..j,colspan=1, column_count=3}
				local caption = {"left","right"}
				for side = 1,2 do
					sides.add{type="checkbox",name="beltSorter.side."..i.."."..j.."."..side,caption={caption[side]},state=false}
				end
			end
		end
		if lvl>2 then
			--local prioList = frame.table.add{type="table",name="priority"..i,colspan=4}
			for prio = 1,4 do
				frame.table.add{type="flow",name="flow."..i.."."..prio}
			end
		end
	end
	frame.add{type="table",name="settings",colspan=2, column_count=3}
	frame.settings.add{type="button",name="beltSorter.copy",caption={"copy"}}
	frame.settings.add{type="button",name="beltSorter.paste",caption={"paste"}}
	beltSorterGui.refreshGui(player,entity)
end

beltSorterGui.close = function(player)
	if player.gui.left.beltSorterGui then
		player.gui.left.beltSorterGui.destroy()
	end
end

beltSorterGui.click = function(nameArr,player,entity)
	local data = global.entityData[idOfEntity(entity)]
	local fieldName = table.remove(nameArr,1)
	if fieldName == "slot" then
		local box = player.gui.left.beltSorterGui.table["beltSorter.slot."..nameArr[1].."."..nameArr[2]]
		local itemName = box.elem_value
		local activeBeltLanes = {false,false}
		if data.lvl == 1 then activeBeltLanes = {true,true} end
		beltSorterGui.setSlotFilter(entity,nameArr,itemName,activeBeltLanes)
		beltSorterGui.refreshGui(player,entity)
	elseif fieldName == "side" then
		local key = nameArr[1].."."..nameArr[2]..".sides"
		if not data.guiFilter[key] then data.guiFilter[key] = {} end
		local side = tonumber(nameArr[3])
		data.guiFilter[key][side] = not data.guiFilter[key][side]
		beltSorterGui.rebuildFilterFromGui(data)
		beltSorterGui.refreshGui(player,entity)
	elseif fieldName == "copy" then
		if global.gui.playerData[player.name] == nil then global.gui.playerData[player.name] = {} end
		global.gui.playerData[player.name].beltSorterGuiCopy = deepcopy(data.guiFilter)
	elseif fieldName == "paste" then
		local playerData = global.gui.playerData[player.name]
		if playerData ~= nil and playerData.beltSorterGuiCopy ~= nil then
			beltSorter.replaceFilter(entity,data,playerData.beltSorterGuiCopy)
		end
	elseif fieldName == "prio" then
		beltSorterGui.adjustPriorities(data,tonumber(nameArr[1]),tonumber(nameArr[2]))
		beltSorterGui.refreshGui(player,entity)
		beltSorterGui.rebuildFilterFromGui(data)
	else --may happen if you click a table or some button which is not defined yet
		info("unknown gui clicked: "..fieldName.." arr: "..serpent.block(nameArr))
	end
end

---------------------------------------------------
-- Methods
---------------------------------------------------

beltSorterGui.adjustPriorities = function(data,setRow,newPrio)
	local oldPrio = data.guiFilter[setRow]
	local bigger = (newPrio > oldPrio)
	
	for row = 1,4 do
		local prio = data.guiFilter[row]
		if bigger and prio<=newPrio and prio>oldPrio then
			data.guiFilter[row] = prio-1
		elseif prio>= newPrio and prio<oldPrio then
			data.guiFilter[row] = prio+1
		end
	end
	data.guiFilter[setRow] = newPrio
end


beltSorterGui.refreshGui = function(player,entity)
	local data = global.entityData[idOfEntity(entity)]
	if not data then
		err("no data found for "..entity.name.." id:"..idOfEntity(entity)..". Remove it and place it again!")
		gui[entity.name].close(player)
		return
	end
	if data.guiFilter == nil then return end
	local frame = player.gui.left.beltSorterGui
	for row = 1,4 do
		for slot = 1,beltSorterGui.slotsAvailable[data.lvl] do
			local itemName = data.guiFilter[row.."."..slot]
			local element = frame.table["beltSorter.slot."..row.."."..slot]
			if itemName then
				local tip = game.item_prototypes[itemName].localised_name
				element.elem_value = itemName
				element.tooltip = tip
			else
				element.elem_value = nil
				element.tooltip = ""
			end
			if data.lvl>1 then
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
		if data.lvl>2 then
			for prio = 1,4 do
				local flow = frame.table["flow."..row.."."..prio]
				flow.clear()
				if data.guiFilter[row] == prio then
					flow.add{type="label",caption=prio}
				else
					flow.add{type="button",name="beltSorter.prio."..row.."."..prio,caption=tostring(prio),state=false}
				end
			end
		end
	end
end

---------------------------------------------------
-- data handling
---------------------------------------------------

beltSorterGui.setSlotFilter = function(entity,nameArr,itemName,sides)
	local data = global.entityData[idOfEntity(entity)]
	if data.guiFilter == nil then data.guiFilter = {} end
	data.guiFilter[nameArr[1].."."..nameArr[2]] = itemName
	data.guiFilter[nameArr[1].."."..nameArr[2]..".sides"] = sides
	beltSorterGui.rebuildFilterFromGui(data)
end

beltSorterGui.rebuildFilterFromGui = function(data)
	data.filter = {}
	if not data.guiFilter then return end
	for row = 1,4 do
		data.filter[data.guiFilter[row]] = row
	end
	for prio = 1,4 do
		local row = data.filter[prio]
		for slot = 1,beltSorterGui.slotsAvailable[data.lvl] do
			local itemName = data.guiFilter[row.."."..slot]
			if itemName then
				if data.filter[itemName] == nil then data.filter[itemName] = {} end
				local sides = data.guiFilter[row.."."..slot..".sides"]
				table.insert(data.filter[itemName], {row, sides})
			end
		end
	end
	if data.config then
		beltSorterGui.storeConfigToCombinator(data)
	end
end

beltSorterGui.storeConfigToCombinator = function(data)
	local behavior = data.config.get_or_create_control_behavior()
	local param = behavior.parameters
	for row = 1,4 do
		for slot = 1,beltSorterGui.slotsAvailable[data.lvl] do
			local index = (row-1)*beltSorterGui.slotsAvailable[data.lvl] + slot
			local sides = data.guiFilter[row.."."..slot..".sides"]
			local slotConfig = { count = 0, index = index, signal = {type="item"}}
			slotConfig.signal.name = data.guiFilter[row.."."..slot]
			if sides then
				slotConfig.count = (sides[1] and 1 or 0) + (sides[2] and 2 or 0)
			end
			param.parameters[index] = slotConfig
		end
		param.parameters[16+row] = { 
			index = 16+row, 
			signal = {type="item", name="belt-sorter-everythingelse"}, 
			count = data.guiFilter[row]
		} 
	end
	behavior.parameters = param
end

beltSorterGui.loadFilterFromConfig = function(data)
	local params = data.config.get_or_create_control_behavior().parameters.parameters
	if not data.guiFilter then data.guiFilter = {} end
	for row = 1,4 do
		for slot = 1,beltSorterGui.slotsAvailable[data.lvl] do
			local index = (row-1)*beltSorterGui.slotsAvailable[data.lvl] + slot
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
		if params[row+16] and params[row+16].signal.name then
			info(params[row+16])
			data.guiFilter[row] = params[row+16].count --priority of row
		else
			data.guiFilter[row] = row
		end
	end
	info(data.guiFilter)
	beltSorterGui.rebuildFilterFromGui(data)
end