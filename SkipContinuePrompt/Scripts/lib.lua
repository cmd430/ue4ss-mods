local config = require('config')

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
