Circle = GameObject:extend()

function Circle:new(x, y, radius, opts)
    Circle.super.new(self, x, y, opts)
	self.radius = radius
end

function Circle:update(dt)
    Circle.super.update(self, dt)
end

function Circle:draw()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end
