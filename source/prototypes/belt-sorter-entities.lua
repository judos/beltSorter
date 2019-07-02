require "prototypes.belt-sorter-prototypes"

-- Entity
-- 25kW, 50kW, 100kW
-- use rounded up values when dividing by 60 such that an round number shows
--   up in electricity UI.
local energy = {25020,50040, 100020} -- in Watt

for i=1,3 do
	createBeltSorterPrototype(i, energy[i])
end