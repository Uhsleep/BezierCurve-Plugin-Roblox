local Selection = game:GetService("Selection")

local RootDir = script.Parent
local Path = require(RootDir.types.path)
local WorldPath = require(RootDir.worldPath)
local PluginSettings = require(RootDir.pluginSettings)

local PathContext = {
    pathName = "EXAMPLE PATH NAME",
    worldPath = WorldPath,
    Settings = PluginSettings
}
PathContext.__index = PathContext

function PathContext:init(plugin)
    self.Settings:init(plugin)
end

function PathContext:newPath(pathName, pathData)
    self.pathName = pathName
    self.worldPath:_init(Path(pathData.anchors, pathData.controls))
    self.worldPath.worldPath.Name = "WorldPath_" .. pathName
end

function PathContext:loadPath(pathName)
    local path = self.Settings:load(pathName)
    if not path then
        return false
    end

    self.pathName = pathName
    self.worldPath:_init(path)
    self.worldPath.worldPath.Name = "WorldPath_" .. pathName
    
    return true
end

function PathContext:setSelectedAnchor(anchorIndex)
    local worldAnchor = self.worldPath:getWorldAnchor(anchorIndex)
    if not worldAnchor then
        return
    end

    -- This in turn will end up calling worldPath:setSelectedAnchor
    Selection:Set({ worldAnchor.Anchor })
end

function PathContext:save()
    self.Settings:save(self.pathName, self.worldPath.path)
end

return PathContext