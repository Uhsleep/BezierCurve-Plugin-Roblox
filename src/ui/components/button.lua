local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local Assets = require(Root.ui.assets)

--[[
    PROPS
----------------------------
    - anchorPoint
    - position
    - size
    - color
    - icon
    - text
    - textStyle
    - disabled
    - aspectRatio
    - onClick
    - onMouseDown
    - onMouseUp
    - baseLayerImage
    - topLayerImage
]]

local button = Roact.Component:extend("Button")

function button:init()
    self:setState({
        pressed = false,
        hovered = false
    })

    self.onMouseEnter = function()
        self:setState({ hovered = true })
    end

    self.onMouseLeave = function()
        if self.state.pressed then
            if type(self.props.onMouseUp) == "function" then
                self.props.onMouseUp()
            end
        end
        
        self:setState({ hovered = false, pressed = false })
    end

    self.onMouseDown = function(btn)
        if self.state.pressed then return end

        self:setState({ pressed = true })

        if type(self.props.onMouseDown) == "function" then
            self.props.onMouseDown(btn)
        end
    end

    self.onMouseUp = function(btn)
        if not self.state.pressed then return end

        self:setState({ pressed = false })
        
        if type(self.props.onMouseUp) == "function" then
            self.props.onMouseUp(btn)
        end
    end
end

function button:render()
    -- get gui props from component props that were passed in
    local props = self:createGUIProps(self.props)
    
    -- create children
    local iconView = self.renderIcon(props.icon)
    local textView = self.renderText(props.text)
    local aspectRatio = nil

    if self.props.aspectRatio ~= nil and type(self.props.aspectRatio) == "number" then
        aspectRatio = e("UIAspectRatioConstraint", {
            AspectRatio = self.props.aspectRatio
        })
    end

    -- create the component
    return e("ImageButton", props.button, {
        ButtonShading = e("ImageLabel", props.shading),
        IconView = iconView,
        TextView = textView,
        ARConstraint = aspectRatio,
    })
end

function button:shouldUpdate(nextProps, nextState)
    if nextState.pressed ~= self.state.pressed or nextState.hovered ~= self.state.hovered then
        return true
    end

    -- shallow checks
    if  self.props.position ~= nextProps.position or 
        self.props.size ~= nextProps.size or
        self.props.color ~= nextProps.color or 
        self.props.icon ~= nextProps.icon or
        self.props.text ~= nextProps.text or
        self.props.textStyle == nil and nextProps.textStyle ~= nil or self.props.textStyle ~= nil and nextProps.textStyle == nil or
        self.props.disabled and not nextProps.disabled or not self.props.disabled and nextProps.disabled or
        self.props.aspectRatio ~= nextProps.aspectRatio or
        self.props.onClick ~= nextProps.onClick then
            return true
    end

    -- deep check
    -- FIX: if a key is added to nextprops with all else staying the same, this won't return true 
    if self.props.textStyle ~= nil and nextProps.textStyle ~= nil then
        -- do both of the below tests at the same time possibly?
        
        -- first test for number of keys


        -- now test those values
        for k,v in pairs(self.props.textStyle) do
            if v ~= nextProps.textStyle[k] then
                return true
            end
        end
    end

    return false
end

function button:createGUIProps(buttonProps)
    local guiProps =  {}

    local shadingTransparency = 0
    local buttonColor = buttonProps.color or Color3.fromRGB(200, 200, 200)
    local h,s,v = Color3.toHSV(buttonColor)
    local dv = 0

    if self.state.pressed then
        shadingTransparency = 1
        dv = -0.1
    elseif self.state.hovered then
        dv = 0.1
    end
    
    buttonColor = Color3.fromHSV(h, s, v + dv)

    -- button
    guiProps.button = {
        AnchorPoint = self.props.anchorPoint or Vector2.new(0.5, 0.5),
        Position = buttonProps.position,
        Size = buttonProps.size or UDim2.new(0, 100, 0, 100),

        Image = Assets.images.button,
        ImageColor3 = buttonColor,
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(9, 9, 34, 31),

        -- [Roact.Ref] = self.buttonRef,
        [Roact.Event.MouseEnter] = self.onMouseEnter,
        [Roact.Event.MouseLeave] = self.onMouseLeave,
        [Roact.Event.MouseButton1Down] = self.onMouseDown,
        [Roact.Event.MouseButton1Up] = self.onMouseUp,
        [Roact.Event.MouseButton1Click] = function() 
            if buttonProps.disabled or type(buttonProps.onClick) ~= "function" then return end 
            buttonProps.onClick() 
        end
    }

    -- shading
    guiProps.shading = {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),

        Image = Assets.images.buttonShading,
        ImageTransparency = shadingTransparency,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(9, 9, 34, 31),

        -- [Roact.Ref] = self.shadingRef
    }

    -- icon
    local iconWidth = 0.2
    local iconPosition = 0.15

    if buttonProps.text == nil or buttonProps.text == "" then
        iconPosition = 0.5
        iconWidth = 0.6
    end

    guiProps.icon = {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(iconPosition, 0, 0.5, 0),
        Size = UDim2.new(iconWidth, 0, iconWidth, 0),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = buttonProps.icon,
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }

    -- text
    local textStyle = buttonProps.textStyle or {}

    local textWidth = 0.65
    local textPosition = 0.625

    if buttonProps.icon == nil then
        textWidth = 0.8
        textPosition = 0.5
    end

    guiProps.text = {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(textPosition, 0, 0.5, 0),
        Size = UDim2.new(textWidth, 0, 0.8, 0),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Text = buttonProps.text,
        TextSize = textStyle.size or 30,
        TextColor3 = textStyle.color,
        Font = textStyle.font or Enum.Font.ArialBold,
        TextScaled = true
    }

    -- if button is disabled, change button color to light gray and remove shading
    if buttonProps.disabled then
        guiProps.button.ImageColor3 = Color3.new(0.6, 0.6, 0.6)
        guiProps.button.ImageTransparency = 0.7
        guiProps.shading.ImageTransparency = 1
    end

    return guiProps
end

function button.renderText(textProps)
    if textProps.Text == nil or textProps.Text == "" then
        return nil
    end

    return Roact.createElement("TextLabel", textProps)
end

function button.renderIcon(iconProps)
    if iconProps.Image == nil then
        return nil
    end

    return e("ImageLabel", iconProps, {
        ARConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        })
    })
end

return button