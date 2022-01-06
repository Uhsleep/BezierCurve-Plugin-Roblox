local UserInputService = game:GetService("UserInputService")

local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local Slider = Roact.PureComponent:extend("Slider")

function Slider:init()
    self.trackReference = Roact.createRef()
    self.thumbReference = Roact.createRef()

    self.onTrackContainerMouseDown = function(frame, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
             -- get the relative x position
             local x = input.Position.X
             local relativeX = x - self.trackPosition:getValue().X

             -- clamp the position between two points
             local min = self.thumbSize:getValue().X / 2
             local max = self.trackSize:getValue().X - min
             local clampedX = math.clamp(relativeX, min, max)

             -- map the x position to a value between 0 and props.maxValue
             local mappedValue = (clampedX - min) / (max - min) * self.props.maxValue
             -- print("mappedValue:", mappedValue)
             -- update value using the props callback
             if type(self.props.onValueChanged) == "function" then
                 self.props.onValueChanged(mappedValue)
             end

             self:setState({
                 dragging = true
             })
        end
    end

    self.onTrackContainerMouseMoved = function(frame, input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if self.state.dragging then
                -- print("Moving mouse in track container while dragging.")

                -- get the relative x position
                local x = input.Position.X
                local relativeX = x - self.trackPosition:getValue().X

                -- clamp the position between two points
                local min = self.thumbSize:getValue().X / 2
                local max = self.trackSize:getValue().X - min
                local clampedX = math.clamp(relativeX, min, max)

                -- map the x position to a value between 0 and props.maxValue
                local mappedValue = (clampedX - min) / (max - min) * self.props.maxValue
                -- print("mappedValue:", mappedValue)
                -- update value using the props callback
                if type(self.props.onValueChanged) == "function" then
                    self.props.onValueChanged(mappedValue)
                end
            end
        end
    end

    self.onTrackContainerMouseUp = function(frame, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:setState({
                dragging = false
            })
        end
    end

    self.onIncreaseButtonClicked = function(frame)
        local newValue = math.clamp(self.props.value + 0.01 * self.props.maxValue, 0, self.props.maxValue)

        if type(self.props.onValueChanged) == "function" then
            self.props.onValueChanged(newValue)
        end
    end

    self.onDecreaseButtonClicked = function(frame)
        local newValue = math.clamp(self.props.value - 0.01 * self.props.maxValue, 0, self.props.maxValue)

        if type(self.props.onValueChanged) == "function" then
            self.props.onValueChanged(newValue)
        end
    end

    self.thumbSize, self.updateThumbSize = Roact.createBinding(Vector2.new(0, 0))
    self.trackSize, self.updateTrackSize = Roact.createBinding(Vector2.new(0, 0))
    self.trackPosition, self.updateTrackPosition = Roact.createBinding(Vector2.new(0, 0))
    
    self:setState({
        dragging = false
    })
end

function Slider:render()
    local value = self.props.value
    local maxValue = self.props.maxValue

    -- local thumbPosition = UDim2.new(0.1, 0, 0.5, 0)
    -- if self.trackReference:getValue() then
    --     local thumbHalfWidth = self.thumbReference:getValue().AbsoluteSize.X / 2
    --     local trackWidth = self.trackReference:getValue().AbsoluteSize.X

    --     local x = value / maxValue * (trackWidth - 2 * thumbHalfWidth)
    --     thumbPosition = UDim2.new(0, thumbHalfWidth + x, 0.5, 0)
    -- end

    local props = {
        decreaseButton = {
            Size = UDim2.new(0.05, 0, 1, 0),
            LayoutOrder = 1,

            Text = "<",

            [Roact.Event.MouseButton1Click] = self.onDecreaseButtonClicked
        },

        increaseButton = {
            Size = UDim2.new(0.05, 0, 1, 0),
            LayoutOrder = 3,

            Text = ">",

            [Roact.Event.MouseButton1Click] = self.onIncreaseButtonClicked
        },

        trackContainer = {
            Size = UDim2.new(0.9, 0, 1, 0),
            LayoutOrder = 2,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(200, 100, 100),

            [Roact.Event.InputBegan] = self.onTrackContainerMouseDown,
            [Roact.Event.InputChanged] = self.onTrackContainerMouseMoved,
            [Roact.Event.InputEnded] = self.onTrackContainerMouseUp
        },

        track = {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0.3, 0),

            [Roact.Change.AbsoluteSize] = function(obj)
                self.updateTrackSize(obj.AbsoluteSize)
            end,

            [Roact.Change.AbsolutePosition] = function(obj)
                self.updateTrackPosition(obj.AbsolutePosition)
            end
        },

        thumb = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = Roact.joinBindings({self.thumbSize, self.trackSize}):map(function(sizes)
                local thumbHalfWidth = sizes[1].X / 2
                local trackWidth = sizes[2].X

                local x = value / maxValue * (trackWidth - 2 * thumbHalfWidth)
                return UDim2.new(0, thumbHalfWidth + x, 0.5, 0)
            end),

            Size = UDim2.new(0.05, 0, 1, 0),
            Active = true,

            [Roact.Ref] = self.thumbReference,

            [Roact.Change.AbsoluteSize] = function(obj)
                self.updateThumbSize(obj.AbsoluteSize)
            end
        }
    }


    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            FillDirection = Enum.FillDirection.Horizontal
        }),

        DecreaseButton = e("TextButton", props.decreaseButton),
        TrackContainer = e("Frame", props.trackContainer, {
            Track = e("Frame", props.track),
            Thumb = e("Frame", props.thumb)
        }),
        IncreaseButton = e("TextButton", props.increaseButton)
    })
end

function Slider:didMount()

end

function Slider:willUnmount()

end

return Slider