require "constants"

logging = {}


function info(message)
	if settings.global.log_level.value <= 1 then logging.debug(message,"INFO") end
end
function warn(message)
	if settings.global.log_level.value <= 2 then logging.debug(message,"WARN") end
end
function err(message)
	if settings.global.log_level.value <= 3 then logging.debug(message,"ERROR") end
end


function assert2(value,message)
	assert(value, message .. "\n" .. debug.traceback())
end


function x(object)
	return serpent.block(object)
end


function logging.debug(message,level)
	if not settings.global.log_master.value then return end
	if not level then level = "ERROR" end
	if type(message) ~= "string" then
		message = serpent.block(message)
	end
	local data = {
		time = logging.gameTime(),
		level = level,
		name = fullModName,
		caller = logging.caller(),
		message = message
	}
	if game and (level == "ERROR" or settings.global.log_player_logging.value) then
		game.print(formatWith("[%level %name]: %message (in %caller)",data))
	end
	local str = formatWith("%time [%level %name - %caller]: %message",data)
	if settings.global.log_stack_trace.value then
		str = str .. "\n" .. logging.traceback()
	end
	print(str)
end

function logging.caller()
	local s = debug.traceback()
	local lines = split(s, "\n")
	table.remove(lines, 1) -- removes the "Stacktrace:" line
	local file, appendix
	repeat
		local l = table.remove(lines, 1)
		file, appendix = l:match("([^/]+)(.lua:%d+)")
	until file ~= "logging"
	if not file then return s end
	return tostring(file)..tostring(appendix)
end


function logging.traceback()
	local s = debug.traceback()
	local lines = split(s, "\n")
	table.remove(lines, 1) -- removes the "Stacktrace:" line
	local file, appendix, line
	repeat
		line = table.remove(lines, 1)
		file,appendix = line:match("(%a+)(.lua:%d+)")
	until file ~= "logging"
	table.insert(lines, 1, line)
	return table.concat(lines, "\n")
end


function logging.gameTime()
	local tick = 0
	if game then tick = game.tick end
	local s = math.floor(tick / 60)
	local h = math.floor(s / 3600)
	local m = math.floor(s / 60) - h * 60
	local s = s % 60
	if s < 10 then s = "0" .. s end
	if m < 10 then m = "0" .. m end

	return h..":"..m..":"..s
end
