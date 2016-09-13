log = {}

require "constants"

if log.debug_master == nil then
	log.debug_master = true -- Master switch for debugging, prints debug stuff into the shell where factorio was started from
end
if log.debug_level == nil then
	log.debug_level = 2
end
if log.testing then
	log.debug_master = true -- Master switch for debugging, prints debug stuff into the shell where factorio was started from
	log.debug_level = 1 -- 1=info 2=warning 3=error
	log.always_player_print = true
end

log.stack_trace = true


function info(message)
	if log.debug_level<=1 then log.debug(message,"INFO") end
end
function warn(message)
	if log.debug_level<=2 then log.debug(message,"WARN") end
end
function err(message)
	if log.debug_level<=3 then log.debug(message,"ERROR") end
end

function assert2(value,message)
	assert(value,message.."\n"..debug.traceback())
end

function log.debug(message,level)
	if not level then level="ANY" end
	if log.debug_master then
		if type(message) ~= "string" then
			message = serpent.block(message)
		end
		local data = {
			time = log.gameTime(),
			level = level,
			name = fullModName,
			caller = log.caller(),
			message = message
		}
		--local str = .." [ "..level.." "..fullModName.." ] "..log.caller()..": "..message
		if level == "ERROR" or log.always_player_print then
			log.PlayerPrint(formatWith("[%name - %caller]: %message",data))
		end
		local str = formatWith("%time [ %level %name - %caller]: %message",data)
		if log.stack_trace then
			str = str.."\n"..log.traceback()
		end
		print(str)
	end
end

function log.caller()
	local s = debug.traceback()
	local lines = split(s,"\n")
	table.remove(lines,1) -- removes the "Stacktrace:" line
	local file,appendix
	repeat
		local l = table.remove(lines,1)
		file,appendix = l:match("(%a+)(.lua:%d+)")
	until file ~= "logging"
	return file..appendix
end

function log.traceback()
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

function log.gameTime()
	local s = math.floor(game.tick/60)
	local h = math.floor(s/3600)
	local m = math.floor(s/60) - h*60
	local s = s % 60
	if s<10 then s = "0"..s end
	if m<10 then m = "0"..m end

	return h..":"..m..":"..s
end

function log.PlayerPrint(message)
	if not game then
		_debug(message)
		return
	end
	for _,player in pairs(game.players) do
		player.print(message)
	end
end
