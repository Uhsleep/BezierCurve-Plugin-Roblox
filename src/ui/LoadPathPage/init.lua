local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local PageHeader = require(script:FindFirstAncestor("ui").components.pageHeader)
local Button = require(script:FindFirstAncestor("ui").components.button)

local LoadPathPage = Roact.Component:extend("LoadPathPage")

function LoadPathPage:init()
    self.onPreviousPageClicked = function()
        self.props.gotoPage(1)
    end

    self.onScrollingFrameSizeChanged = function(frame)
        -- print("Size changed!")
        self.updateScrollingFrameSize(frame.AbsoluteSize)
    end

    self.onPathItemClicked = function(textLabel, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:setState({
                selectedPath = textLabel.LayoutOrder
            })
        end
    end

    self.onLoadButtonClicked = function()
        local pathName = self.state.paths[self.state.selectedPath].name

        if self.props.pathContext:loadPath(pathName) then
            self.props.gotoPage(4)

            self.props.pathContext:setSelectedAnchor(#self.props.pathContext.worldPath.worldAnchors)
        else
            print("Error loading the path: does it exist?")
        end
    end

    self.onDeleteButtonClicked = function()
        local pathName = self.state.paths[self.state.selectedPath].name
        local settings = self.props.pathContext.Settings

        settings:delete(pathName)

        self:setState({
            selectedPath = Roact.None,
            paths = settings:getPathList(),
        })
    end

    self.scrollingFrameSize, self.updateScrollingFrameSize = Roact.createBinding(Vector2.new(0, 0))

    self:setState({
        paths = {},
        selectedPath = nil
    })
end

function LoadPathPage:render()
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

        scrollingFrame = {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.95, 0, 0.79, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            LayoutOrder = 2,

            [Roact.Change.AbsoluteWindowSize] = self.onScrollingFrameSizeChanged
        },

        buttonContainer = {
            Position = UDim2.new(0, 0, 0.8, 0),
            Size = UDim2.new(1, 0, 0.2, 0),
            LayoutOrder = 3,
            BackgroundTransparency = 1
        },

        loadButton = {
            size = UDim2.new(0.4, 0, 0.7, 0),
            text = "Load",
            color = Color3.fromRGB(200, 126, 30),

            onClick = self.onLoadButtonClicked
        },

        deleteButton = {
            size = UDim2.new(0.4, 0, 0.7, 0),
            text = "Delete",
            color = Color3.fromRGB(253, 104, 104),

            onClick = self.onDeleteButtonClicked
        },
    }

    local children = {
        ListLayout = e("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            FillDirection = Enum.FillDirection.Vertical,
            -- Padding = UDim.new(0.0, 0)
        })
    }

    for index, path in ipairs(self.state.paths) do
        local pathName = path.name
        local childName = "Path-" .. pathName
        local element = e("TextLabel", {
            Size = self.scrollingFrameSize:map(function(val)
                return UDim2.new(1, 0, 0, 0.1 * val.Y)
            end),

            Text = pathName,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextScaled = true,
            LayoutOrder = index,

            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            BackgroundTransparency = self.state.selectedPath == index and 0 or 1,
            
            [Roact.Event.InputBegan] = self.onPathItemClicked
        })

        children[childName] = element
    end

    local loadButton, deleteButton
    -- print(self.state.selectedPath)
    if self.state.selectedPath then
        loadButton = e(Button, props.loadButton)
        deleteButton = e(Button, props.deleteButton)
    end

    return Roact.createFragment({
        PageHeaderContainer = e("Frame", props.pageHeaderContainer, {
            PageHeader = e(PageHeader, {
                title = "Load Path",
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

        ContentContainer= e("Frame", props.contentContainer, {
            ListLayout = e("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Vertical,
                -- Padding = UDim.new(0.0, 0)
            }),

            -- Only here for the padding
            PaddingFrame = e("Frame", {
                Size = UDim2.new(1, 0, 0.01, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 1
            }),

            ScrollingFrame = e("ScrollingFrame", props.scrollingFrame, children),

            ButtonContainer = e("Frame", props.buttonContainer, {
                ListLayout = e("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                }),

                LoadButton = loadButton,
                DeleteButton = deleteButton
            })
        }),
    })
end

function LoadPathPage:didMount()    
    self:setState({
        paths = self.props.pathContext.Settings:getPathList()
    })
end

function LoadPathPage:willUnmount()
    -- print("Load Path Page unmounting")
end

return LoadPathPage