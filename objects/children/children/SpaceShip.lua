SpaceShip = Vehicle:extend()

function SpaceShip:new(x, y, body, body_id, type)
	SpaceShip.super.new(self, x, y, body, body_id, type)

	if type == 'delivery' then
		self.color = {r = 100, g = 200, b = 255, a = 255}
	end
end

function SpaceShip:update(dt)
	SpaceShip.super.update(self, dt)
end

function SpaceShip:draw()
	SpaceShip.super.draw(self)
end
