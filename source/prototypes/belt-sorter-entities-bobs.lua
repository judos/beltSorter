require "prototypes.belt-sorter-prototypes"

-- Entity
local energy = {0,0,0,175020,275040} --W

for i=4,5 do
	createBeltSorterPrototype(i, energy[i])
end