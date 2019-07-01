require "libs.prototypes.all"

-- check if compat mods are available
local bobsLogistics = data.raw.item['turbo-transport-belt']~=nil
local ultimateBelts = data.raw.item['ultra-fast-belt']~=nil
if bobsLogistics or ultimateBelts then

	print("beltSorter: adding support for bobs/ultimate belts");	
	
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

end