local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = require(script:FindFirstAncestor("ui").components.pageHeader)
local Button = require(script:FindFirstAncestor("ui").components.button)

local NewPathPage = Roact.Component:extend("NewPathPage")

function NewPathPage:init()
    self.textBoxReference = Roact.createRef()

    self.onPreviousPageClicked = function()
        self.props.gotoPage(4)
    end

    self.onSaveButtonClicked = function()
        -- create a real default path
        local name = self.textBoxReference:getValue().Text
        name = name:gsub(" ", "")
        
        if name:len() == 0 then
            name = "Blank"
        end

        local pathContext = self.props.pathContext
        pathContext.pathName = name
        pathContext:save()

        self.props.gotoPage(4)
    end
end

function NewPathPage:render()
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
            Text = "Save as: ",
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
            BorderSizePixel = 0,

            [Roact.Ref] = self.textBoxReference
        }
    }

    return Roact.createFragment({
        PageHeaderContainer = e("Frame", props.pageHeaderContainer, {
            PageHeader = e(PageHeader, {
                title = "Save As",
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

            FormContainer = e("Frame", {
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0.1, 0)
            }, {
                Label = e("TextLabel", props.textLabel),
                EditText = e("TextBox", props.textBox),
            }),

            CreatePathButton = e("Frame", {
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0.13, 0)
            }, {
                Button = e(Button, {
                    position = UDim2.new(0.5, 0, 0.5, 0),
                    size = UDim2.new(1, 0, 1, 0),
                    text = "Save Path",
                    color = Color3.fromRGB(58, 216, 95),
                    onClick = self.onSaveButtonClicked
                }),
            })

        })
    })
end

function NewPathPage:didMount()
    -- print("New Path Page mounted")
end

function NewPathPage:willUnmount()
    -- print("New Path Page unmounting")
end

return NewPathPage