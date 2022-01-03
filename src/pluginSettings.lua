local RootPath = script.Parent
local Path = require(RootPath.types.path)

local Settings = {
    paths = plugin:GetSetting("paths")
}
Settings.__index = Settings

function Settings:load(pathName)
    if not self.paths[pathName] then
        return
    end

    return plugin:GetSetting("BezierPath_" .. pathName)
end

function Settings:save(pathName, path)
    
end

function Settings:saveAndExport(pathName, path)

end

function Settings:export(path)

end

return Settings