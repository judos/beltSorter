-- Helpers
local noPicture = {
  filename = "__beltSorter__/graphics/entity/empty.png",
  width = 1,
  height = 1,
  shift = {0, 0}
}

-- Config entity
local entity = deepcopy(data.raw["constant-combinator"]["constant-combinator"])
overwriteContent(entity,{
  name = "belt-sorter-config-combinator",
  item_slot_count = 21,
  icon = "__beltSorter__/graphics/icons/belt-sorter-config.png",
  minable = {hardness = 10, mining_time = 10, results = {}},
  order = "zzz",
  collision_box = {{0,0}, {0,0}},
  selection_box = {{0,0}, {0,0}},
  flags = {"placeable-neutral", "player-creation", "not-on-map", "placeable-off-grid", "not-repairable"},
  sprites = { north = noPicture, south = noPicture, east = noPicture, west = noPicture }
})
data:extend({entity})

-- Config item (needed to be stored in blueprint)
local item = deepcopy(data.raw["item"]["constant-combinator"])
overwriteContent(item,{
  name = "belt-sorter-config-combinator",
  icon = "__beltSorter__/graphics/icons/belt-sorter-config.png",
  flags = {"hidden"},
  place_result = "belt-sorter-config-combinator"
})
data:extend({item})

