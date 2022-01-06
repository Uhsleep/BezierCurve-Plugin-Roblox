local WorldPath = {
    -- path = nil,

    -- worldPath = nil,
    worldAnchors = {},
    worldSegments = {},
    -- connection = nil,
    -- currentSelectedAnchor = nil
}
WorldPath.__index = WorldPath

local ANCHOR_COLOR = Color3.fromRGB(255, 255, 0)
local HANDLE_COLOR = Color3.fromRGB(255, 0, 0)
local LINK_COLOR = Color3.fromRGB(0, 0, 0)

local ANCHOR_SIZE = 1
local HANDLE_SIZE = 0.75
local LINK_SIZE = 0.2
local SEGMENT_SIZE = 0.75
---------------------------------------------------------------------------------------

--[[
    segment here is a bezier curve object
]]
local function createWorldSegment(segment, segmentIndex)
    local model = Instance.new("Model")
    model.Name = "WorldSegment" .. tostring(segmentIndex)

    -- determine how many segment pieces we should make based 
    -- on the length of the segment
    local maxLengthPerSegment = 3
    local pathLength = segment:length()

    local N = math.ceil(pathLength / maxLengthPerSegment)
    local lengthPerSegment = pathLength / N

    local distance = 0
    for i = 1, N do
        local p1 = segment:pointAtDistance(distance)
        local p2 = segment:pointAtDistance(distance + lengthPerSegment)
        
        local length = (p2 - p1).Magnitude
        local position = (p1 + p2) / 2

        local part = Instance.new("Part")
        part.Parent = model
        part.Name = "SegmentPiece" ..   i
        part.Anchored = true
        part.Transparency = 0.75
        part.CanCollide = false
        part.Size = Vector3.new(SEGMENT_SIZE, SEGMENT_SIZE, length)
        part.CFrame = CFrame.lookAt(position, p2)

        distance = distance + lengthPerSegment
    end

    return model
end

local function createWorldAnchor(anchor, anchorIndex)
    local model = Instance.new("Model")
    model.Name = "WorldAnchor" -- default name

    -- create anchor part
    local anchorPart = Instance.new("Part")
    anchorPart.Name = "Anchor"
    anchorPart.Anchored = true
    anchorPart.CanCollide = false
    anchorPart.Size = Vector3.new(ANCHOR_SIZE, ANCHOR_SIZE, ANCHOR_SIZE)
    anchorPart.Color = ANCHOR_COLOR
    anchorPart.Position = anchor.position
    anchorPart.Parent = model

    -- create handle parts
    local backHandlePart = Instance.new("Part")
    backHandlePart.Name = "BackHandle"
    backHandlePart.Anchored = true
    backHandlePart.CanCollide = false
    backHandlePart.Size = Vector3.new(HANDLE_SIZE, HANDLE_SIZE, HANDLE_SIZE)
    backHandlePart.Color = HANDLE_COLOR
    backHandlePart.Position = anchor.handles[1]
    backHandlePart.Parent = model

    local frontHandlePart = Instance.new("Part")
    frontHandlePart.Name = "FrontHandle"
    frontHandlePart.Anchored = true
    frontHandlePart.CanCollide = false
    frontHandlePart.Size = Vector3.new(HANDLE_SIZE, HANDLE_SIZE, HANDLE_SIZE)
    frontHandlePart.Color = HANDLE_COLOR
    frontHandlePart.Position = anchor.handles[2]
    frontHandlePart.Parent = model

    -- create links from anchor to both handle points
    local length = (anchor.handles[1] - anchor.position).Magnitude
    local backLinkPart = Instance.new("Part")
    backLinkPart.Name = "BackLink"
    backLinkPart.Anchored = true
    backLinkPart.CanCollide = false
    backLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
    backLinkPart.Color = LINK_COLOR
    backLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[1]), anchor.handles[1])
    backLinkPart.Parent = model

    length = (anchor.handles[2] - anchor.position).Magnitude
    local frontLinkPart = Instance.new("Part")
    frontLinkPart.Name = "FrontLink"
    frontLinkPart.Anchored = true
    frontLinkPart.CanCollide = false
    frontLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
    frontLinkPart.Color = LINK_COLOR
    frontLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[2]), anchor.handles[2])
    frontLinkPart.Parent = model

    return model
end

---------------------------------------------------------------------------------------

function WorldPath:_init(path)
    -- Destroy any past World Paths before constructing this one
    if self.worldPath then
        self:destroy()
    end
    
    self.path = path
    self.worldPath = Instance.new("Model")
    self.worldPath.Name = "WorldPath"
    self.worldPath.Parent = workspace

    -- create parts for all anchors and handles
    for index, anchor in ipairs(path.anchors) do
        local worldAnchorModel = createWorldAnchor(anchor)
        worldAnchorModel.Name = "WorldAnchor" .. tostring(index)
        worldAnchorModel.Parent = self.worldPath

        self.worldAnchors[index] = worldAnchorModel
        self:setAnchorVisible(worldAnchorModel, false)
        -- attach the position changed connection
        -- local anchorPart = worldAnchorModel.Anchor
        -- local connectionName = "AnchorPositionChange" .. tostring(index)
        -- if self.connections[connectionName] then
        --     self.connections[connectionName]:Disconnect()
        --     self.connections[connectionName] = nil
        -- end

        -- local anchorConnection = anchorPart:GetPropertyChangedSignal("Position"):Connect(function()
        --     self:updateAnchor(index, anchorPart.Position)
        -- end)

        -- self.connections[connectionName] = anchorConnection
    end

    -- create segment paths to all anchors following the bezier curves
    for index, segment in ipairs(path.segments) do
        local worldSegment = createWorldSegment(segment, index)
        worldSegment.Parent = self.worldPath

        self.worldSegments[index] = worldSegment
    end


end

function WorldPath:updateAnchor(anchorIndex, position)
    print("updating anchor")
    local path = self.path
    
    -- update the path itself
    path:updateAnchorPoint(anchorIndex, position)

    -- update the world anchors and the handles and links
    local anchorModel = self:getWorldAnchor(anchorIndex)
    if anchorModel then
        local anchor = path.anchors[anchorIndex]

        local anchorPart = anchorModel.Anchor
        anchorPart.Position = anchor.position

        local backHandlePart = anchorModel.BackHandle
        backHandlePart.Position = anchor.handles[1]

        local frontHandlePart = anchorModel.FrontHandle
        frontHandlePart.Position = anchor.handles[2]

        -- Couldn't these links automatically be handled using a rod cosntraint or something ?
        local backLinkPart = anchorModel.BackLink
        local length = (anchor.handles[1] - anchor.position).Magnitude
        backLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
        backLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[1]), anchor.handles[1])

        local frontLinkPart = anchorModel.FrontLink
        length = (anchor.handles[2] - anchor.position).Magnitude
        frontLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
        frontLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[2]), anchor.handles[2])

        -- update the segments that connect to this anchor
        self:updateSegment(anchorIndex - 1)
        self:updateSegment(anchorIndex)
    end
end

function WorldPath:setSelectedHandle(anchorIndex, handleIndex)
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end

    local anchorModel = self:getWorldAnchor(anchorIndex)
    if anchorModel then
        self:setAnchorVisible(self.currentSelectedAnchor, false)
        self.currentSelectedAnchor = anchorModel
        self:setAnchorVisible(self.currentSelectedAnchor, true)

        local handlePart = handleIndex == 1 and anchorModel.BackHandle or anchorModel.FrontHandle
        print("Attaching connection to:", handlePart)

        local connection = handlePart:GetPropertyChangedSignal("Position"):Connect(function()
            self:updateHandle(anchorIndex, handleIndex, handlePart.Position)
        end)

        self.connection = connection
    end
end

function WorldPath:setSelectedAnchor(anchorIndex)
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end

    local anchorModel = self:getWorldAnchor(anchorIndex)
    self:setAnchorVisible(self.currentSelectedAnchor, false)
    self.currentSelectedAnchor = anchorModel

    
    if anchorModel then
        -- set the last selected anchor's handles invisible
        self:setAnchorVisible(self.currentSelectedAnchor, true)

        local anchorPart = anchorModel.Anchor
        local connection = anchorPart:GetPropertyChangedSignal("Position"):Connect(function()
            self:updateAnchor(anchorIndex, anchorPart.Position)
        end)

        self.connection = connection
    end 
end

function WorldPath:updateHandle(anchorIndex, handleIndex, position)
    local path = self.path
    path:updateHandlePoint(anchorIndex, handleIndex, position)

    local anchorModel = self:getWorldAnchor(anchorIndex)
    if anchorModel then
        local anchor = path.anchors[anchorIndex]

        if handleIndex == 2 then
            print("Updating backHandlePart?")
            local backHandlePart = anchorModel.BackHandle
            backHandlePart.Position = anchor.handles[1]
        else
            local frontHandlePart = anchorModel.FrontHandle
            frontHandlePart.Position = anchor.handles[2]
        end

        -- Couldn't these links automatically be handled using a rod cosntraint or something ?
        local backLinkPart = anchorModel.BackLink
        local length = (anchor.handles[1] - anchor.position).Magnitude
        backLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
        backLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[1]), anchor.handles[1])

        local frontLinkPart = anchorModel.FrontLink
        length = (anchor.handles[2] - anchor.position).Magnitude
        frontLinkPart.Size = Vector3.new(LINK_SIZE, LINK_SIZE, length)
        frontLinkPart.CFrame = CFrame.lookAt(0.5 * (anchor.position + anchor.handles[2]), anchor.handles[2])

        -- update the segments that connect to this anchor
        self:updateSegment(anchorIndex - 1)
        self:updateSegment(anchorIndex)
    end 
end

function WorldPath:updateSegment(segmentIndex)
    local path = self.path
    local segment = path.segments[segmentIndex]
    if not segment then
        return
    end

    local worldSegment = self:getWorldSegment(segmentIndex)
    if not worldSegment then
        return
    end

    local maxLengthPerSegment = 3
    local pathLength = segment:length()
    local N = #worldSegment:GetChildren()
    local lengthPerSegment = pathLength / N

    if lengthPerSegment >= 1.5 * maxLengthPerSegment or lengthPerSegment <= 0.5 * maxLengthPerSegment then
        -- destroy this segment completely and reconstruct it
        worldSegment:Destroy()
        local newSegment = createWorldSegment(segment, segmentIndex)
        newSegment.Parent = self.worldPath

        self.worldSegments[segmentIndex] = newSegment

    else
        local distance = 0
        for _, part in ipairs(worldSegment:GetChildren()) do
            local p1 = segment:pointAtDistance(distance)
            local p2 = segment:pointAtDistance(distance + lengthPerSegment)
            
            local length = (p2 - p1).Magnitude
            local position = (p1 + p2) / 2

            part.Size = Vector3.new(SEGMENT_SIZE, SEGMENT_SIZE, length)
            part.CFrame = CFrame.lookAt(position, p2)

            distance = distance + lengthPerSegment
        end
    end
end

function WorldPath:setAnchorVisible(worldAnchor, isVisible)
    if not worldAnchor then --or worldAnchor.Parent ~= workspace then
        return
    end

    worldAnchor.BackHandle.Transparency = isVisible and 0 or 1
    worldAnchor.BackLink.Transparency = isVisible and 0 or 1
    worldAnchor.FrontLink.Transparency = isVisible and 0 or 1
    worldAnchor.FrontHandle.Transparency = isVisible and 0 or 1
end

function WorldPath:addAnchorPoint()
    -- The goal here is to add another anchor point at some point in front of the last one
    -- Then create a segment connecting the two

    local lastAnchor = self.path.anchors[#self.path.anchors]
    local toForwardHandle = (lastAnchor.handles[2] - lastAnchor.position).Unit

    local newPosition = lastAnchor.position + 7 * 4 * toForwardHandle
    local handlePosition1 = newPosition - 2 * 4 * toForwardHandle
    local handlePosition2 = newPosition + 2 * 4 * toForwardHandle

    self.path:addAnchor({
        position = newPosition,
        handles = {
            handlePosition1,
            handlePosition2
        }
    })

    -- create a WorldAnchor and a WorldSegment
    local lastIndex = #self.path.anchors
    local worldAnchorModel = createWorldAnchor(self.path.anchors[lastIndex])
    worldAnchorModel.Name = "WorldAnchor" .. tostring(lastIndex)
    worldAnchorModel.Parent = self.worldPath
    table.insert(self.worldAnchors, worldAnchorModel)
    self:setAnchorVisible(worldAnchorModel, false)

    local segment = self.path.segments[lastIndex - 1]
    local worldSegmentModel = createWorldSegment(segment, lastIndex - 1)
    worldSegmentModel.Parent = self.worldPath
    table.insert(self.worldSegments, worldSegmentModel)

    -- lets select this most recent anchor
    self:setSelectedAnchor(lastIndex)
    self:updateModelNames()
end

function WorldPath:removeAnchorPoint(anchorIndex)
    self.path:removeAnchor(anchorIndex)

    -- Remove the necessary WorldSegments and WorldAnchor
    local anchor = self:getWorldAnchor(anchorIndex)
    local frontSegment = self:getWorldSegment(anchorIndex)
    local backSegment = self:getWorldSegment(anchorIndex - 1)

    table.remove(self.worldAnchors, anchorIndex)
    -- anchor:Destroy()

    if frontSegment then
        frontSegment:Destroy()
        table.remove(self.worldSegments, anchorIndex)

        -- The fact that there is a front segment means there is an anchor point ahead of this one
        -- So if we have a back segment, we can just update that back segment to connect to this one
        if backSegment then
            self:updateSegment(anchorIndex - 1)
        end

        -- After removing the anchor from the list, the next anchor is now at
        -- index 'anchorIndex' instead of 'anchorIndex + 1' 
        self:setSelectedAnchor(anchorIndex) --(anchorIndex + 1)
    else
        table.remove(self.worldSegments, anchorIndex - 1)
        backSegment:Destroy()
        
        self:setSelectedAnchor(anchorIndex - 1)
    end
    
    anchor:Destroy()

    self:updateModelNames()
end

function WorldPath:getWorldAnchor(anchorIndex)
    return self.worldAnchors[anchorIndex]
end

function WorldPath:getWorldSegment(segmentIndex)
    return self.worldSegments[segmentIndex]
end

function WorldPath:updateModelNames()
    for index, worldAnchor in ipairs(self.worldAnchors) do
        worldAnchor.Name = "WorldAnchor" .. tostring(index)
    end

    for index, worldSegment in ipairs(self.worldSegments) do
        worldSegment.Name = "WorldSegment" .. tostring(index)
    end
end

function WorldPath:pointAtDistance(distance)
    return self.path:pointAtDistance(distance)
end

function WorldPath:pointAtTime(time)
    return self.path:pointAtTime(time)
end

function WorldPath:directionAtTime(time)
    return self.path:directionAtTime(time)
end

function WorldPath:directionAtDistance(distance)
    return self.path:directionAtDistance(distance)
end

function WorldPath:length()
    return self.path:length()
end

function WorldPath:destroy()
    if self.worldPath then
        self.worldPath:Destroy()
    end

    self.worldPath = nil
    self.connection = nil
    self.path = nil
    self.currentSelectedAnchor = nil
    
    -- print("Clearing tables")
    table.clear(self.worldAnchors)
    table.clear(self.worldSegments)

end

---------------------------------------------------------------------------------------

return WorldPath