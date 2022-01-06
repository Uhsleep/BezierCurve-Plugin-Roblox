local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = Roact.Component:extend("PageHeader")

function PageHeader:init()

end

function PageHeader:render()
    local props = {
        container = {
            -- Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = self.props.color
        },

        pageTitle = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.4, 0, 0.7, 0),
            BackgroundTransparency = 1,

            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            BorderSizePixel = 0,
            Text = self.props.title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true
        },

        leftButtonContainer = {
            Size = UDim2.new(0.2, 0, 1, 0),
            BackgroundTransparency = 1
        },

        rightButtonContainer = {
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 1, 0),
            BackgroundTransparency = 1
        }
    }

    local leftButtonContainer
    if self.props.leftButtons and #self.props.leftButtons > 0 then
        local children = {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal,
            })
        }

        for i = 1, #self.props.leftButtons do
            local bc = e("Frame", {
                Size = UDim2.new(1 / #self.props.leftButtons, 0, 1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = i
            }, self.props.leftButtons[i])

            table.insert(children, bc)
        end

        leftButtonContainer = e("Frame", props.leftButtonContainer, children)
    end

    local rightButtonContainer
    if self.props.rightButtons and #self.props.rightButtons > 0 then
        local children = {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                FillDirection = Enum.FillDirection.Horizontal,
            })
        }

        for i = 1, #self.props.rightButtons do
            local bc = e("Frame", {
                Size = UDim2.new(0.25, 0, 1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = i
            }, self.props.rightButtons[i])

            table.insert(children, bc)
        end

        rightButtonContainer = e("Frame", props.rightButtonContainer, children)
    end

    return e("Frame", props.container, {
        LeftSideButtonContainer = leftButtonContainer,
        PageTitle = e("TextLabel", props.pageTitle),
        RightSideButtonContainer = rightButtonContainer
    })
end

function PageHeader:didMount()
end

function PageHeader:willUnmount()
end

return PageHeader