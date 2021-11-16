require "libs.migrations.util"

for i, force in pairs(game.forces) do
  force.reset_technologies()
  force.reset_recipes()

  migrateAdd(force,"k-advanced-logistics","belt-sorter4")

  -- if a recipe is unlocked only by one tech:
  --migrateCheck(force, "logistics-2", "fast-long-inserter")
  -- if a recipe is unlocked by multiple techs: (does not disable recipe if no tech is researched)
  --migrateAdd(force, "logistics-2", "fast-long-inserter")

end