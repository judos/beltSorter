-- Helpers
local noPicture = {
  filename = "__beltSorter__/graphics/entity/empty.png",
  width = 1,
  height = 1,
  shift = {0, 0}
}

-- Config entity
local combinator = deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combinator.name = "belt-sorter-config-combinator"
combinator.item_slot_count = 21
combinator.icon = "__beltSorter__/graphics/icons/belt-sorter-config.png"
combinator.minable = {hardness = 10, mining_time = 10, results = {}}
combinator.order = "zzz"
combinator.collision_box = {{0,0}, {0,0}}
combinator.selection_box = {{0,0}, {0,0}}
combinator.flags = {"placeable-neutral", "player-creation", "not-on-map", "placeable-off-grid", "not-repairable"}
combinator.sprites = { north = noPicture, south = noPicture, east = noPicture, west = noPicture }
data:extend({combinator})

-- Config item (needed to be stored in blueprint)
local combinatorItem = deepcopy(data.raw["item"]["constant-combinator"])
combinatorItem.name = "belt-sorter-config-combinator"
combinatorItem.icon = "__beltSorter__/graphics/icons/belt-sorter-config.png"
combinatorItem.flags = {"hidden"}
combinatorItem.place_result = "belt-sorter-config-combinator"
data:extend({combinatorItem})

