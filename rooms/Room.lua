Room = Object:extend()

function Room:new()
    self.areas = {}
    self.timer = Timer()
end

function Room:update(dt)
    if self.timer then self.timer:update(dt) end
end

function Room:draw()
    -- body
end

function Room:activate()
    -- body
end

function Room:deactivate()
    -- body
end

function Room:addArea(area)
    table.insert(self.areas, area)
end
