HyperCircle = Circle:extend()

function HyperCircle:new(x, y, radius, outer_radius, line_width, outer_radius_multiplier)
	HyperCircle.super.new(self, x, y, radius)
	self.outer_radius, self.line_width, self.outer_radius_multiplier = outer_radius, line_width, outer_radius_multiplier
	self.color = {r = (love.math.random() * 105) + 150, g = (love.math.random() * 105) + 150, b = (love.math.random() * 105) + 150, a = 255}
end

function HyperCircle:update(dt)
	HyperCircle.super.update(self, dt)
end

function HyperCircle:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)

	HyperCircle.super.draw(self)

	love.graphics.setLineWidth(self.line_width)

	love.graphics.circle('line', self.x, self.y, self.outer_radius)

	--[[ CLEANUP ]]--
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255, 255)
end

function HyperCircle:setRadius(new_radius)
	local new_outer_radius = new_radius * self.outer_radius_multiplier

	self.timer:tween('radius', 1, self, {radius = new_radius}, 'out-elastic')
	self.timer:tween('outer_radius', 2, self, {outer_radius = new_outer_radius}, 'out-elastic')
end
