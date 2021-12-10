require("libs.all")
require("prototypes.belt-sorter-prototypes")

--BS1
BeltSorterItemPrototype(1)
BeltSorterPrototype(1, 25020) --power, dividable by 60 (to show round numbers)
BeltSorterRecipePrototype(1, {
  {"steel-chest", 1},
  {"steel-plate", 5},
  {"electronic-circuit", 4}
})
BeltSorterTechPrototype(1, {"electronics", "logistics"}, 50, { {"automation-science-pack", 3} })

--BS2
BeltSorterItemPrototype(2)
BeltSorterPrototype(2, 50040)
BeltSorterRecipePrototype(2, {
  {"belt-sorter1", 1},
  {"advanced-circuit", 4}
})
BeltSorterTechPrototype(2, {"belt-sorter1", "advanced-electronics", "logistics-2"}, 20, { {"automation-science-pack", 2}, {"logistic-science-pack", 5} })

--BS3
BeltSorterItemPrototype(3)
BeltSorterPrototype(3, 100020)
BeltSorterRecipePrototype(3, {
  {"belt-sorter2", 1},
  {"processing-unit", 4}
})
BeltSorterTechPrototype(3, {"belt-sorter2", "advanced-electronics-2", "logistics-3"}, 60, { {"automation-science-pack", 1}, {"logistic-science-pack", 2}, {"production-science-pack", 1} })


require("prototypes.everything-else-filter-item")
require("prototypes.belt-sorter-config-combinator")
