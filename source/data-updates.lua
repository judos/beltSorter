require("libs.prototypes.all")
require("prototypes.belt-sorter-prototypes")

--------------------------------------------------------------------- DECLARE TIER 4 & 5 -----------------------------------------------------------------------
local IsBeltSorter4_active = false
local IsBeltSorter5_active = false

local mods_with_4belts = {}
local mods_with_5belts = {"boblogistics", "UltimateBelts", "Krastorio2"}

for _,mod in pairs(mods_with_4belts) do
  if mods[mod] then
    IsBeltSorter4_active = true
  end
end

for _,mod in pairs(mods_with_5belts) do
  if mods[mod] then
    IsBeltSorter4_active = true
    IsBeltSorter5_active = true
  end
end

if IsBeltSorter4_active then
  BeltSorterItemPrototype(4)
  BeltSorterPrototype(4, 175020)
  BeltSorterRecipePrototype(4, {
    {"belt-sorter3", 1},
    {"advanced-circuit", 4},
    {"processing-unit", 4}
  })
  BeltSorterTechPrototype(4, {"belt-sorter3"}, 200, { {"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"production-science-pack", 1} })
end

if IsBeltSorter4_active and IsBeltSorter5_active then
  BeltSorterItemPrototype(5)
  BeltSorterPrototype(5, 275040)
  BeltSorterRecipePrototype(5, {
    {"belt-sorter4", 1},
    {"advanced-circuit", 8},
    {"processing-unit", 8}
  })
  BeltSorterTechPrototype(5, {"belt-sorter4"}, 300, { {"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1} })
end

if data.raw.tool["advanced-logistic-science-pack"] then
  bobmods.lib.tech.replace_science_pack("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
  bobmods.lib.tech.replace_prerequisite("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
end

--------------------------------------------------------------------- ADAPT COMPATIBILITY -----------------------------------------------------------------------
----------------------- Bob's Logistics----------------------
if mods["boblogistics"] then
  if data.raw.technology["logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "logistics-4") end
  if data.raw.technology["logistics-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "logistics-5") end


  for i=1,5 do
    data.raw.item["belt-sorter" .. i].subgroup = "bob-logistic-tier-" .. i
    data.raw.item["belt-sorter" .. i].order = "d[belt-sorter]" .. i
  end
end

----------------------- Ultimate Belts ----------------------
if mods["UltimateBelts"] then
  if data.raw.technology["ultra-fast-logistics"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "ultra-fast-logistics") end
  if data.raw.technology["ultra-fast-logistics"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "extreme-fast-logistics") end
end

----------------------- Krastorio 2 ----------------------
if mods["Krastorio2"] then

  --switch graphics: 4=green, 5=purple
  data.raw.item["belt-sorter4"].icon = "__beltSorter__/graphics/icons/belt-sorter5.png"
  data.raw.item["belt-sorter5"].icon = "__beltSorter__/graphics/icons/belt-sorter4.png"

  data.raw.lamp["belt-sorter4"].icon = "__beltSorter__/graphics/icons/belt-sorter5.png"
  data.raw.lamp["belt-sorter5"].icon = "__beltSorter__/graphics/icons/belt-sorter4.png"

  data.raw.lamp["belt-sorter4"].picture_off.layers[1].filename = "__beltSorter__/graphics/entity/hr-belt-sorter-5-base.png"
  data.raw.lamp["belt-sorter5"].picture_off.layers[1].filename = "__beltSorter__/graphics/entity/hr-belt-sorter-4-base.png"

  data.raw.lamp["belt-sorter-lamp4"].icon = "__beltSorter__/graphics/icons/belt-sorter5.png"
  data.raw.lamp["belt-sorter-lamp5"].icon = "__beltSorter__/graphics/icons/belt-sorter4.png"

  data.raw.technology["belt-sorter4"].icon = "__beltSorter__/graphics/technology/belt-sorter5.png"
  data.raw.technology["belt-sorter5"].icon = "__beltSorter__/graphics/technology/belt-sorter4.png"

  if data.raw.technology["kr-logistic-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "kr-logistic-4") end
  if data.raw.technology["kr-logistic-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "kr-logistic-5") end
end

--to add: one-more-tier se/AAI modmash/modmashsplinterlogistics 5dim_transport BetterBelts FactorioExtended-Transport
