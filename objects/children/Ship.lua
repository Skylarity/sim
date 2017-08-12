Ship = GameObject:extend()

function Ship:new(x, y, body)
	Ship.super.new(self, x, y)

	self.body = body

	self.angle = 0
end

function Ship:update(dt)
	Ship.super.update(self, dt)

	self.x = self.body.x + math.cos(self.angle) * self.body.outer_radius
	self.y = self.body.y + math.sin(self.angle) * self.body.outer_radius

	self.angle = self.angle + (1 * dt)
end

function Ship:draw()
	Ship.super.draw(self)

	love.graphics.setColor(100, 200, 255, 255)
	love.graphics.circle('fill', self.x, self.y, 10)
end
