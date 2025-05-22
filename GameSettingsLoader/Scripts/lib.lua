local config = require "config"

-- Print logs with the modname for easy debug
function Log(output)
  print(string.format("[%s] %s\n", config.name, output))
end

-- Get Static Object or wait until its ready
function EnsureStaticObject(objectName, retryInterval)
  Log(string.format("EnsureStaticObject: %s", objectName))
  local objectToFind = nil

  while not (objectToFind and objectToFind:IsValid()) do
    Log(string.format("Calling StaticFindObject: %s", objectName))
    objectToFind = StaticFindObject(objectName)
  end

  Log("EnsureStaticObject Finished")
  -- Finally return the object
  return objectToFind
end

-- Get the release type, name, and bin dir of the game
function getGameData()
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
  return nil
end

-- Replaces io.popen, takes a path\\to\\dir, optional filter ".ini" and optional basepath table, will append the path to the file in the table if includePath is set to true
function getFilesInDirectory(path, filter, basePath, includePath)
  local files = {}
  local folders = path:gmatch("([^\\]+)")
  local currentPath

  if (basePath ~= nil) then
    currentPath = basePath
  else
    currentPath = getGameVersion().BinariesDirectory
  end

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
      if (includePath == true) then
        table.insert(files, path .. "\\" .. fileobject.__name)
      else
        table.insert(files, fileobject.__name)
      end
    end
  end

  return pairs(files)
end
