function lerp(a, b, weight)
    weight = math.clamp(weight, 0, 1)

    return (1 - weight) * a + a * weight
end

local BezierCurve = {}
BezierCurve.__index = BezierCurve

function BezierCurve:length()
    return self._LUT[self._LUTLength]
end

function BezierCurve:pointAtTime(t)
    t = math.clamp(t, 0, 1)
    local oneMinusT = 1 - t

    local a = oneMinusT * oneMinusT * oneMinusT * self.points[1]
    local b = 3 * oneMinusT * oneMinusT * t * self.points[2]
    local c = 3 * oneMinusT * t * t * self.points[3]
    local d = t * t * t * self.points[4]

    return a + b + c + d
end

function BezierCurve:pointAtDistance(s)
    local time = self:_lookUp(s)
    return self:pointAtTime(time)
end

function BezierCurve:updatePoint(index, value)
    self.points[index] = value
end

function BezierCurve:_lookUp(s)
    local time = 0
    for i = 1, self._LUTLength - 1 do
        local lowerDistance = self._LUT[i]
        local upperDistance = self._LUT[i + 1]

        if s >= lowerDistance and s <= upperDistance then
            -- Let's just linearly interpolate a t value from these 2 points
            local weight = (s - lowerDistance) / (upperDistance - lowerDistance)
            local lowerTime = (i - 1) / (self._LUTLength - 1)
            local upperTime = i / (self._LUTLength - 1)
            
            return lerp(lowerTime, upperTime, weight)
        end
    end

    -- s was outside the range of the lookup table
    return s / self:length()
end

--[[
    Sample the bezier curve at evenly distributed times and record
    the total distance into a look up table. The first index of this
    look up table corresponds to the distance traveled at t = 0. Likewise,
    The last index corresponds to the distance traveled at t = 1.
]]
function BezierCurve:updateLUT()
    local previousPoint = self:pointAtTime(0)
    self._LUT[1] = 0

    for i = 2, self._LUTLength do
        local t = (i - 1) / (self._LUTLength - 1)
        local point = self:pointAtTime(t)
        local distance = (point - previousPoint).Magnitude

        self._LUT[i] = self._LUT[i - 1] + distance
        previousPoint = point
    end
end

return function(points)
    assert(type(points) == "table" and #points == 4, "A cubic bezier curve needs 4 points to define the curve.")

    local curve = setmetatable({
        points = {
            points[1],
            points[2],
            points[3],
            points[4]
        },
        
        -- internals
        _LUT = {},
        _LUTLength = 150

    }, BezierCurve)

    curve:updateLUT()

    return curve
end