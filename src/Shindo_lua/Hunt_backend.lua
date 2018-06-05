dir = ""
Target = ""
attempt = 0
HuntType = 0 -- 0 off, 1 hunt, 2 hunt trick

function openDoor()
  SendToServer("open "..dir)
end

function startHunt(mob)
  Note("\nAuto hunt engaged.\n")
  enableTriggers(true)
  Target = mob
  dir = ""
  HuntType = 1
  SendToServer("hunt "..Target)
  return true
end

function startHT(mob)
  Note("\nAuto-hunt-trick engaged: "..mob.."\n")
  enableTriggers(true)
  HuntType = 2
  start_pos = mob:find("%.")
  if(not start_pos) then
    Target = mob
    attempt = 1
  else
    Note("Start pos: "..start_pos)
    Target = mob:sub(start_pos+1)
    attempt = mob:sub(0,start_pos-1)
    Note("pulled out "..Target.." pos:"..attempt)
  end
  SendToServer("hunt "..attempt.."."..Target)
  return true
end

function advanceHuntandHT(name,line,replaceMap)
  if (HuntType == 1) then
    dir = replaceMap["1"]
    Note("Auto hunt advancing: "..dir.."\n")
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
    Note("\nAuto hunt obstruction occurred, disabling triggers.\n")
    enableTriggers(false)
    dir = ""
    HuntType = 0
    return true
  elseif (HuntType == 2) then
    Note("\nAuto-hunt-trick completed.\n")
    SendToServer("where "..attempt.."."..Target)
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
    SendToServer("hunt "..attempt.."."..Target)
    return true
  end
end

function enableTriggers(State)
  EnableTriggerGroup("autohunt",State)
end

function OnBackgroundStartup()
  enableTriggers(false)
end

RegisterSpecialCommand("ah","startHunt")
RegisterSpecialCommand("ht","startHT")
Note("Auto Hunt and Hunt Trick Plugin installed\n")
