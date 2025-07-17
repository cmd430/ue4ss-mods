-- Import library functions globaly
require('lib')

-- Import config
local config = require('config')

-- Print mod version and author on load
Info(string.format('version: %s - author: %s', config.version, config.author))

-- Quit Game: qqq -> Exit
RegisterConsoleCommandHandler("qqq", function ()
  RunCommand('Exit')

  return true
end)

-- Toggle Collision : tcl -> Ghost/Walk
local tcl = false
RegisterConsoleCommandHandler("tcl", function ()
  if tcl == true then
    RunPlayerCommand('Walk')
    tcl = false
  else
    RunPlayerCommand('Ghost')
    tcl = true
  end

  return true
end)
