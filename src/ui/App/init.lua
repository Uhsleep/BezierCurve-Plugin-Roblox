local Root = script:FindFirstAncestorWhichIsA("Script")
local Roact = require(Root.dependencies.Roact)
local e = Roact.createElement

local InitialPage = require(script.Parent.InitialPage)
local NewPathPage = require(script.Parent.NewPathPage)
local LoadPathPage = require(script.Parent.LoadPathPage)
local EditPathPage = require(script.Parent.EditPathPage)
local WorldPathContext = require(script.Parent.worldPathContext)

local Pages = {
    Initial = 1,
    NewPath = 2,
    LoadPath = 3,
    EditPath = 4
}

local App = Roact.Component:extend("App")

function App:init()
    print("Initializing App")
    self.pages = {
        InitialPage,
        NewPathPage,
        LoadPathPage,
        EditPathPage
    }

    self:setState({
        page = Pages.Initial
    })
end

-- Lord help me, I don't know the 'React' way of doing this ;-;
function App:render()
    local page = self.pages[self.state.page]

    return e(WorldPathContext.Consumer, {
        render = function(value)
            return e(page, {
                plugin = value.plugin,
                pathContext = value.pathContext,
                selectedAnchorIndex = value.selectedAnchorIndex,
                
                gotoPage = function(pageId)
                    self:setState({
                        page = pageId
                    })
                end
            })
        end
    })
end

function App:didMount()
    print("App mounted")
end

function App:willUnmount()
    print("App dismounting")
end

return App