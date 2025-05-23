-- Import library functions globaly
require("lib")

-- Import config and INI parsing library
local config = require("config")
local INIParser = require("LIP")

-- Get UE Objects
local GameSettingInstance = EnsureStaticObject("/Script/UE5AltarPairing.Default__VOblivionInitialSettings")
local PhysicsSettingsInstance = EnsureStaticObject("/Script/Engine.Default__PhysicsSettings")

-- Table to Hold changed settings
local Settings = {
  GameUE5 = {},
  GameTES = {},
  Physics = {},
  Console = {}
}

Info(string.format("Started - version: %s - author: %s", config.version, config.author))

-- Loop over inis in GameSettings directory
for _, ini in FindFiles("OBSE\\Plugins\\GameSettings", ".ini") do
  Info("Loading settings from '" .. ini .. "'")

  local current = INIParser.load(ini)

  -- This section is for TES4 game settings that are mapped to VOblivionInitialSettings
  local tes4Section = current.GameSettings
  if tes4Section ~= nil then
    for setting, value in pairs(tes4Section) do
      Debug("Found setting: " .. setting .. ": " .. tostring(value))
      Settings.GameTES[setting] = value

      -- Support setting UE5Settings settings via TES4Settings
      local mappedSetting = config.tes4_to_ue5_bindings[setting]
      if mappedSetting ~= nil then
        Debug("Found mapped setting: " .. setting .. " -> " .. mappedSetting .. ": " .. tostring(value))
        Settings.GameUE5[mappedSetting] = value
      end
    end
  end

  -- This section is for VOblivionInitialSettings
  local ue5Section = current.VOblivionInitialSettings
  if ue5Section ~= nil then
    for setting, value in pairs(ue5Section) do
      Debug("Found setting " .. setting .. ": " .. tostring(value))
      Settings.GameUE5[setting] = value

      -- Support setting TES4 settings via UE5Settings
      local mappedSetting = FlipTable(config.tes4_to_ue5_bindings)[setting]
      if mappedSetting ~= nil then
        Debug("Found mapped setting: " .. setting .. " -> " .. mappedSetting .. ": " .. tostring(value))
        Settings.GameTES[mappedSetting] = value
      end
    end
  end

  -- This section is for PhysicsSettings
  local physicsSection = current.PhysicsSettings
  if physicsSection ~= nil then
    for setting, value in pairs(physicsSection) do
      Debug("Found setting " .. setting .. ": " .. tostring(value))
      Settings.Physics[setting] = value
    end
  end

  -- This section is for ConsoleVariables
  local consoleSection = current.ConsoleVariables
  if consoleSection ~= nil then
    for setting, value in pairs(consoleSection) do
      Debug("Found setting " .. setting .. ": " .. tostring(value))
      Settings.Console[setting] = value
    end
  end
end

-- Patch the settings with the values in our inis
UpdateValues(GameSettingInstance, Settings.GameUE5)
UpdateValues(PhysicsSettingsInstance, Settings.Physics)
UpdateCVars(Settings.Console)
UpdateGameSettings(Settings.GameTES)
