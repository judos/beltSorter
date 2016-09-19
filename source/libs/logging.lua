beltSorterLog = {}

require "constants"

if beltSorterLog.debug_master == nil then
	beltSorterLog.debug_master = true -- Master switch for debugging, prints debug stuff into the shell where factorio was started from
end
if beltSorterLog.debug_level == nil then
	beltSorterLog.debug_level = 2
end
if beltSorterLog.testing then
	beltSorterLog.debug_master = true -- Master switch for debugging, prints debug stuff into the shell where factorio was started from
	beltSorterLog.debug_level = 1 -- 1=info 2=warning 3=error
	beltSorterLog.always_player_print = true
end

beltSorterLog.stack_trace = true


function info(message)
	if beltSorterLog.debug_level<=1 then beltSorterLog.debug(message,"INFO") end
end
function warn(message)
	if beltSorterLog.debug_level<=2 then beltSorterLog.debug(message,"WARN") end
end
function err(message)
	if beltSorterLog.debug_level<=3 then beltSorterLog.debug(message,"ERROR") end
end

function assert2(value,message)
	assert(value,message.."\n"..debug.traceback())
end

function beltSorterLog.debug(message,level)
	if not level then level="ANY" end
	if beltSorterLog.debug_master then
		if type(message) ~= "string" then
			message = serpent.block(message)
		end
		local data = {
			time = beltSorterLog.gameTime(),
			level = level,
			name = fullModName,
			caller = beltSorterLog.caller(),
			message = message
		}
		--local str = .." [ "..level.." "..fullModName.." ] "..beltSorterLog.caller()..": "..message
		if level == "ERROR" or beltSorterLog.always_player_print then
			beltSorterLog.PlayerPrint(formatWith("[%name - %caller]: %message",data))
		end
		local str = formatWith("%time [ %level %name - %caller]: %message",data)
		if beltSorterLog.stack_trace then
			str = str.."\n"..beltSorterLog.traceback()
		end
		print(str)
	end
end

function beltSorterLog.caller()
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

function beltSorterLog.traceback()
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

function beltSorterLog.gameTime()
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

function beltSorterLog.PlayerPrint(message)
	if not game then
		return
	end
	for _,player in pairs(game.players) do
		player.print(message)
	end
end
