-- Import library functions globaly
require('lib')

-- Import config and INI parsing library
local config = require('config')

-- Print mod version and author on load
Info(string.format('version: %s - author: %s', config.version, config.author))

-- Hook functions and send click on Confirm button
RegisterHook("/Script/Altar.VMainMenuViewModel:RegisterSendClickedContinue", function()
  Info("Continue Game selected")

  -- Wait for visible prompt
  LoopAsync(10, function()
    local ContinuePrompt = FindFirstOf("WBP_ModernMenu_Message_C")

    -- Continue Prompt not found
    if not (ContinuePrompt and ContinuePrompt:IsValid()) then
      Debug('ContinuePrompt not found, trying again')
      return false
    end

    -- Auto Confirm if Visible
    if ContinuePrompt:IsVisible() then
      Info("Skipping Continue Prompt")

      ContinuePrompt:SendClickedButton(0)
      return true
    end

    -- Retry
    return false
  end)
end)
