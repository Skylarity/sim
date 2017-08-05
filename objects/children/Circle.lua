Circle = GameObject:extend()

function Circle:new(area, x, y, radius, opts)
    Circle.super.new(self, area, x, y, opts)
	self.radius = radius
end

function Circle:update(dt)
    -- body
end

function Circle:draw()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end
