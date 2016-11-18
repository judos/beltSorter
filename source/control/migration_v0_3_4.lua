function migration_v0_3_4()
	for id,data in pairs(global.entityData) do
		local entity = entityOfId(id,"belt-sorter-advanced")
		if entity then
			err("found mismatch entity: "..serpent.block(config.position).." vs "..serpent.block(entity.position))
		else
			warn("belt-sorter not found for config: "..serpent.block(data.config))
		end
	end
	global.beltSorter.version = "0.3.4"
end