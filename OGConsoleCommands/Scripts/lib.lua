local config = require('config')
local UEHelpers = require('UEHelpers')


---Print logs with the mod name
---@param message string
---@param level 'L' | 'I' | 'W' | 'E' | 'D'
function PrintLog (message, level)
  if level == 'D' and config.debug ~= true then
    return
  end

  return print(string.format('[%s] [%s] %s\n', config.name, level, message))
end

---Print message to log
---@param message string
function Log (message)
  return PrintLog(message, 'L')
end

---Print info message to log
---@param message string
function Info (message)
  return PrintLog(message, 'I')
end

---Print warn message to log
---@param message string
function Warn (message)
  return PrintLog(message, 'W')
end

---Print error message to log
---@param message string
function Error (message)
  return PrintLog(message, 'E')
end

---Print debug message to log
---@param message string
function Debug (message)
  return PrintLog(message, 'D')
end

---Run Console Command as Engine
---@param command string
function RunCommand (command)
  local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
  local EngineInstance = FindFirstOf('Engine')

  Info(string.format('Running command "%s"', command))
  KismetSystemLibrary:ExecuteConsoleCommand(EngineInstance, command, nil, nil)
end

---Run Console Command as Player
---@param command string
function RunPlayerCommand (command)
  local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
  local PlayerController = UEHelpers.GetPlayerController()

  if PlayerController == nil then
    return Error(string.format('Unable to run run command "%s", no player', command))
  end

  Info(string.format('Running command "%s"', command))
  KismetSystemLibrary:ExecuteConsoleCommand(PlayerController.player, command, PlayerController, nil)
end

