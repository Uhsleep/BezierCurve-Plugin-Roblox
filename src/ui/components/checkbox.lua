local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local function boxContainsPoint(x, y, width, height, point)
    local a = point.X >= x and point.X <= x + width
    local b = point.Y >= y and point.Y <= y + height

    return a and b
end

local Checkbox = Roact.PureComponent:extend("Checkbox")

function Checkbox:init()
    self.onCheckboxClicked = function(frame, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if boxContainsPoint(self.position.x, self.position.y, self.size.x, self.size.y, input.Position) then
                if type(self.props.onValueChanged) == "function" then
                    self.props.onValueChanged(not self.props.value)
                end
            end
        end
    end

    self.onAbsolutePositionChanged = function(frame)
        self.position = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
    end

    self.onAbsoluteSizeChanged = function(frame)
        self.size = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
    end
end


function Checkbox:render()
    local props = {
        outerFrame = {
            Size = UDim2.new(1, 0, 1, 0),

            [Roact.Event.InputEnded] = self.onCheckboxClicked,
            [Roact.Change.AbsolutePosition] = self.onAbsolutePositionChanged,
            [Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged
        },

        innerFrame = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.75, 0, 0.75, 0),

            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        }
    }

    local innerFrame
    if self.props.value then
        innerFrame = e("Frame", props.innerFrame)
    end

    return e("Frame", props.outerFrame, {
        InnerFrame = innerFrame
    })
end

return Checkbox