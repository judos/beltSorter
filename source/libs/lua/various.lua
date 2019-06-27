
function overwriteContent(originalTable,newContent,removeRef)
	if originalTable == nil then
		err("could not overwrite content of nil with new content: "..serpent.block(newContent))
		return
	end
	for k,d in pairs(newContent) do
		if d == removeRef then
			originalTable[k]=nil
		else
			originalTable[k]=d
		end
	end
end

function removeAfterSign(str, separator)
	local pos = str:find(separator)
	if pos == nil then return str end
	return str:sub(1,pos-1)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
