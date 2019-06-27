function iconAddLast(object,iconNew)

	local icon_size = object.icon_size
	if icon_size and (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
		error("ERROR: icon_size that is not 32, 64 or 128: "..object.name)
	end
	if not icon_size then icon_size = 32 end
	
	if object.icon then
		object.icons = { {icon=object.icon}, iconNew }
		object.icon = nil
	elseif object.icons then
		table.insert(object.icons, iconNew)
	else
		error("ERROR: item with no icon or icons properties ("..object.name..")")
	end

end