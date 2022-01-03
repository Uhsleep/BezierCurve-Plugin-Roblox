local BezierCurve = require(script.Parent.bezierCurve)

local Path = {}
Path.__index = Path

function Path:length()
    local totalDistance = 0
    for _, segment in ipairs(self.segments) do
        totalDistance = totalDistance + segment:length()
    end
    
    return totalDistance
end

--[[
    t here is between [0,1]. This means we need to figure out which segment
    this timme corresponds to and map the time to the time it would be in
    said segment
]]
function Path:pointAtTime(t)
    t = math.clamp(t, 0, 1)

    local numSegments = #self.segments
    local segmentTimeWidth = 1 / numSegments
    local segmentIndex = math.ceil(t / segmentTimeWidth)
    if segmentIndex == 0 then
        segmentIndex = 1 -- the case when t = 0
    end

    -- Need to map this path time to the current segment time  
    local segment = self.segments[segmentIndex]
    local timeInSegment = (t - (segmentIndex - 1) * segmentTimeWidth) / segmentTimeWidth

    -- print("Time:", t)
    -- print("Time in segment:", timeInSegment)

    return segment:pointAtTime(timeInSegment)
end

function Path:pointAtDistance(s)
    if #self.segments == 0 then
        return self.anchors[1].position
    end

    s = math.clamp(s, 0, self:length())

    local segmentIndex = 1
    local numSegments = #self.segments
    local accumulatedDistance = 0

    -- print("Number of segments:", numSegments)
    
    -- figure out which segment we're in based on the given distance s
    for i = 1, numSegments do
        local segment = self.segments[i]
        
        if s < accumulatedDistance + segment:length() then
            segmentIndex = i
            break
        end

        accumulatedDistance = accumulatedDistance + segment:length()
    end

    local segment = self.segments[segmentIndex]
    local segmentDistance = s - accumulatedDistance

    return segment:pointAtDistance(segmentDistance)
end

function Path:updateAnchorPoint(anchorIndex, position)
    local previousPosition = self.anchors[anchorIndex].position
    local delta = position - previousPosition
    
    -- print("before:", self.anchors[anchorIndex])

    -- update anchor position as well as the handles for anchor by delta
    self.anchors[anchorIndex].position = self.anchors[anchorIndex].position + delta
    self.anchors[anchorIndex].handles[1] = self.anchors[anchorIndex].handles[1] + delta
    self.anchors[anchorIndex].handles[2] = self.anchors[anchorIndex].handles[2] + delta
    
    -- print("after:", self.anchors[anchorIndex])

    -- need to update the actual segment objects
    local segments = {
        back = anchorIndex > 1 and self.segments[anchorIndex - 1] or nil,
        front = anchorIndex <= #self.segments and self.segments[anchorIndex] or nil 
    }

    -- print("segments before:", segments)

    if segments.back then
        segments.back:updatePoint(4, self.anchors[anchorIndex].position) --points[4] = self.anchors[anchorIndex].position
        segments.back:updatePoint(3, self.anchors[anchorIndex].handles[1]) --points[3] = self.anchors[anchorIndex].handles[1]
        segments.back:updateLUT()
    end

    if segments.front then
        segments.front:updatePoint(1, self.anchors[anchorIndex].position) --[1] = self.anchors[anchorIndex].position
        segments.front:updatePoint(2, self.anchors[anchorIndex].handles[2]) --.points[2] = self.anchors[anchorIndex].handles[2]
        segments.front:updateLUT()
    end

    -- print("segments after:", segments)
end

function Path:updateHandlePoint(anchorIndex, handleIndex, position)
    -- update both handle positions
    self.anchors[anchorIndex].handles[handleIndex] = position -- first one
    local anchorPosition = self.anchors[anchorIndex].position
    local otherHandleIndex = (handleIndex % 2) + 1
    local normal = (anchorPosition - position).Unit
    local toOtherHandle = self.anchors[anchorIndex].handles[otherHandleIndex] - anchorPosition
    local newPosition = anchorPosition + toOtherHandle.Magnitude * normal
    self.anchors[anchorIndex].handles[otherHandleIndex] = newPosition

    -- update both segments
    local segments = {
        back = anchorIndex > 1 and self.segments[anchorIndex - 1] or nil,
        front = anchorIndex <= #self.segments and self.segments[anchorIndex] or nil 
    }

    -- print("segments before:", segments)

    if segments.back then
        segments.back:updatePoint(3, self.anchors[anchorIndex].handles[1]) --points[3] = self.anchors[anchorIndex].handles[1]
        segments.back:updateLUT()
    end

    if segments.front then
        segments.front:updatePoint(2, self.anchors[anchorIndex].handles[2]) --.points[2] = self.anchors[anchorIndex].handles[2]
        segments.front:updateLUT()
    end

    -- print("segments after:", segments)
end

function Path:addAnchor(anchor)
    table.insert(self.anchors, {
        position = anchor.position,
        handles = {
            anchor.handles[1],
            anchor.handles[2]
        }
    })

    local points = {
        self.anchors[#self.anchors - 1].position,
        self.anchors[#self.anchors - 1].handles[2],
        self.anchors[#self.anchors].handles[1],
        self.anchors[#self.anchors].position
    }

    local newSegment = BezierCurve(points)
    table.insert(self.segments, newSegment)
end

function Path:removeAnchor(anchorIndex)
    local segments = {
        back = anchorIndex > 1 and self.segments[anchorIndex - 1] or nil,
        front = anchorIndex <= #self.segments and self.segments[anchorIndex] or nil 
    }

    if segments.back and segments.front then
        -- remove anchor N and segment N
        table.remove(self.anchors, anchorIndex)
        table.remove(self.segments, anchorIndex)

        -- modify segment N - 1
        local segment = segments.back
        segment:updatePoint(3, self.anchors[anchorIndex].handles[1])
        segment:updatePoint(4, self.anchors[anchorIndex].position)
        segment:updateLUT()

    elseif segments.back then
        table.remove(self.anchors, anchorIndex)
        table.remove(self.segments, anchorIndex - 1)
    elseif segments.front then
        table.remove(self.anchors, anchorIndex)
        table.remove(self.segments, anchorIndex)
    end
end

return function(anchorPoints, controlPoints)
    assert(type(anchorPoints) == "table" and #anchorPoints >= 2, "Anchor points must have at least 2 points")
    assert(#controlPoints == 2 * #anchorPoints, "Each anchor point must have 2 control points.")

    local path = setmetatable({
        segments = {},
        anchors = {}
    }, Path)

    -- create anchor objects
    for i = 1, #anchorPoints do
        table.insert(path.anchors, {
            position = anchorPoints[i],
            handles = {
                controlPoints[2 * i - 1],
                controlPoints[2 * i]
            }
        })
    end

    -- create the bezier curve segments
    for i = 1, #anchorPoints - 1 do
        local points =  {
            path.anchors[i].position,
            path.anchors[i].handles[2],
            path.anchors[i + 1].handles[1],
            path.anchors[i + 1].position
        }

        local segment = BezierCurve(points)
        path.segments[i] = segment
    end

    return path
end