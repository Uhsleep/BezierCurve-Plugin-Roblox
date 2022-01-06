local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = require(script:FindFirstAncestor("ui").components.pageHeader)
local Button = require(script:FindFirstAncestor("ui").components.button)

local InitialPage = Roact.Component:extend("InitialPage")

function InitialPage:init()
    self.onNewPathClicked = function()
        self.props.gotoPage(2)
    end

    self.onLoadPathClicked = function()
        self.props.gotoPage(3)
    end
end

function InitialPage:render()
    local props = {
        pageHeaderContainer = {
            Size = UDim2.new(1, 0, 0.1, 0),
        },

        buttonContainer = {
            Position = UDim2.new(0, 0, 0.1, 0),
            Size = UDim2.new(1, 0, 0.9, 0),

            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        }
    }

    return Roact.createFragment({
        PageHeaderContainer = e("Frame", props.pageHeaderContainer, {
            PageHeader = e(PageHeader, {
                title = "Bezier Paths",
                color = Color3.fromRGB(70, 70, 70)
            })
        }),

        ButtonContainer = e("Frame", props.buttonContainer, {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Vertical,

            }),

            NewPathButton = e("Frame", {
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0.13, 0)
            }, {
                Button = e(Button, {
                    position = UDim2.new(0.5, 0, 0.5, 0),
                    size = UDim2.new(1, 0, 1, 0),
                    text = "New Path",
                    color = Color3.fromRGB(58, 216, 95),
                    onClick = self.onNewPathClicked
                }),
            }),

            LoadPathButton = e("Frame", {
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0.13, 0)
            }, {
                Button = e(Button, {
                    position = UDim2.new(0.5, 0, 0.5, 0),
                    size = UDim2.new(1, 0, 1, 0),
                    text = "Load Path",
                    color = Color3.fromRGB(200, 126, 30),
                    onClick = self.onLoadPathClicked
                }),
            })
        })
    })
end

function InitialPage:didMount()
    -- print("Initial Page mounted")
end

function InitialPage:willUnmount()
    -- print("Initial Page unmounting")
end

return InitialPage