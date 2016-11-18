libLog = {}

require "constants"

if libLog.debug_master == nil then
	-- Master switch for debugging, prints debug stuff into the shell where factorio was started from
	libLog.debug_master = true
end
if libLog.debug_level == nil then
	libLog.debug_level = 2
end
if libLog.testing then
	-- Master switch for debugging, prints debug stuff into the shell where factorio was started from
	libLog.debug_master = true 
	-- 1=info 2=warning 3=error
	libLog.debug_level = libLog.debug_level or 1
	libLog.always_player_print = true
end

libLog.stack_trace = true


function info(message)
	if libLog.debug_level<=1 then libLog.debug(message,"INFO") end
end
function warn(message)
	if libLog.debug_level<=2 then libLog.debug(message,"WARN") end
end
function err(message)
	if libLog.debug_level<=3 then libLog.debug(message,"ERROR") end
end

function assert2(value,message)
	assert(value,message.."\n"..debug.traceback())
end

function libLog.debug(message,level)
	if not level then level="ANY" end
	if libLog.debug_master then
		if type(message) ~= "string" then
			message = serpent.block(message)
		end
		local data = {
			time = libLog.gameTime(),
			level = level,
			name = fullModName,
			caller = libLog.caller(),
			message = message
		}
		--local str = .." [ "..level.." "..fullModName.." ] "..libLog.caller()..": "..message
		if level == "ERROR" or libLog.always_player_print then
			libLog.PlayerPrint(formatWith("[%name - %caller]: %message",data))
		end
		local str = formatWith("%time [ %level %name - %caller]: %message",data)
		if libLog.stack_trace then
			str = str.."\n"..libLog.traceback()
		end
		print(str)
	end
end

function libLog.caller()
	local s = debug.traceback()
	local lines = split(s,"\n")
	table.remove(lines,1) -- removes the "Stacktrace:" line
	local file,appendix
	repeat
		local l = table.remove(lines,1)
		file,appendix = l:match("([%w_]+)(.lua:%d+)")
	until file ~= "logging"
	if not file then return s end
	return tostring(file)..tostring(appendix)
end

function libLog.traceback()
	local s = debug.traceback()
	local lines = split(s,"\n")
	table.remove(lines,1) -- removes the "Stacktrace:" line
	local file,appendix,line
	repeat
		line = table.remove(lines,1)
		file,appendix = line:match("(%a+)(.lua:%d+)")
	until file ~= "logging"
	table.insert(lines,1,line)
	return table.concat(lines,"\n")
end

function libLog.gameTime()
	local tick = 0
	if game then tick = game.tick end
	local s = math.floor(tick/60)
	local h = math.floor(s/3600)
	local m = math.floor(s/60) - h*60
	local s = s % 60
	if s<10 then s = "0"..s end
	if m<10 then m = "0"..m end

	return h..":"..m..":"..s
end

function libLog.PlayerPrint(message)
	if not game then
		return
	end
	for _,player in pairs(game.players) do
		player.print(message)
	end
end
