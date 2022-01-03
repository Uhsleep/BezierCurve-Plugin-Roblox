local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)

local context = Roact.createContext(nil)

return context