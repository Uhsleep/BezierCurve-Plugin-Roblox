local Selection = game:GetService("Selection")

local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = require(script:FindFirstAncestor("ui").components.pageHeader)
local Button = require(script:FindFirstAncestor("ui").components.button)
local Slider = require(script:FindFirstAncestor("ui").components.slider)
local Checkbox = require(script:FindFirstAncestor("ui").components.checkbox)

local EditPathPage = Roact.Component:extend("EditPathPage")

function EditPathPage:init(props)
    print("Edit Page init - path context name:", props.pathContext.pathName)

    self.onSaveButtonClicked = function()
        -- save this path to the plugin settings
        local pathContext = self.props.pathContext
        pathContext:save()

        if self.state.pathEdited then
            self:setState({
                pathEdited = false
            })
        end
    end

    self.onSaveAsButtonClicked = function()
        self.props.gotoPage(5)
    end

    self.onExportButtonClicked = function()
        -- save file here too
        self.onSaveButtonClicked()

        -- open a newly created module script and paste a table containing the necessary
        local path = self.props.pathContext.worldPath.path
        local script = Instance.new("ModuleScript")
        local source = "path = {\n"

        local anchors = "anchors = {\n"
        local controls = "controls = {\n"
        for _, anchor in ipairs(path.anchors) do
            local position = anchor.position
            local backHandlePosition = anchor.handles[1]
            local frontHandlePosition = anchor.handles[2]

            anchors = anchors .. ("\t\tVector3.new(%.3f, %.3f, %.3f),\n"):format(position.X, position.Y, position.Z)
            controls = controls .. ("\t\tVector3.new(%.3f, %.3f, %.3f),\n"):format(backHandlePosition.X, backHandlePosition.Y, backHandlePosition.Z)
            controls = controls .. ("\t\tVector3.new(%.3f, %.3f, %.3f),\n"):format(frontHandlePosition.X, frontHandlePosition.Y, frontHandlePosition.Z)
        end

        anchors = anchors .. "\t},\n\n"
        controls = controls .. "\t}\n"

        source = source .. "\t" .. anchors .. "\t" .. controls .. "}"

        script.Source = source
        script.Name = "Path-" .. self.props.pathContext.pathName
        script.Parent = workspace

        self.props.plugin:OpenScript(script)
        -- values and show the user

    end

    self.updatePathTracker = function()
        local worldPath = self.props.pathContext.worldPath
        local pathLength = worldPath:length()
        local distanceSliderValue = self.state.distanceSliderValue
        local desiredDistance = distanceSliderValue * pathLength
        local desiredPosition = worldPath:pointAtDistance(desiredDistance)

        self.pathTracker.Position = desiredPosition

        if not self.state.pathEdited then
            self:setState({
                pathEdited = true
            })
        end
    end

    self.onPreviousPageClicked = function()
        -- force save path
        -- self.onSaveButtonClicked()

        self.props.pathContext.worldPath:destroy()
        self.props.gotoPage(1)
    end

    self.onAddAnchorClicked = function()
        self.props.pathContext.worldPath:addAnchorPoint()
        self.props.pathContext:setSelectedAnchor(#self.props.pathContext.worldPath.worldAnchors)

        local worldAnchor = self.props.pathContext.worldPath:getWorldAnchor(#self.props.pathContext.worldPath.worldAnchors)
        local anchor = worldAnchor.Anchor
        local backHandle = worldAnchor.BackHandle
        local frontHandle = worldAnchor.FrontHandle

        -- add listener here to update tracker
        anchor:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)
        backHandle:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)
        frontHandle:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)

        if not self.state.pathEdited then
            self:setState({
                pathEdited = true
            })
        end
    end

    self.onDeleteAnchorClicked = function()
        local index = self.props.selectedAnchorIndex
        self.props.pathContext.worldPath:removeAnchorPoint(index)
        
        if self.props.pathContext.worldPath.currentSelectedAnchor then
            Selection:Set({ self.props.pathContext.worldPath.currentSelectedAnchor.Anchor })
        end

        if not self.state.pathEdited then
            self:setState({
                pathEdited = true
            })
        end
    end

    self.onDistanceSliderMoved = function(value)
        self:setState({
            distanceSliderValue = value
        })

        if self.state.previewChecked then
            local camera = workspace.CurrentCamera
            local worldPath = self.props.pathContext.worldPath
            local pathLength = worldPath:length()
            local position = worldPath:pointAtDistance(value * pathLength)
            local direction = worldPath:directionAtDistance(value * pathLength)

            camera.CFrame = CFrame.lookAt(position, position + direction)
        end
    end

    self.onPreviewChanged = function(value)
        self:setState({
            previewChecked = value
        })

        local camera = workspace.CurrentCamera

        if value then
            self.originalCFrame = camera.CFrame
            camera.CameraType = Enum.CameraType.Scriptable
            
            local worldPath = self.props.pathContext.worldPath
            local pathLength = worldPath:length()
            local position = worldPath:pointAtDistance(self.state.distanceSliderValue * pathLength)
            local direction = worldPath:directionAtDistance(self.state.distanceSliderValue * pathLength)

            camera.CFrame = CFrame.lookAt(position, position + direction)
        else
            camera.CameraType = Enum.CameraType.Custom
            camera.CFrame = self.originalCFrame
        end
    end

    self:setState({
        distanceSliderValue = 0,
        previewChecked = false,
        pathEdited = false
    })
end

function EditPathPage:createDistanceSlider()
    local props = {
        sliderLabelContainer = {
            Size = UDim2.new(1, 0, 0.3, 0),
            BackgroundTransparency = 1,
        },

        sliderLabel = {
            Size = UDim2.new(1, 0, 1, 0),
            TextScaled = true,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = string.format("Path Distance %% (%.2f)", self.state.distanceSliderValue),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        },

        sliderContainer = {
            Position = UDim2.new(0, 0, 0.3, 0),
            Size = UDim2.new(1, 0, 0.7, 0),
            BackgroundTransparency = 1,
        },

        container2 = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.85, 0, 0.5, 0),
            BackgroundTransparency = 1,
        },

        slider = {
            value = self.state.distanceSliderValue,
            maxValue = 1,
            onValueChanged = self.onDistanceSliderMoved
        }
    }

    return Roact.createFragment({
        LabelContainer = e("Frame", props.sliderLabelContainer, {
            Label = e("TextLabel", props.sliderLabel)
        }),

        SliderContainer = e("Frame", props.sliderContainer, {
            Container2 = e("Frame", props.container2, {
                Slider = e(Slider, props.slider)
            })
        })
    })
end

function EditPathPage:createCheckboxes()
    local values = { "Preview" }
    local elements = {
        ListLayout = e("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            FillDirection = Enum.FillDirection.Horizontal,
            -- Padding = UDim.new(0.1, 0)
        })
    }

    for _, value in ipairs(values) do
        local props = {
            container = {
                Position = UDim2.new(0.1, 0, 0, 0),
                Size = UDim2.new(0.3, 0, 0.33, 0),
                BackgroundTransparency = 1
            },

            checkboxContainer = {
                -- Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.2, 0, 1, 0),
                BackgroundTransparency = 1
            },

            checkbox = {
                value = self.state.previewChecked,
                onValueChanged = self["on" .. value .. "Changed"]
            },

            label = {
                Position = UDim2.new(0.2, 0, 0, 0),
                Size = UDim2.new(0.8, 0, 1, 0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = value,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }
        }

        -- print("function:", self["onPreviewChanged"])

        local element = e("Frame", props.container, {
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0.05, 0)
            }),

            CheckboxContainer = e("Frame", props.checkboxContainer, {
                Checkbutton = e(Checkbox, props.checkbox)
            }),

            Label = e("TextLabel", props.label),
        })

        elements["CheckButton-" .. value] = element
    end

    return Roact.createFragment(elements)
end

function EditPathPage:createButtons()
    local props = {
        addAnchorButton = {
            size = UDim2.new(0.6, 0, 0.3, 0),
            color = Color3.fromRGB(58, 216, 95),
            text = "Add Anchor",
            onClick = self.onAddAnchorClicked
        },

        deleteAnchorButton = {
            size = UDim2.new(0.6, 0, 0.3, 0),
            color = Color3.fromRGB(253, 104, 104),
            text = "Delete Anchor",
            onClick = self.onDeleteAnchorClicked
        }
    }

    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0.01, 0)
        }),

        AddAnchorButton = e(Button, props.addAnchorButton),
        DeleteAnchorButton = e(Button, props.deleteAnchorButton)
    })
end

function EditPathPage:render()
    local props = {
        pageHeaderContainer = {
            Size = UDim2.new(1, 0, 0.1, 0),
        },

        contentContainer = {
            Position = UDim2.new(0, 0, 0.1, 0),
            Size = UDim2.new(1, 0, 0.9, 0),

            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        },

        distanceSliderContainer = {
            Size = UDim2.new(1, 0, 0.25, 0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(100, 200, 100),
            LayoutOrder = 1
        },

        checkbuttonContainer = {
            Size = UDim2.new(1, 0, 0.25, 0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(110, 100, 200),
            LayoutOrder = 2
        },

        buttonContainer = {
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(200, 198, 100),
            LayoutOrder = 3
        },
    }

    return Roact.createFragment({
        PageHeaderContainer = e("Frame", props.pageHeaderContainer, {
            PageHeader = e(PageHeader, {
                title = self.props.pathContext.pathName .. (self.state.pathEdited and "*" or ""),
                color = Color3.fromRGB(70, 70, 70),
                leftButtons = {
                    e(Button, {
                        anchorPoint = Vector2.new(0, 0.5),
                        position = UDim2.new(0.01, 0, 0.5, 0),
                        size = UDim2.new(0.5, 0, 0.9, 0),
                        -- aspectRatio = 1,
                        text = "<",
                        color = Color3.fromRGB(236, 89, 89),
                        onClick = self.onPreviousPageClicked
                    })
                },

                rightButtons = {
                    e(Button, {
                        anchorPoint = Vector2.new(0, 0.5),
                        position = UDim2.new(0.01, 0, 0.5, 0),
                        size = UDim2.new(1, 0, 1, 0),
                        -- aspectRatio = 1,
                        text = "S",
                        color = Color3.fromRGB(89, 236, 96),
                        onClick = self.onSaveButtonClicked
                    }),

                    e(Button, {
                        anchorPoint = Vector2.new(0, 0.5),
                        position = UDim2.new(0.01, 0, 0.5, 0),
                        size = UDim2.new(1, 0, 1, 0),
                        -- aspectRatio = 1,
                        text = "A",
                        color = Color3.fromRGB(89, 236, 96),
                        onClick = self.onSaveAsButtonClicked
                    }),

                    e(Button, {
                        anchorPoint = Vector2.new(0, 0.5),
                        position = UDim2.new(0.01, 0, 0.5, 0),
                        size = UDim2.new(1, 0, 1, 0),
                        -- aspectRatio = 1,
                        text = "E",
                        color = Color3.fromRGB(233, 196, 34),
                        onClick = self.onExportButtonClicked
                    })
                }
            })
        }),
        
        ContentContainer= e("Frame", props.contentContainer, {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Vertical,
                -- Padding = UDim.new(0.0, 0)
            }),

            DistanceSliderContainer = e("Frame", props.distanceSliderContainer, {
                Content = self:createDistanceSlider()
            }),

            CheckbuttonContainer = e("Frame", props.checkbuttonContainer, {
                Content = self:createCheckboxes()
            }),

            ButtonContainer = e("Frame", props.buttonContainer, {
                Content = self:createButtons()
            })
        }),
    })
end

function EditPathPage:didMount()
    print("Edit Path Page mounted")

    -- create a transparent ball on the path
    local pathTracker = Instance.new("Part")
    pathTracker.Parent = workspace
    pathTracker.Name = "PathTracker"
    pathTracker.CastShadow = false
    pathTracker.Shape = Enum.PartType.Ball
    pathTracker.Size = Vector3.new(2.5, 2.5, 2.5)
    pathTracker.Color =  Color3.fromRGB(13, 105, 172)
    pathTracker.CanCollide = false
    pathTracker.Anchored = true
    pathTracker.Transparency = 0.5

    local worldPath = self.props.pathContext.worldPath
    local position = worldPath:pointAtDistance(0)

    pathTracker.Position = position


    -- This tracker needs to be able to update it's position when the path is altered
    -- and not just update when the slider value is changed
    local worldAnchors = worldPath.worldAnchors
    for _, worldAnchor in ipairs(worldAnchors) do
        -- All these connections will be disconnected when the parts are destroyed
        -- (Leaving the EditPath page) so I'm lazily creating them without keeping
        -- track of the them

        local anchor = worldAnchor.Anchor
        local backHandle = worldAnchor.BackHandle
        local frontHandle = worldAnchor.FrontHandle

        anchor:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)
        backHandle:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)
        frontHandle:GetPropertyChangedSignal("Position"):Connect(self.updatePathTracker)
    end

    self.pathTracker = pathTracker
end

function EditPathPage:didUpdate()
    local worldPath = self.props.pathContext.worldPath
    local pathLength = worldPath:length()

    local distanceSliderValue = self.state.distanceSliderValue
    local desiredDistance = distanceSliderValue * pathLength
    local desiredPosition = worldPath:pointAtDistance(desiredDistance)

    self.pathTracker.Position = desiredPosition
end

function EditPathPage:willUnmount()
    -- do clean up with the world path
    print("Edit Page unmounting")

    if self.pathTracker then
        self.pathTracker:Destroy()
    end
end

return EditPathPage