require("libs.lua.numbers")


-- get the value of a nested table by accessing the keys passed as array
function table.getMD(tabl,keyArray)
	local cur = tabl
	for _,key in pairs(keyArray) do
		cur = cur[key]
		if cur == nil then return nil end
	end
	return cur
end

-- set the value of a nested table by accessing the keys passed as array
-- mode:
--   1 = create all missing keys
--   2 = create only last key
--   3 = only overwrite value
function table.setMD(tabl,keyArray,value,mode)
	mode = mode or 1
	if mode <1 or mode>3 or not isint(mode) then
		error("invalid mode passed to setMD function. mode: "..tostring(mode).." keyArray: "..serpent.block(keyArray))
	end
	local cur = tabl
	local nex
	local lastKey = table.remove(keyArray)
	for _,key in pairs(keyArray) do
		if cur[key]==nil then
			if mode==1 then
				cur[key]={}
			else
				return false
			end
		end
		cur = cur[key]
		if cur == nil then return false end
	end
	if mode==3 and cur[lastKey]==nil then return false end
	cur[lastKey] = value
	return true
end