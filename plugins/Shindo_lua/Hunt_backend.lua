local dir = ""
local Target = ""
local attempt = 0
local HuntType = 0 -- 0 off, 1 hunt, 2 hunt trick

-- Colour Stuff
local ansi = "\27["
local dred = "\27[0;31m"
local dgreen = "\27[0;32m"
local dyellow = "\27[0;33m"
local dblue = "\27[0;34m"
local dmagenta = "\27[0;35m"
local dcyan = "\27[0;36m"
local dwhite = "\27[0;37m"
local bred = "\27[31;1m"
local bgreen = "\27[32;1m"
local byellow = "\27[33;1m"
local bblue = "\27[34;1m"
local bmagenta = "\27[35;1m"
local bcyan = "\27[36;1m"
local bwhite = "\27[37;1m"

function split(line, delim)
	local result = {}
	local index = 1
	for token in string.gmatch(line, delim) do
		result[index] = token
		index = index + 1
	end
	return result
end

function openDoor()
	SendToServer("open "..dir)
end

function startHunt(mob)
	Note("\nAuto hunt engaged.\n")
	enableTriggers(true)
	Target = string.lower(mob)
	dir = ""
	HuntType = 1
	SendToServer("hunt "..Target)
	return true
end

function startHT(mob)
	Note(string.format("\n%sAuto-hunt-trick engaged: %s%s%s.%s\n", dgreen, bgreen, mob, dgreen, dwhite))
	enableTriggers(true)
	HuntType = 2
	start_pos = mob:find("%.")
	if(not start_pos) then
		Target = string.lower(mob)
		attempt = 1
	else
		Note(string.format("Start pos: %s\n", start_pos))
		Target = string.lower(mob:sub(start_pos+1))
		attempt = mob:sub(0,start_pos-1)
		Note(string.format("pulled out %s pos: %s\n", Target, attempt))
	end
	SendToServer("hunt "..attempt.."."..Target)
	return true
end

function advanceHuntandHT(name,line,replaceMap)
	if (HuntType == 1) then
		dir = replaceMap["1"]
		Note(string.format("Auto hunt advancing: %s \n", dir))
		SendToServer(dir..";hunt "..Target)
	elseif (HuntType == 2) then
		attempt = attempt+1
		SendToServer("hunt "..attempt.."."..Target)
	end
end

function failedHuntAvanceHT()
	if (HuntType == 1) then
		Note("\nAuto hunt obstruction occurred, disabling triggers.\n")
		enableTriggers(false)
		dir = ""
		HuntType = 0
		return true
	elseif (HuntType == 2) then
		attempt = attempt+1
		SendToServer("hunt "..attempt.."."..Target)
	end
end

function failedHuntandHT()
	if (HuntType == 1) then
		Note("\nAuto hunt obstruction occurred, disabling triggers.\n")
		enableTriggers(false)
		dir = ""
		HuntType = 0
		return true
	elseif (HuntType == 2) then
		Note("\nAuto-hunt-trick failed.\n")
		enableTriggers(false)
		HuntType = 0
		return true
	end
end

function failedHuntEndHT()
	if (HuntType == 1) then
		Note(string.format("\n%sAuto hunt obstruction occurred, disabling triggers.%s\n", bred, dwhite))
		enableTriggers(false)
		dir = ""
		HuntType = 0
		return true
	elseif (HuntType == 2) then
		Note(string.format("\n%sAuto-hunt-trick completed.%s\n", bgreen, dwhite))
		EnableTriggerGroup("HTcr",true)
		--EnableTriggerGroup("hl_mobs",false)
		SendToServer(string.format("where %s.%s", attempt, Target))
		enableTriggers(false)
		HuntType = 0
		return true
	end
end

function finishHuntAdvanceHT()
	if (HuntType == 1) then
		Note("\nAuto hunt completed.\n")
		enableTriggers(false)
		dir = ""
		HuntType = 0
		return true
	elseif (HuntType == 2) then
		attempt = attempt+1
		SendToServer(string.format("where %s.%s", attempt, Target))
		return true
	end
end

function HTparseRoom(name, line, lineCaptured)
	local found = false
	local forNote =  lineCaptured["1"]
	local mobName = string.lower(string.sub(forNote, 1, 31))
	local parts = split(string.lower(Target), "[^ ]+")
	for index = 1, #parts do
		if (string.find(mobName, parts[index], 1, true) ~= nil) then
			found = true
			-- Note(string.format("%s - %s\n", parts[index], mobName))
			break -- leave loop
		end
	end
	if (found == true) then
		local RoomName = string.sub(forNote, 32)
		EnableTriggerGroup("HTcr", false)
		--[[
		Note("Room Captured.\n")
		Note(string.format("Captured this: %s%s%s.\n", bgreen, RoomName, dwhite))
		--]]
		SendToServer(string.format(".MapperPopulateRoomListArea here %s", RoomName))
	end
end

function startQW(mobName)
	Target = string.lower(mobName)
	EnableTriggerGroup("HTcr", true)
	Note(string.format("%sWhere is %s%s%s.%s\n", dgreen, bgreen, Target, dgreen, dwhite))
	SendToServer(string.format("where %s", mobName))
end

function HTnowheremob()
	EnableTriggerGroup("HTcr", false)
	Note(string.format("%sMob is nowhere or %s isn't in the area.%s\n", dred, Target, dwhite))
end

function enableTriggers(State)
	EnableTriggerGroup("autohunt",State)
end

function OnBackgroundStartup()
	enableTriggers(false)
	EnableTriggerGroup("HTcr",false)
end

Note(string.format("%sAuto Hunt%s and %sHunt Trick%s Plugin (experimental) installed\n", byellow, dwhite, dyellow, dwhite))
