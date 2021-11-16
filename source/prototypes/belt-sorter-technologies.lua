require "libs.prototypes.all"

-- Technology
data:extend({
  {
    type = "technology",
    name = "belt-sorter1",
    icon = "__beltSorter__/graphics/technology/belt-sorter1.png",
    icon_size = 256,
    prerequisites = {"electronics"},
    effects = {},
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 3},
      },
      time = 15
    },
    order = "_belt-sorter1"
  },
  {
    type = "technology",
    name = "belt-sorter2",
    icon = "__beltSorter__/graphics/technology/belt-sorter2.png",
    icon_size = 256,
    prerequisites = {"belt-sorter1", "advanced-electronics"},
    effects = {},
    unit = {
      count = 20,
      ingredients = {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 5},
      },
      time = 15
    },
    order = "_belt-sorter2"
  },
  {
    type = "technology",
    name = "belt-sorter3",
    icon = "__beltSorter__/graphics/technology/belt-sorter3.png",
    icon_size = 256,
    prerequisites = {"belt-sorter2", "advanced-electronics-2", "production-science-pack"},
    effects = {},
    unit = {
      count = 60,
      ingredients = {
      	{"automation-science-pack", 1},
      	{"logistic-science-pack", 2},
      	{"production-science-pack", 1}
      },
      time = 15
    },
    order = "_belt-sorter3"
  }
})

addTechnologyUnlocksRecipe("belt-sorter1","belt-sorter1")
addTechnologyUnlocksRecipe("belt-sorter2","belt-sorter2")
addTechnologyUnlocksRecipe("belt-sorter3","belt-sorter3")