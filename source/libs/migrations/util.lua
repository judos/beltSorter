-- Example migration:
--[[
require "libs.migrations.util"
for i, force in pairs(game.forces) do
	force.reset_technologies()
	force.reset_recipes()
	
	migrateAdd(force,"logistics-4","belt-sorter4")
	migrateAdd(force,"logistics-5","belt-sorter5")
	
	-- if a recipe is unlocked only by one tech:
	--migrateCheck(force, "logistics-2", "fast-long-inserter")
	-- if a recipe is unlocked by multiple techs: (does not disable recipe if no tech is researched)
	--migrateAdd(force, "logistics-2", "fast-long-inserter")
end
]]--


-- unlock the recipe if this tech is enabled (recipe may be unlocked by multiple techs)
function migrateAdd(force, technologyName, recipeName)
	if force.technologies[technologyName] ~= nil then
		if force.technologies[technologyName].researched then
			if force.recipes[recipeName] then
				force.recipes[recipeName].enabled = true
			end
		end
	end
end

-- Force the recipe to be equivalent to technology enabled (one-to-one)
local function migrateCheck(force, technologyName, recipeName)
	if force.technologies[technologyName] ~= nil then
		if force.recipes[recipeName] then
			force.recipes[recipeName].enabled = force.technologies[technologyName].researched
		end
	end
end