Vehicle = GameObject:extend()

function Vehicle:new(x, y, body, body_id, type)
	Vehicle.super.new(self, x, y)

	self.body = body
	self.body_id = body_id

	self.radius = 3

	self.type = type

	self.color = {r = 255, g = 255, b = 255, a = 255}
end

function Vehicle:update(dt)
	Vehicle.super.update(self, dt)
end

function Vehicle:draw()
	Vehicle.super.draw(self)

	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle('fill', self.x, self.y, self.radius)

	--[[ CLEANUP ]]--
	love.graphics.setColor(255, 255, 255, 255)
end
