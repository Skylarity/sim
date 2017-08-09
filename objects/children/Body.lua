Body = GameObject:extend()

function Body:new(x, y, default_radius, selected_radius, outer_radius_multiplier, line_width)
	Body.super.new(self, x, y)
	self.radius, self.line_width, self.outer_radius_multiplier = 0, line_width, outer_radius_multiplier
	self.outer_radius = self.radius * self.outer_radius_multiplier
	self.color = {
		r = (love.math.random() * 155) + 100,
		g = (love.math.random() * 155) + 100,
		b = (love.math.random() * 155) + 100,
		a = 255
	}

	self.selected = false
	self.default_radius, self.selected_radius = default_radius, selected_radius
	self.setting_radius, self.setting_outer_radius = false, false
end

function Body:update(dt)
	Body.super.update(self, dt)

	if self.selected then
		self:setRadius(self.selected_radius)
	else
		self:setRadius(self.default_radius)
	end
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

	if not self.setting_radius and not self.setting_outer_radius then
		self.setting_radius = true
		self.setting_outer_radius = true

		self.timer:tween('radius', 1, self, {radius = new_radius}, 'out-elastic', function() self.setting_radius = false end)
		self.timer:tween('outer_radius', 2, self, {outer_radius = new_outer_radius}, 'out-elastic', function() self.setting_outer_radius = false end)
	end
end
