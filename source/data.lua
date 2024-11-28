require("libs.all")
require("prototypes.belt-sorter-prototypes")

--BS1
BeltSorterItemPrototype(1)
BeltSorterPrototype(1, 25020) --power, dividable by 60 (to show round numbers)
BeltSorterRecipePrototype(1, {
    { type = "item", name = "steel-chest",        amount = 1 },
    { type = "item", name = "steel-plate",        amount = 5 },
    { type = "item", name = "electronic-circuit", amount = 4 }
})
BeltSorterTechPrototype(1, { "electronics", "logistics" }, 50, { { "automation-science-pack", 3 } })

--BS2
BeltSorterItemPrototype(2)
BeltSorterPrototype(2, 50040)
BeltSorterRecipePrototype(2, {
    { type = "item", name = "belt-sorter1",     amount = 1 },
    { type = "item", name = "advanced-circuit", amount = 4 }
})
BeltSorterTechPrototype(2, { "belt-sorter1", "advanced-circuit", "logistics-2" }, 20,
    { { "automation-science-pack", 2 }, { "logistic-science-pack", 5 } })

--BS3
BeltSorterItemPrototype(3)
BeltSorterPrototype(3, 100020)
BeltSorterRecipePrototype(3, {
    { type = "item", name = "belt-sorter2",    amount = 1 },
    { type = "item", name = "processing-unit", amount = 4 }
})
BeltSorterTechPrototype(3,
    { "belt-sorter2", "processing-unit", "logistics-3" },
    60,
    { { "automation-science-pack", 1 }, { "logistic-science-pack", 2 }, { "production-science-pack", 1 } })


require("prototypes.everything-else-filter-item")
require("prototypes.belt-sorter-config-combinator")
