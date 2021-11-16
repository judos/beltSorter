require("libs.prototypes.all")

-- check if compat mods are available
local bobsLogistics = data.raw.item['turbo-transport-belt']~=nil
local ultimateBelts = data.raw.item['ultra-fast-belt']~=nil
local krastorio = data.raw.item['k-transport-belt']~=nil
if bobsLogistics or ultimateBelts or krastorio then

  print("beltSorter: adding support for bobs/ultimate/krastorio belts");



data:extend({
  {
    type = "recipe",
    name = "belt-sorter4",
    enabled = false,
    ingredients = {
      {"belt-sorter3", 1},
      {"advanced-circuit", 4},
      {"processing-unit", 4}
    },
    result = "belt-sorter4"
  },
  {
    type = "recipe",
    name = "belt-sorter5",
    enabled = false,
    ingredients = {
      {"belt-sorter4", 1},
      {"advanced-circuit", 8},
      {"processing-unit", 8}
    },
    result = "belt-sorter5"
  }
})

  require("prototypes.belt-sorter-prototypes")

  -- Entity
  local energy = {0,0,0,175020,275040} --W

  for i=4,5 do
    createBeltSorterPrototype(i, energy[i])
    createBeltSorterItemPrototype(i)
  end


  if bobsLogistics then
    addTechnologyUnlocksRecipe("logistics-4","belt-sorter4")
    addTechnologyUnlocksRecipe("logistics-5","belt-sorter5")
  end
  if ultimateBelts then
    addTechnologyUnlocksRecipe("ultra-fast-logistics","belt-sorter4")
    addTechnologyUnlocksRecipe("ultra-fast-logistics","belt-sorter5")
  end
  if krastorio then
    addTechnologyUnlocksRecipe("k-advanced-logistics","belt-sorter4")
  end

end
--to add: one-more-tier se/AAI modmash/modmashsplinterlogistics 5dim_transport BetterBelts FactorioExtended-Transport

if data.raw.tool["advanced-logistic-science-pack"] then
  bobmods.lib.tech.replace_science_pack("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
  bobmods.lib.tech.replace_prerequisite("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
end










