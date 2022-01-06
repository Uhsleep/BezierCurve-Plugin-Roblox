--[[
    Save Format
    ----------------------------------
    {
        [1] = {
            position = { x, y, z }
            handles = {
                [1] = { x, y, z },
                [2] = { x, y, z }
            }
        },
        .
        .
        .
    }
]]

local RootPath = script.Parent
local Path = require(RootPath.types.path)


local function serializePath(path)
    local serializedPath = {}

    for _, anchorInfo in ipairs(path.anchors) do
        table.insert(serializedPath, {
            position = {
                anchorInfo.position.X,
                anchorInfo.position.Y,
                anchorInfo.position.Z
            },

            handles = {
                {
                    anchorInfo.handles[1].X,
                    anchorInfo.handles[1].Y,
                    anchorInfo.handles[1].Z
                },

                {
                    anchorInfo.handles[2].X,
                    anchorInfo.handles[2].Y,
                    anchorInfo.handles[2].Z
                }
            }
        })
    end

    return serializedPath
end

local function deserializePath(serializedPath)
    local anchors = {}
    local controls = {}

    for _, anchorInfo in ipairs(serializedPath) do
        table.insert(anchors, Vector3.new(anchorInfo.position[1], anchorInfo.position[2], anchorInfo.position[3]))
        table.insert(controls, Vector3.new(anchorInfo.handles[1][1], anchorInfo.handles[1][2], anchorInfo.handles[1][3]))
        table.insert(controls, Vector3.new(anchorInfo.handles[2][1], anchorInfo.handles[2][2], anchorInfo.handles[2][3]))
    end

    return Path(anchors, controls)
end

local Settings = {}
Settings.__index = Settings

function Settings:init(plugin)
    -- print("plugin from settings:", plugin)
    self.pl = plugin
    self.paths = plugin:GetSetting("paths") or {}
end

function Settings:load(pathName)
    if not self.paths[pathName] then
        return
    end

    local savedPath =self.pl:GetSetting("BezierPath_" .. pathName).path
    return deserializePath(savedPath)
end

function Settings:save(pathName, path)
    self.paths[pathName] = {
        saveTime = os.time(),
        path = serializePath(path)
    }

    self.pl:SetSetting("paths", self.paths)
    self.pl:SetSetting("BezierPath_" .. pathName, {
        saveTime = os.time(),
        path = serializePath(path)
    })
end

function Settings:saveAndExport(pathName, path)
    self:save(pathName, path)
    self:export(path)
end

function Settings:export(path)

end

function Settings:delete(pathName)
    if not self.paths[pathName] then
        return
    end

    self.pl:SetSetting("BezierPath_" .. pathName, nil)
    self.paths[pathName] = nil
    self.pl:SetSetting("paths", self.paths)
end

function Settings:getPathList()
    -- convert to array
    local paths = {}

    for pathName, pathData in pairs(self.paths) do
        table.insert(paths, { name = pathName, path = pathData.path, saveTime = pathData.saveTime })
    end

    -- sort by save time
    table.sort(paths, function(a, b)
        -- print(a.name, "save time vs", b.name, "save time: (", a.saveTime, "vs", b.saveTime, ")")
        return a.saveTime > b.saveTime
    end)

    -- 
    local p = {}

    for _, pathData in ipairs(paths) do
        table.insert(p, {
            name = pathData.name,
            path = pathData.path
        })
    end

    return p
end

return Settings