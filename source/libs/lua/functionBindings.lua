
function bind3(func,arg3)
	return function(arg1,arg2)
		return func(arg1,arg2,arg3)
	end
end


function bind34(func,arg3,arg4)
	return function(arg1,arg2)
		return func(arg1,arg2,arg3,arg4)
	end
end