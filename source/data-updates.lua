require "libs.prototypes.all"

-- check if compat mods are available
local bobsLogistics = data.raw.item['turbo-transport-belt']~=nil
local ultimateBelts = data.raw.item['ultra-fast-belt']~=nil
local krastorio = data.raw.item['k-transport-belt']~=nil
if bobsLogistics or ultimateBelts or krastorio then

	print("beltSorter: adding support for bobs/ultimate/krastorio belts");	
	
	require "prototypes.belt-sorter-items-bobs"
	require "prototypes.belt-sorter-recipes-bobs"
	require "prototypes.belt-sorter-entities-bobs"
	
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

if data.raw.tool["advanced-logistic-science-pack"] then
  bobmods.lib.tech.replace_science_pack("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
  bobmods.lib.tech.replace_prerequisite("belt-sorter3", "production-science-pack", "advanced-logistic-science-pack")
end