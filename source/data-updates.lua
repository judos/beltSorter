require("libs.prototypes.all")
require("prototypes.belt-sorter-prototypes")

--------------------------------------------------------------------- DECLARE TIER 4 & 5 -----------------------------------------------------------------------
local IsBeltSorter4_active = false
local IsBeltSorter5_active = false

local mods_with_4belts = {"one-more-tier", "BetterBelts"}
local mods_with_5belts = {"boblogistics", "UltimateBelts", "Krastorio2", "modmashsplinterlogistics", "5dim_transport", "FactorioExtended-Transport", "FactorioExtended-Plus-Transport", "iper-belt", "Hiladdar_Belts"}

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

local function SwapColorOfSorterTier(tier, destination)
  data.raw.item["belt-sorter" .. tier].icon = "__beltSorter__/graphics/icons/belt-sorter" .. destination .. ".png"
  data.raw.lamp["belt-sorter" .. tier].icon = "__beltSorter__/graphics/icons/belt-sorter" .. destination .. ".png"
  data.raw.lamp["belt-sorter" .. tier].picture_off.layers[1].filename = "__beltSorter__/graphics/entity/hr-belt-sorter-" .. destination .. "-base.png"
  data.raw.lamp["belt-sorter-lamp" .. tier].icon = "__beltSorter__/graphics/icons/belt-sorter" .. destination .. ".png"
  data.raw.technology["belt-sorter" .. tier].icon = "__beltSorter__/graphics/technology/belt-sorter" .. destination .. ".png"
end

----------------------- Hiladdar's Belts -----------------------
if mods["Hiladdar_Belts"] then
  SwapColorOfSorterTier(4, 5)
  SwapColorOfSorterTier(5, 4)
  if data.raw.technology["logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "logistics-4") end
  if data.raw.technology["logistics-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "logistics-5") end
end

----------------------- One More Tier -----------------------
if mods["one-more-tier"] then
  if data.raw.technology["omt-logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "omt-logistics-4") end
end

----------------------- Better Belts -----------------------
if mods["BetterBelts"] then
  SwapColorOfSorterTier(4, 5)
  if data.raw.technology["BetterBelts_ultra-class"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "BetterBelts_ultra-class") end
end

----------------------- FactorioExtended -----------------------
if mods["FactorioExtended-Transport"] then
  SwapColorOfSorterTier(4, 5)
  SwapColorOfSorterTier(5, 4)
  if data.raw.technology["stainless-steel-tech"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "stainless-steel-tech") end
  if data.raw.technology["titanium-tech"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "titanium-tech") end
end

----------------------- FactorioExtended Plus -----------------------
if mods["FactorioExtended-Plus-Transport"] then
  SwapColorOfSorterTier(4, 5)
  SwapColorOfSorterTier(5, 4)
  if data.raw.technology["logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "logistics-4") end
  if data.raw.technology["logistics-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "logistics-5") end
  for i=4,5 do
    data.raw.item["belt-sorter" .. i].subgroup = "fb-transport"
  end
end

----------------------- Bob's Logistics ----------------------
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
  SwapColorOfSorterTier(4, 5)
  SwapColorOfSorterTier(5, 4)

  if data.raw.technology["kr-logistic-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "kr-logistic-4") end
  if data.raw.technology["kr-logistic-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "kr-logistic-5") end
end

----------------------- Mod Mash ----------------------
if mods["modmashsplinterlogistics"] then
  SwapColorOfSorterTier(4, 5)
  SwapColorOfSorterTier(5, 4)

  if data.raw.technology["logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "logistics-4") end
  if data.raw.technology["logistics-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "logistics-5") end
end

----------------------- 5Dim ----------------------
if mods["5dim_transport"] then
  data:extend({
    {
      type = "item-subgroup",
      name = "5d-belt-sorters",
      group = "transport",
      order = "e1",
    }
  })

  for i=1,5 do
    data.raw.item["belt-sorter" .. i].subgroup = "5d-belt-sorters"
  end

  if data.raw.technology["logistics-4"] then table.insert(data.raw.technology["belt-sorter4"].prerequisites, "logistics-4") end
  if data.raw.technology["logistics-5"] then table.insert(data.raw.technology["belt-sorter5"].prerequisites, "logistics-5") end
end
