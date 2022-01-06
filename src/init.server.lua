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
    local toolbar = plugin:CreateToolbar("Bezier Path")
 
    -- Add a toolbar button named "Create Empty Script"
    local button = toolbar:CreateButton("", "Create Path", "rbxassetid://4458901886")
    -- Make button clickable even if 3D viewport is hidden
    button.ClickableWhenViewportHidden = false


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

    local app = Roact.createElement(WorldPathContext.Provider, {
            value = { plugin = plugin, pathContext = PathContext, selectedObject = nil }
        }, { 
            A = Roact.createElement(App)
    })

    local tree = Roact.mount(app, testWidget, "BezierPathPlugin")

    button.Click:Connect(function()
        testWidget.Enabled = not testWidget.Enabled
        button:SetActive(testWidget.Enabled)
    end)

    plugin.Unloading:Connect(function()
        -- print("PLUGIN UNLOADING")
        PathContext.worldPath:destroy()
        Roact.unmount(tree)
        -- Roact.unmount(tree2)
        -- ScreenGui:Destroy()
    end)

    plugin.Deactivation:Connect(function()
        -- print("PLUGIN DEACTIVATION")
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

        tree = Roact.update(tree, Roact.createElement(WorldPathContext.Provider, {
            value = { plugin = plugin, pathContext = PathContext, selectedAnchorIndex = index }
        }, { 
            A = Roact.createElement(App)
        }))

    end)
end