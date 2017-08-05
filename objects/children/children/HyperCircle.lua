HyperCircle = Circle:extend()

function HyperCircle:new(area, x, y, radius, line_width, outer_radius)
	HyperCircle.super.new(self, area, x, y, radius)
	self.line_width, self.outer_radius = line_width, outer_radius
end

function HyperCircle:update(dt)
	HyperCircle.super.update(self, dt)
end

function HyperCircle:draw()
	HyperCircle.super.draw(self)

	love.graphics.setLineWidth(self.line_width)
	love.graphics.circle('line', self.x, self.y, self.outer_radius)

	love.graphics.setLineWidth(1)
end

function HyperCircle:setRadius(new_radius)
	local new_outer_radius = new_radius * 1.5

	timer:tween('radius', 1, hyper_circle, {radius = new_radius}, 'out-elastic')
	timer:tween('outer_radius', 2, hyper_circle, {outer_radius = new_outer_radius}, 'out-elastic')
end
