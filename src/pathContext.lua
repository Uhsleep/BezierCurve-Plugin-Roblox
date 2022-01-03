local Selection = game:GetService("Selection")

local RootDir = script.Parent
local Path = require(RootDir.types.path)
local WorldPath = require(RootDir.worldPath)

local PathContext = {
    pathName = "EXAMPLE PATH NAME",
    worldPath = WorldPath
}
PathContext.__index = PathContext

function PathContext:newPath(pathName, pathData)
    self.pathName = pathName
    self.worldPath:_init(Path(pathData.anchors, pathData.controls))
    self.worldPath.worldPath.Name = "WorldPath_" .. pathName
end

function PathContext:loadPath(pathName)

end

function PathContext:setSelectedAnchor(anchorIndex)
    local worldAnchor = self.worldPath:getWorldAnchor(anchorIndex)
    if not worldAnchor then
        return
    end

    -- This in turn will end up calling worldPath:setSelectedAnchor
    Selection:Set({ worldAnchor.Anchor })
end

print("Selection:", Selection)

return PathContext