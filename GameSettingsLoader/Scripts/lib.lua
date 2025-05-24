local config = require('config')
local UEHelpers = require('UEHelpers')


---Print logs with the mod name
---@param message string
---@param level 'I' | 'W' | 'E' | 'D'
function PrintLog (message, level)
  if level == 'DEBUG' and config.debug ~= true then
    return
  end

  return print(string.format('[%s] [%s] %s\n', config.name, level, message))
end

---Print log alias for Info
---@param message string
function Log (message)
  return Info(message)
end

---Print info log
---@param message string
function Info (message)
  return PrintLog(message, 'I')
end

---Print warn log
---@param message string
function Warn (message)
  return PrintLog(message, 'W')
end

---Print error log
---@param message string
function Error (message)
  return PrintLog(message, 'E')
end

---Print debug log
---@param message string
function Debug (message)
  return PrintLog(message, 'D')
end


---Get Static Object or wait until its ready
---@param objectName string
---@return UObject
function EnsureStaticObject (objectName)
  Debug(string.format('EnsureStaticObject: %s', objectName))
  local objectToFind = nil

  while not (objectToFind and objectToFind:IsValid()) do
    Debug(string.format('Calling StaticFindObject: %s', objectName))
    objectToFind = StaticFindObject(objectName)
  end

  Debug('EnsureStaticObject Finished')
  -- Finally return the object
  return objectToFind
end


---Swap a tables keys with its values
---@param table table
---@returns table<<table.V>, <table.K>>
function FlipTable (table)
   local flipped = {}

   for key, value in pairs(table) do
     flipped[value]=key
   end

   return flipped
end


---Update UObject settings
---@param objectInstance UObject
---@param settings table
function UpdateValues (objectInstance, settings)
  local objectFName = objectInstance:GetFName()
  local objectName = 'Unknown UObject'

  if objectFName then
    objectName = objectFName:ToString()
  end

  Info('Configuring ' .. objectName)

  if objectInstance:IsValid() == false then
    return Error('Failed to configure ' .. objectName)
  end

  -- Try changing the default object settings
  for setting, value in pairs(settings) do
    if not string.find(tostring(objectInstance:GetPropertyValue(setting)), 'UObject') then
      Info(string.format('Updating %s -> %s', setting, value))
      objectInstance:SetPropertyValue(setting, value)
    else
      Error(string.format('Failed to set %s -> %s', setting, value))
    end
  end
end


---Update Console Variables via console
---@param settings table
function UpdateCVars (settings)
  local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
  local EngineInstance = FindFirstOf('Engine')

  Info('Configuring Console Variables')

  for cmd, value in pairs(settings) do
    local command = cmd .. ' ' .. value

    if command == '' or command == nil then
      return Error('Unable to run command (command is nil)')
    end

    Info(string.format('Running command "%s"', command))
    ExecuteInGameThread(function ()
      KismetSystemLibrary:ExecuteConsoleCommand(EngineInstance, command, nil)
    end)
  end
end


---Update TES4 Game Settings via console
---@param settings table
function UpdateGameSettings (settings)
  local GameSaveLoad = '/Script/Altar.VLevelChangeData:OnFadeToBlackBeginEventReceived'

  ExecuteInGameThread(function ()
    -- hook id refs
    local PreId, PostId

    -- hook event and keep id refs so we can unhook
    PreId, PostId = RegisterHook(GameSaveLoad, function ()
      local PlayerController = UEHelpers.GetPlayerController()
      local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()

      Info('Configuring Game Settings')

      for cmd, value in pairs(settings) do
        local command = 'SetGameSetting ' .. cmd .. ' ' .. value

        if command == '' or command == nil then
          return Error('Unable to run command (command is nil)')
        end

        Info(string.format('Running command "%s"', command))
        ExecuteInGameThread(function ()
          KismetSystemLibrary:ExecuteConsoleCommand(PlayerController.player, command, PlayerController)
        end)
      end

      -- Unhook once the function has been called once
      UnregisterHook(GameSaveLoad, PreId, PostId)
    end)
  end)
end


---Get the release type, name, and bin dir of the game
---@returns { Name: string, ReleaseType: 'Win64' | 'WinGDK', BinariesDirectory: table<<K>, <V>> }
function GameData ()
  local GameDirectory = IterateGameDirectories()['Game']
  local GameName = GameDirectory.__name
  local BinariesDirectory = GameDirectory.Binaries

  -- is Steam Release
  if BinariesDirectory.Win64 ~= nil then
    for _,file in pairs(BinariesDirectory.Win64.__files) do
      if file.__name == GameName .. '-Win64-Shipping.exe' then
        return {
          Name = GameName,
          ReleaseType = 'Win64',
          BinariesDirectory = BinariesDirectory.Win64
        }
      end
    end
  end

  -- is Gamepass Release
  if BinariesDirectory.WinGDK ~= nil then
    for _,file in pairs(BinariesDirectory.WinGDK.__files) do
      if file.__name ==  GameName .. '-WinGDK-Shipping.exe' then
        return {
          Name = GameName,
          ReleaseType = 'WinGDK',
          BinariesDirectory = BinariesDirectory.WinGDK
        }
      end
    end
  end
end


---Takes a path\\to\\dir, optional filter '.ini', will append the path to the file in the table unless namesOnly is set to true
---@param path string
---@param filter? string
---@param namesOnly? boolean
---@returns fun(table: table<<K>, <V>>, index?: <K>):<K>, <V>
function FindFiles (path, filter, namesOnly)
  local files = {}
  local currentPath = GameData().BinariesDirectory

  -- follow path making sure dirs exist, returns early if any dir missing
  for directory in path:gmatch('([^\\]+)') do
    if currentPath[directory] ~= nil then
      currentPath = currentPath[directory]
    else
      return pairs(files)
    end
  end

  -- loop over files in path
  for _, fileobject in pairs(currentPath.__files) do
    local currentFile = fileobject.__name

    -- only add files if filter not set or if they match the filter
    if filter == nil or filter ~= nil and currentFile:sub(-4):lower() == filter then
      if namesOnly == true then
        table.insert(files, fileobject.__name)
      else
        table.insert(files, path .. '\\' .. fileobject.__name)
      end
    end
  end

  return pairs(files)
end


---Takes a path\\to\\file.ini
---@param path string
---@returns table<<K>, <V>>
function ParseINI (path)
  local ini = io.open(path, 'r')
  local parsed = {}
  local currentSection = nil

  if ini == nil then
    return parsed
  end

  for line in ini:lines() do
    -- match ini sections i.e [Section]
    local section = line:match('^%[([^%[%]]+)%][\r]?$')

    if section then
      currentSection = section
      -- merge duplicate sections into single table or create new table if new section
      parsed[currentSection] = parsed[currentSection] or {}
    end

    local param, value = line:match('^([%w|_|%.]+)%s*=%s*(.*)[\r]?$')

    if param and value ~= nil then
      -- match key value pairs ignoring in-line comments i.e key=value ; comment
      value = value:match('^(.-)%s-;.-$') or value:match('^(.-)%s-$')

      -- number values to number, boolean values to boolean
      if tonumber(value) then
        value = tonumber(value)
      elseif value == 'true' then
        value = true
      elseif value == 'false' then
        value = false
      end

      parsed[currentSection][param] = value
    end
  end

  ini:close()

  return parsed
end
