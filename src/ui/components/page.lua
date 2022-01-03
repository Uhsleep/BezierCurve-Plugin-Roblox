local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local Page = Roact.Component:extend("Page")



return Page