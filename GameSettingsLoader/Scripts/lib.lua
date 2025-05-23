local config = require("config")
local UEHelpers = require("UEHelpers")


---Print logs with the mod name
---@param message string
---@param level "I" | "W" | "E" | "D"
function PrintLog (message, level)
  if level == "DEBUG" and config.debug ~= true then
    return
  end

  return print(string.format("[%s] [%s] %s\n", config.name, level, message))
end

---Print log alias for Info
---@param message string
function Log (message)
  return Info(message)
end

---Print info log
---@param message string
function Info (message)
  return PrintLog(message, "I")
end

---Print warn log
---@param message string
function Warn (message)
  return PrintLog(message, "W")
end

---Print error log
---@param message string
function Error (message)
  return PrintLog(message, "E")
end

---Print debug log
---@param message string
function Debug (message)
  return PrintLog(message, "D")
end


---Get Static Object or wait until its ready
---@param objectName string
function EnsureStaticObject (objectName)
  Debug(string.format("EnsureStaticObject: %s", objectName))
  local objectToFind = nil

  while not (objectToFind and objectToFind:IsValid()) do
    Debug(string.format("Calling StaticFindObject: %s", objectName))
    objectToFind = StaticFindObject(objectName)
  end

  Debug("EnsureStaticObject Finished")
  -- Finally return the object
  return objectToFind
end


---Swap a tables keys with its values
---@param table table
---@return table
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
  local objectName = objectInstance:GetFName():ToString()

  Info("Configuring " .. objectName)

  if objectInstance:IsValid() == false then
    return Error("Failed to configure " .. objectName)
  end

  -- Try changing the default object settings
  for setting, value in pairs(settings) do
    if not string.find(tostring(objectInstance:GetPropertyValue(setting)), "UObject") then
      Info(string.format("Updating %s -> %s", setting, value))
      objectInstance:SetPropertyValue(setting, value)
    else
      Error(string.format("Failed to set %s -> %s", setting, value))
    end
  end
end


---Update Console Variables via console
---@param settings table
function UpdateCVars (settings)
  local KismetSystemLibrary = EnsureStaticObject('/Script/Engine.Default__KismetSystemLibrary')
  local EngineInstance = FindFirstOf('Engine')

  Info("Configuring Console Variables")

  for cmd, value in pairs(settings) do
    local command = cmd .. " " .. value

    if command == '' or command == nil then
      return Error("Unable to run command (command is nil)")
    end

    Info(string.format("Running %s", command))
    ExecuteInGameThread(function ()
      KismetSystemLibrary:ExecuteConsoleCommand(EngineInstance, command, nil)
    end)
  end
end


---Update TES4 Game Settings via console
---@param settings table
function UpdateGameSettings (settings)
  local GameSaveLoad = "/Script/Altar.VLevelChangeData:OnFadeToBlackBeginEventReceived"

  ExecuteInGameThread(function ()
    -- make sure object is ready to hook
    EnsureStaticObject(GameSaveLoad)

    -- hook id refs
    local PreId
    local PostId

    -- hook event and keep id refs so we can unhook
    PreId, PostId = RegisterHook(GameSaveLoad, function (context)
      local PlayerController = UEHelpers.GetPlayerController()
      local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()

      Info("Configuring Game Settings")

      for cmd, value in pairs(settings) do
        local command = "SetGameSetting " .. cmd .. " " .. value

        if command == '' or command == nil then
          return Error("Unable to run command (command is nil)")
        end

        Info(string.format("Running %s", command))
        ExecuteInGameThread(function ()
          KismetSystemLibrary:ExecuteConsoleCommand(PlayerController.player, command, PlayerController)
        end)
      end

      -- Unhook once the function has been called once
      if PreId then
        UnregisterHook(GameSaveLoad, PreId, PostId)
      end
    end)
  end)
end


---Get the release type, name, and bin dir of the game
---@return { Name: string, ReleaseType: "Win64" | "WinGDK", BinariesDirectory: table } | nil
function GameData ()
  local GameDirectory = IterateGameDirectories().Game
  local GameName = GameDirectory.__name
  local BinariesDirectory = GameDirectory.Binaries

  if BinariesDirectory.Win64 ~= nil then
    for _,file in pairs(BinariesDirectory.Win64.__files) do
      if file.__name == GameName .. "-Win64-Shipping.exe" then
        return {
          Name = GameName,
          ReleaseType = "Win64",
          BinariesDirectory = BinariesDirectory.Win64
        }
      end
    end
  end

  if BinariesDirectory.WinGDK ~= nil then
    for _,file in pairs(BinariesDirectory.WinGDK.__files) do
      if file.__name ==  GameName .. "-WinGDK-Shipping.exe" then
        return {
          Name = GameName,
          ReleaseType = "WinGDK",
          BinariesDirectory = BinariesDirectory.WinGDK
        }
      end
    end
  end
end


---Takes a path\\to\\dir, optional filter ".ini", will append the path to the file in the table unless namesOnly is set to true
---@param path string
---@param filter? string
---@param namesOnly? boolean
function FindFiles (path, filter, namesOnly)
  local files = {}
  local folders = path:gmatch("([^\\]+)")
  local currentPath = GameData().BinariesDirectory

  for folder in folders do
    if currentPath[folder] ~= nil then
      currentPath = currentPath[folder]
    else
      return pairs(files)
    end
  end

  for _, fileobject in pairs(currentPath.__files) do
    local currentFile = fileobject.__name

    if (filter == nil or filter ~= nil and currentFile:sub(-4):lower() == filter) then
      if (namesOnly == true) then
        table.insert(files, fileobject.__name)
      else
        table.insert(files, path .. "\\" .. fileobject.__name)
      end
    end
  end

  return pairs(files)
end
