require "libs.classes.BeltFactory"
require "control.belt-sorter-gui"

-- Registering entity into system
local beltSorterEntity = {}
entities["belt-sorter1"] = beltSorterEntity
entities["belt-sorter2"] = beltSorterEntity
entities["belt-sorter3"] = beltSorterEntity
entities["belt-sorter4"] = beltSorterEntity
entities["belt-sorter5"] = beltSorterEntity
beltSorter = {} -- methods of beltSorter

-- Constants
local searchPriority = {{0,-1},{-1,0},{1,0},{0,1}}
local rowIndexToDirection = {
  [1]=defines.direction.north,
  [2]=defines.direction.west,
  [3]=defines.direction.east,
  [4]=defines.direction.south
}
local minimalUpdateTicks = 120
local maxUpdateTicks = {32,16,11,8,6}
local configOffsetY = 0.2


---------------------------------------------------
-- entityData
---------------------------------------------------

-- Used data:
-- {
--   lamp = LuaEntity(fake lamp),
--   config = LuaEntity(fake constant combinator to store settings)
--   filter[$itemName] = { {$int(side), {$bool(putOnLeftLane), $bool(putOnRightLane)}} }
--                       This is an ordered list to support output priority
--   filter[$prio] = $rowIndex
--   guiFilter[$row.."."..$slot] = $itemName
--            [$row.."."..$slot..".sides"] = { $bool, $bool } (on which belt lane should itmes go)
--            [$row] = $prio
--            ['splitter'] = $bool (split items instead of prioritize)
--   lvl = $number (1=basic,2=average,3=advanced)
--   condition = $bool (whether circuit condition allows entity to work
--   nextConditionUpdate = int(tick) (when next check of circuit condition is done)
-- }

--------------------------------------------------
-- Global data
--------------------------------------------------

-- This helper file uses the following global data variables:
-- global.gui.playerData[$playerName].beltSorterGuiCopy = $guiFilter

--------------------------------------------------
-- Migration
--------------------------------------------------

---------------------------------------------------
-- build and remove
---------------------------------------------------

beltSorterEntity.build = function(entity)
  scheduleAdd(entity, TICK_ASAP)
  local data = {
    lvl = tonumber(entity.name:sub(-1))
  }

  local pos = entity.position
  local lamp = entity.surface.create_entity({name="belt-sorter-lamp"..data.lvl,position=pos,force=entity.force})
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

  local config = beltSorter.findConfigGhost(pos,entity)
  if config then
    _,data.config = config.revive()
    beltSorterGui.loadFilterFromConfig(data)
  else
    beltSorter.createConfig(data,entity)
  end

  overwriteContent(data,{
    config = data.config,
    lamp = lamp,
    filter = data.filter or {
      [1]=1,[2]=2,[3]=3,[4]=4
    },
    guiFilter = data.guiFilter or {
      [1]=1,[2]=2,[3]=3,[4]=4
    },
  })
  return data
end

beltSorterEntity.move = function(entity,data,player,start_pos)
  data.lamp.teleport(entity.position)
  data.config.teleport({entity.position.x,entity.position.y+configOffsetY})
end

beltSorter.findConfigGhost = function(pos,entity)
  local entitiesFound = entity.surface.find_entities_filtered{
    area={{pos.x-0.5,pos.y-0.5},{pos.x+0.5,pos.y+0.5}},
    name="entity-ghost",
    force=entity.force
  }
  local config = nil
  for i = 1,#entitiesFound do
    if entitiesFound[i].ghost_name == "belt-sorter-config-combinator" then
      return entitiesFound[i]
    end
  end
  info("no config ghost found when building the beltSorter")
end

beltSorter.createConfig = function(data,entity)
  data.config = entity.surface.create_entity({
    name = "belt-sorter-config-combinator",
    position = {entity.position.x,entity.position.y+configOffsetY},
    force = entity.force
  })
  data.config.operable = false
  data.config.minable = false
  data.config.destructible = false
end

beltSorterEntity.remove = function(data)
  if data.config and data.config.valid then
    local ghost = data.config.surface.create_entity{name="entity-ghost",inner_name="belt-sorter-config-combinator",expires=false,position=data.config.position,force=data.config.force}
    ghost.get_or_create_control_behavior().parameters = data.config.get_control_behavior().parameters
    data.config.destroy()
    entities_build({created_entity = ghost})
  end
  if data.lamp and data.lamp.valid then
    data.lamp.destroy()
  end
end

beltSorterEntity.copy = function(source,srcData,target,targetData)
  if not target.name:sub(1,11) == "belt-sorter" then
    return
  end
  beltSorter.replaceFilter(target,targetData,srcData.guiFilter)
end

beltSorter.replaceFilter = function(entity,data,newGuiFilter)
  data.guiFilter = deepcopy(newGuiFilter)
  beltSorter.sanityCheckFilter(data)
  info("Copy entity data. filter after sanity checks: "..serpent.block(data.guiFilter))

  beltSorterGui.rebuildFilterFromGui(data)
  local playersWithGuiOfTarget = gui_playersWithOpenGuiOf(entity)
  for _,player in pairs(playersWithGuiOfTarget) do
    beltSorterGui.refreshGui(player,entity)
  end
end

beltSorter.sanityCheckFilter = function(data)
  if data.lvl < 2 then
    for side=1,4 do
      for slot=1,beltSorterGui.slotsAvailable[1] do
        if data.guiFilter[side.."."..slot] then
          data.guiFilter[side.."."..slot..".sides"] = {true,true}
        end
      end
    end
  end
  if data.lvl < 3 then
    -- remove priorization for lower tier beltSorters
    for side=1,4 do
      data.guiFilter[side] = side
    end
  end
end


beltSorterEntity.tick = function(entity,data)
  if not data then
    err("Error occured with beltSorter: "..idOfEntity(entity))
    return 0,nil
  end
  if data.condition == nil or data.nextConditionUpdate == nil or data.nextConditionUpdate <= game.tick then
    beltSorter.updateCircuitCondition(entity,data)
    if data.condition == false then
      return minimalUpdateTicks,nil
    end
  end

  -- Max energy stored (for 1 tick, e.g. 417J for belt-sorter1)
  local maxEnergy = game.entity_prototypes['belt-sorter'..data.lvl].max_energy_usage
  -- entity.energy is usually 6.666% more than used for 1 tick (factorio 0.17.52)
  -- but that's ok, beltSorter will still run with 100% speed at 93% of energy provided
  local energyPercentage = 1
  if settings.startup['beltSorter-usePower'].value then
    energyPercentage = math.min(entity.energy,maxEnergy) / maxEnergy
  end
  local nextUpdate= math.floor(maxUpdateTicks[data.lvl] / energyPercentage)

  if nextUpdate>minimalUpdateTicks then
    nextUpdate = minimalUpdateTicks
  else
    beltSorter.searchInputOutput(entity,data)
    beltSorter.distributeItems(entity,data)
    data.input = nil
    data.output = nil
  end
  return nextUpdate,nil
end


---------------------------------------------------
-- Helper methods
---------------------------------------------------


beltSorter.updateCircuitCondition = function(beltSorter,data)
  -- check circuit
  local behavior = beltSorter.get_or_create_control_behavior()
  local conditionTable = behavior.circuit_condition
  -- this boolean is set if condition would normally evaluate to false
  -- (empty filter) but the beltSorter should be working by default.
  local lampOverlay = false
  if conditionTable.condition.first_signal.name ~= nil then
    data.condition = conditionTable.fulfilled
  else
    data.condition = true
    lampOverlay = true
  end

  -- check logistic condition
  if data.condition and behavior.connect_to_logistic_network then
    conditionTable = behavior.logistic_condition
    if conditionTable.condition.first_signal.name ~= nil then
      data.condition = conditionTable.fulfilled
    else
      data.condition = true
      lampOverlay = true
    end
  end

  local lampCondition = {
    condition = {
      comparator= (lampOverlay and "=" or ">"),
      first_signal={type="item", name="iron-plate"},
      second_signal={type="item", name="iron-plate"}
    }
  }
  data.lamp.get_control_behavior().circuit_condition = lampCondition
  data.nextConditionUpdate = game.tick + 60
end

beltSorter.distributeItems = function(entity,data)
  -- Search for input (only loop if items available), mostly only 1 input
  for prio = 1,4 do
    local inputSide = data.filter[prio]
    local inputAccess = data.input[inputSide]
    if not inputAccess or not inputAccess:isValid() then
      data.input[inputSide] = nil
    else
      for itemName,amount in pairs(inputAccess:get_contents()) do
        local sideList = data.filter[itemName]
        if sideList then
          beltSorter.distributeItemToSides(data,inputAccess,itemName,sideList,amount)
        else -- item can go nowhere, check rest filter
          sideList = data.filter["belt-sorter-everythingelse"]
          if sideList then
            beltSorter.distributeItemToSides(data,inputAccess,itemName,sideList,amount)
          end
        end
      end
    end
  end
end


beltSorter.distributeItemToSides = function(data,inputAccess,itemName,sideList,amount)
  local itemStack = {name=itemName,count=1}
  local validSides = 0
  for key,arr in pairs(sideList) do
    local side = arr[1]
    local outputAccess = data.output[side]
    local outputOnLanes = arr[2]
    if (not outputAccess) or (not outputAccess:isValid()) or
       (outputOnLanes[1]==false and outputOnLanes[2]==false) then
      data.output[side] = nil
      sideList[key] = nil
    else
      validSides = validSides + 1
    end
  end
  local perSide = {amount, amount, amount, amount}
  local excessItems = 0 -- 8 items, 3 sides -> perSide = 2, another 2 items distributed randomly
  if data.guiFilter['splitter'] then
    perSide = beltSorter.distributeEvenlyToSides(sideList, amount, validSides)
  end
  for _,arr in pairs(sideList) do
    local side = arr[1]
    local outputOnLanes = arr[2]
    local outputAccess = data.output[side]
    beltSorter.insertItemsFromTo(inputAccess,outputAccess,itemStack,outputOnLanes, perSide[side])
  end
end

beltSorter.distributeEvenlyToSides = function(sideList, amount, validSides)
  local x = math.floor(amount / validSides)
  perSide = {x,x,x,x}
  excess = amount % validSides
  while excess > 0 do
    local index = math.random(1, 4)
    if sideList[index] then
      local sideArr = sideList[index]
      local side = sideArr[1]
      perSide[side] = perSide[side] + 1
      excess = excess - 1
    end
  end
  return perSide
end

beltSorter.insertItemsFromTo = function(inputAccess,outputAccess,itemStack,outputOnLanes, insert)
  local curPos = 0
  while curPos <= 1 do
    if outputOnLanes[1] and outputAccess:can_insert_on_at(false,curPos) then
      local result = inputAccess:remove_item(itemStack)
      if result == 0 then  return end
      outputAccess:insert_on_at(false,curPos,itemStack)
      insert = insert - 1
      if insert == 0 then return end
    end
    if outputOnLanes[2] and outputAccess:can_insert_on_at(true,curPos) then
      local result = inputAccess:remove_item(itemStack)
      if result == 0 then  return end
      outputAccess:insert_on_at(true,curPos,itemStack)
      insert = insert - 1
      if insert == 0 then return end
    end
    curPos = curPos + 0.2815
  end

end

beltSorter.searchInputOutput = function(beltSorter,data)
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
        if not entity.to_be_deconstructed(entity.force) then
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
end
