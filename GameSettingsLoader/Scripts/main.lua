require "lib"
local config = require "config"
local INIParser = require "LIP"
local GameData = getGameData()
local GameSettings = {}

Log(string.format("Started - version: %s - author: %s", config.version, config.author))

for _, ini in getFilesInDirectory("OBSE\\Plugins\\GameSettings", ".ini", GameData.BinariesDirectory, true) do
  Log("Loading GameSettings from '" .. ini .. "'")

  local current = INIParser.load(ini)

  -- This section is for TES4 game settings that are mapped to VOblivionInitialSettings
  local tes4section = current.GameSettings
  if tes4section ~= nil then
    for setting, value in pairs(tes4section) do
      local mappedSetting = config.oblivion_to_unreal_bindings[setting]
      if mappedSetting ~= nil then
        Log("Found setting: " .. setting .. " -> " .. mappedSetting .. ": " .. tostring(value))
        GameSettings[mappedSetting] = value
      end
    end
  end

  -- This section is for VOblivionInitialSettings
  local ue5section = current.VOblivionInitialSettings
  if ue5section ~= nil then
    for setting, value in pairs(ue5section) do
      Log("Found setting " .. setting .. ": " .. tostring(value))
      GameSettings[setting] = value
    end
  end
end

-- This object contains settings that were overriden on the UE side
-- In the case the object is not ready yet, this helper function will retry
local SettingInstance = EnsureStaticObject("/Script/UE5AltarPairing.Default__VOblivionInitialSettings")

-- Patch the settings with the values in our inis
if SettingInstance and SettingInstance:IsValid() then
  Log("Configuring GameSettings")

  -- Try changing the default settings
  for setting, value in pairs(GameSettings) do
    if not string.find(tostring(SettingInstance[setting]), "UObject") then
      Log(string.format("Updating %s -> %s", setting, value))
      SettingInstance[setting] = value
    else
      Log(string.format("Failed to set %s -> %s", setting, value))
    end
  end
else
  Log("Failed to configure GameSettings")
end
