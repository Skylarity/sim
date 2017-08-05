Circle = GameObject:extend()

function Circle:new(area, x, y, radius, opts)
    Circle.super.new(self, area, x, y, opts)
	self.radius = radius
    self.timer:tween(love.math.random(2, 4), self, {radius = 0}, 'in-out-linear')
end

function Circle:update(dt)
    if self.radius <= 0 then self.dead = true end
end

function Circle:draw()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end
