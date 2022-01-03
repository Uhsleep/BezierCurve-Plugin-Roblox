local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local LoadPathPage = Roact.Component:extend("LoadPathPage")

function LoadPathPage:init()

end

function LoadPathPage:render()

    return Roact.createFragment({
        Text = e("TextLabel", {
            Size = UDim2.new(1, 0, 0.2, 0),
            Text = "Load Path Page"
        }),

        PreviousPageButton = e("TextButton", {
            Position = UDim2.new(0, 0, 0.2, 0),
            Size = UDim2.new(1, 0, 0.4, 0),
            Text  = "Go to initial page",
            [Roact.Event.MouseButton1Click] = function()
                self.props.gotoPage(1)
            end
        }),

        LoadPathButton = e("TextButton", {
            Position = UDim2.new(0, 0, 0.6, 0),
            Size = UDim2.new(1, 0, 0.4, 0),
            Text  = "Load path",
            [Roact.Event.MouseButton1Click] = function()
                self.props.gotoPage(4)
            end
        })
    })
end

function LoadPathPage:didMount()
    print("Load Path Page mounted")
end

function LoadPathPage:willUnmount()
    print("Load Path Page unmounting")
end

return LoadPathPage