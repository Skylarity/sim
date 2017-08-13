Ship = GameObject:extend()

function Ship:new(x, y, body)
	Ship.super.new(self, x, y)

	self.body = body

	self.angle = 0
	self.min_radius, self.max_radius = 4, 6
	if self.body.selected then self.radius = self.max_radius
	else self.radius = self.min_radius end

	self.color = {r = 100, g = 200, b = 255, a = 255}
end

function Ship:update(dt)
	Ship.super.update(self, dt)

	--[[ ORBIT ]]--
	self.x = self.body.x + math.cos(self.angle) * self.body.outer_radius
	self.y = self.body.y + math.sin(self.angle) * self.body.outer_radius

	self.angle = self.angle + (1 * dt)

	--[[ SELECTION ]]--
	-- if self.body.selection_change then
	-- 	print('selection change')
	-- 	if self.body.selected then
	-- 		self.timer:tween('radius', 1, self, {radius = self.max_radius}, 'out-elastic')
	-- 	else
	-- 		self.timer:tween('radius', 1, self, {radius = self.min_radius}, 'out-elastic')
	-- 	end
	-- end
end

function Ship:draw()
	Ship.super.draw(self)

	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle('fill', self.x, self.y, self.radius)

	--[[ CLEANUP ]]--
	love.graphics.setColor(255, 255, 255, 255)
end
