function table.numericAddTable(t,t2, factor, initial)
	if factor == nil then factor = 1 end
	if initial == nil then initial = 0 end
	for k,value in pairs(t2) do
		if t[k] == nil then t[k] = initial end
		t[k] = t[k] + factor * value
		if t[k] == 0 then t[k] = nil end
	end
end


function table.addTable(t,toAdd)
	if toAdd then
		for k,v in pairs(toAdd) do t[k] = v end
	end
end

function table.set(t) -- set of list
  local s = { }
  for _, v in ipairs(t) do s[v] = true end
  return s
end

function table.clear(t)
	local count = #t
	for i=0, count do t[i]=nil end
end

function table.contains(table,value)
	if table == nil then return false end
	for k,v in pairs(table) do
		if v == value then return true end	
	end
	return false
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end