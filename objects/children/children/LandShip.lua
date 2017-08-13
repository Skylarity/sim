LandShip = Vehicle:extend()

function LandShip:new(x, y, body, body_id, type)
	LandShip.super.new(self, x, y, body, body_id, type)

	if type == 'miner' then
		self.color = {r = 200, g = 150, b = 150, a = 255}
	elseif type == 'farmer' then
		self.color = {r = 255, g = 200, b = 200, a = 255}
	end
end

function LandShip:update(dt)
	LandShip.super.update(self, dt)
end

function LandShip:draw()
	LandShip.super.draw(self)
end
