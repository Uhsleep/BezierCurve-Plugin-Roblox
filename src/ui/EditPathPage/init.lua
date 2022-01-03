local Selection = game:GetService("Selection")

local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = require(script:FindFirstAncestor("ui").components.pageHeader)
local Button = require(script:FindFirstAncestor("ui").components.button)

local EditPathPage = Roact.Component:extend("EditPathPage")

function EditPathPage:init(props)
    print("Edit Page init - path context name:", props.pathContext.pathName)

    self.onSaveClicked = function()
        -- save this path to the plugin settings
    end

    self.onExportClicked = function()
        -- save file here too

        -- open a newly created module script and paste a table containing the necessary
        -- values and show the user

    end

    self.onPreviousPageClicked = function()
        -- force save path
        self.onSaveClicked()

        self.props.pathContext.worldPath:destroy()
        self.props.gotoPage(1)
    end

    self.onAddAnchorClicked = function()
        self.props.pathContext.worldPath:addAnchorPoint()
        self.props.pathContext:setSelectedAnchor(#self.props.pathContext.worldPath.worldAnchors)
    end

    self.onDeleteAnchorClicked = function()
        local index = self.props.selectedAnchorIndex
        self.props.pathContext.worldPath:removeAnchorPoint(index)
        
        if self.props.pathContext.worldPath.currentSelectedAnchor then
            Selection:Set({ self.props.pathContext.worldPath.currentSelectedAnchor.Anchor })
        end
    end
end

function EditPathPage:render()
    print("Selected Anchor Index:", self.props.selectedAnchorIndex)

    local props = {
        pageHeaderContainer = {
            Size = UDim2.new(1, 0, 0.1, 0),
        },

        buttonContainer = {
            Position = UDim2.new(0, 0, 0.1, 0),
            Size = UDim2.new(1, 0, 0.9, 0),

            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        },

        textLabel = {
            Size = UDim2.new(0.3, 0, 1, 0),
            BackgroundTransparency = 1,

            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            BorderSizePixel = 0,
            Text = "Path Name: ",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true
        },

        textBox = {
            Position = UDim2.new(0.3, 0, 0, 0),
            Size = UDim2.new(0.7, 0, 0.8, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),

            Text = "",
            MultiLine = false,
            ClearTextOnFocus = false,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            -- BorderMode = Enum.BorderMode.Inset,
            BorderSizePixel = 0
        }
    }

    local deleteButtonContainer
    if self.props.selectedAnchorIndex then
        deleteButtonContainer = e("Frame", {
            LayoutOrder = 2,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.75, 0, 0.13, 0)
        }, {
            Button = e(Button, {
                position = UDim2.new(0.5, 0, 0.5, 0),
                size = UDim2.new(1, 0, 1, 0),
                text = "Delete Anchor",
                color = Color3.fromRGB(216, 58, 58),
                onClick = self.onDeleteAnchorClicked
            }),
        })
    end

    return Roact.createFragment({
        PageHeaderContainer = e("Frame", props.pageHeaderContainer, {
            PageHeader = e(PageHeader, {
                title = self.props.pathContext.pathName,
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
                }
            })
        }),

        ButtonContainer = e("Frame", props.buttonContainer, {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0.01, 0)
            }),

            AddAnchorButton = e("Frame", {
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0.13, 0)
            }, {
                Button = e(Button, {
                    position = UDim2.new(0.5, 0, 0.5, 0),
                    size = UDim2.new(1, 0, 1, 0),
                    text = "Add Anchor",
                    color = Color3.fromRGB(58, 216, 95),
                    onClick = self.onAddAnchorClicked
                }),
            }),

            DeleteAnchorButton = deleteButtonContainer
        })
    })
end

function EditPathPage:didMount()
    print("Edit Path Page mounted")
end

function EditPathPage:willUnmount()
    -- do clean up with the world path
    print("Initial Page unmounting")
end

return EditPathPage