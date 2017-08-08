Body = GameObject:extend()

function Body:new(x, y, radius, outer_radius_multiplier, line_width)
	Body.super.new(self, x, y)
	self.radius, self.line_width, self.outer_radius_multiplier = radius, line_width, outer_radius_multiplier
	self.outer_radius = self.radius * self.outer_radius_multiplier
	self.color = {
		r = (love.math.random() * 155) + 100,
		g = (love.math.random() * 155) + 100,
		b = (love.math.random() * 155) + 100,
		a = 255
	}
end

function Body:update(dt)
	Body.super.update(self, dt)
end

function Body:draw()
	Body.super.draw(self)

	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.setLineWidth(self.line_width)

	love.graphics.circle('fill', self.x, self.y, self.radius)
	love.graphics.circle('line', self.x, self.y, self.outer_radius)

	--[[ CLEANUP ]]--
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255, 255)
end

function Body:setRadius(new_radius)
	local new_outer_radius = new_radius * self.outer_radius_multiplier

	-- TODO: 'out-elastic' might not be working because I'm setting the radius constantly
	self.timer:tween('radius', 1, self, {radius = new_radius}, 'out-elastic')
	self.timer:tween('outer_radius', 2, self, {outer_radius = new_outer_radius}, 'out-elastic')
end
