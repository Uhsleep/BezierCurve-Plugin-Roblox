local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local StarterGui = game:GetService("StarterGui")

local Roact = require(script.dependencies.Roact)
local App = require(script.ui.App)
local BezierCurve = require(script.types.bezierCurve)
local Path = require(script.types.path)
local WorldPath = require(script.worldPath)
local getter = require(script.getter)

local WorldPathContext = require(script.ui.worldPathContext)

if plugin then
    if not RunService:IsEdit() then
        return
    end

    -- Entry point for plugin loading
    -- Create the ToolBar (Just one button enabling/disabling our GUI)

    print("RUNNING AS PLUGIN")
    local toolbar = plugin:CreateToolbar("Bezier Path")
 
    -- Add a toolbar button named "Create Empty Script"
    local button = toolbar:CreateButton("", "Create Path", "rbxassetid://4458901886")
    -- Make button clickable even if 3D viewport is hidden
    button.ClickableWhenViewportHidden = false
    local visible = false

    local widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
        true,   -- Widget will be initially enabled
        false,  -- Don't override the previous enabled state
        200,    -- Default width of the floating window
        300,    -- Default height of the floating window
        150,    -- Minimum width of the floating window
        150     -- Minimum height of the floating window
    )
 
    -- Create new widget GUI
    local testWidget = plugin:CreateDockWidgetPluginGui("TestWidget", widgetInfo)
    testWidget.Title = "Bezier Paths"
    testWidget:BindToClose(function()
        testWidget.Enabled = false
        button:setActive(false)
    end)
    
    local PathContext = require(script.pathContext)
    PathContext:init(plugin)

    ------------------ SAVE TEST ------------------------

    local R = 30
    local C = R / 2
    local points = {
        anchor = {
            Vector3.new(R, 2, 0),
            Vector3.new(0, 2, R),
            Vector3.new(-R, 2, 0),
            Vector3.new(0, 2, -R),
            -- Vector3.new(R, 2, 0) -- loop back around with itself (should add support for this internally but w/e)
        },

        control = {
            Vector3.new(R, 2, -C),
            Vector3.new(R, 2, C),

            Vector3.new(C, 2, R),
            Vector3.new(-C, 2, R),

            Vector3.new(-R, 2, C),
            Vector3.new(-R, 2, -C),

            Vector3.new(-C, 2, -R),
            Vector3.new(C, 2, -R),

            -- Vector3.new(R, 2, -C),
            -- Vector3.new(R, 2, C)
        }
    }



    -- local curve = BezierCurve({
    --     points.anchor[1],
    --     points.control[2],
    --     points.control[3],
    --     points.anchor[2]
    -- })
    local path = Path(points.anchor, points.control)
    PathContext.Settings:save("circle", path)
    print("LOADING PATH BACK")
    local loadedPath  =PathContext.Settings:load("circle")
    print("loadedPath:", loadedPath)
    --------------------------------------------------------------------

    local app = Roact.createElement(WorldPathContext.Provider, {
            value = { plugin = plugin, pathContext = PathContext, selectedObject = nil }
        }, { 
            A = Roact.createElement(App)
    })

    local tree = Roact.mount(app, testWidget, "BezierPathPlugin")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = StarterGui
    local tree2 = Roact.mount(app, ScreenGui, "BezierPathPlugin2")

    for _, child in ipairs(testWidget:GetChildren()) do
        print("child:", child)
    end

    button.Click:Connect(function()
        testWidget.Enabled = not testWidget.Enabled
        button:SetActive(testWidget.Enabled)
    end)

    plugin.Unloading:Connect(function()
        print("PLUGIN UNLOADING")
        PathContext.worldPath:destroy()
        Roact.unmount(tree)
        Roact.unmount(tree2)
        ScreenGui:Destroy()
    end)

    plugin.Deactivation:Connect(function()
        print("PLUGIN DEACTIVATION")
        PathContext.worldPath:destroy()
    end)

    Selection.SelectionChanged:Connect(function()
        local objects = Selection:Get()
        local index
        
        if not PathContext.worldPath then
            return
        end

        if #objects > 0 then
            -- Selection:Set({objects[1]})
            -- To handle, multiple selections, we will only ever consider the very first
            local selectedObj = objects[1]
            local parent = selectedObj.Parent

            -- check if it is a child of a WorldAnchor
            if parent.Name:match("WorldAnchor") then
                index = tonumber(parent.Name:sub(-1, -1))

                -- now we will check if the part is handle or anchor
                if selectedObj.Name == "Anchor" then
                    PathContext.worldPath:setSelectedAnchor(index)
                elseif selectedObj.Name == "BackHandle" or selectedObj.Name == "FrontHandle" then
                    local handleIndex = selectedObj.Name == "BackHandle" and 1 or 2
                    PathContext.worldPath:setSelectedHandle(index, handleIndex)
                end
            end
        end
        -- else
        --     PathContext.worldPath:setSelectedAnchor(nil)
        -- end

        print("Updating selection tree with index:", index)
        tree = Roact.update(tree, Roact.createElement(WorldPathContext.Provider, {
            value = { plugin = plugin, pathContext = PathContext, selectedAnchorIndex = index }
        }, { 
            A = Roact.createElement(App)
        }))

        -- tree2 = Roact.update(tree2, Roact.createElement(WorldPathContext.Provider, {
        --     value = { plugin = plugin, pathContext = PathContext, selectedAnchorIndex = index }
        -- }, { 
        --     A = Roact.createElement(App)
        -- }))
    end)
else
    local R = 30
    local C = R / 2
    local points = {
        anchor = {
            Vector3.new(R, 2, 0),
            Vector3.new(0, 2, R),
            Vector3.new(-R, 2, 0),
            Vector3.new(0, 2, -R),
            -- Vector3.new(R, 2, 0) -- loop back around with itself (should add support for this internally but w/e)
        },

        control = {
            Vector3.new(R, 2, -C),
            Vector3.new(R, 2, C),

            Vector3.new(C, 2, R),
            Vector3.new(-C, 2, R),

            Vector3.new(-R, 2, C),
            Vector3.new(-R, 2, -C),

            Vector3.new(-C, 2, -R),
            Vector3.new(C, 2, -R),

            -- Vector3.new(R, 2, -C),
            -- Vector3.new(R, 2, C)
        }
    }



    -- local curve = BezierCurve({
    --     points.anchor[1],
    --     points.control[2],
    --     points.control[3],
    --     points.anchor[2]
    -- })
    local path = Path(points.anchor, points.control)
    WorldPath:_init(path)
    -- worldPath:setSelectedHandle(1, 1)

    local SelectionRE = ReplicatedStorage.Selection
    SelectionRE.Event:Connect(function(name, anchorIndex, handleIndex)
        if name == "anchor" then
            WorldPath:setSelectedAnchor(anchorIndex)
        elseif name == "handle" then
            WorldPath:setSelectedHandle(anchorIndex, handleIndex)
        elseif name == "add" then
            WorldPath:addAnchorPoint()
        elseif name == "delete" then
            WorldPath:removeAnchorPoint(anchorIndex)
        else
            print("Ummmm.....??")
        end
    end)
    

    -- Path follower part
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Color = Color3.fromRGB(58, 224, 91)
    part.Parent = workspace
    part.Anchored = true

    local totalTime = 0
    local speed = 5
    local totalDistance = 0
    local Y = 8

    local connection = RunService.Heartbeat:Connect(function(dt)
        -- print("Total Distance:", totalDistance)
        -- print("Total Time:", totalTime)

        part.Position = path:pointAtDistance(totalDistance)

        totalDistance = totalDistance + speed * dt
        if totalDistance > path:length() then
            totalDistance = 0
        end

        -- part.Posiition = curve:pointAtTime(totalTime / 10)
        -- totalTime = totalTime + dt
        -- if totalTime > 10 then
        --     totalTime = 0
        -- end
    end)

end