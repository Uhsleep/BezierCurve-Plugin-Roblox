local PluginSettings = require(script.Parent.pluginSettings)

local PathPlugin = {
    Settings = PluginSettings
}
PathPlugin.__index = PathPlugin

function PathPlugin:init(plugin)


end

function PathPlugin:onDeactivation()

end

function PathPlugin:onUnloading()

end

return PathPlugin

