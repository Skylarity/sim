HyperCircleRoom = Room:extend()

function HyperCircleRoom:new()
    HyperCircleRoom.super.new(self)
    self.area = Area()

	planets = {}
	table.insert(planets, HyperCircle(300, 200, 0, 0, 2, 1.5))
	table.insert(planets, HyperCircle(400, 300, 0, 0, 2, 2))
	table.insert(planets, HyperCircle(500, 400, 0, 0, 2, 1.25))
	for _, planet in ipairs(planets) do
		planet:setRadius(25)
	end

	input:bind('mouse1', 'circle')
end

function HyperCircleRoom:update(dt)
	local pressed = false
	if input:pressed('circle') then
		pressed = true
	else
		pressed = false
	end

	for _, planet in ipairs(planets) do
		planet:update(dt)

		if pressed then
			local new_radius = (love.math.random() * 25) + 25
			local new_outer_radius = new_radius + (love.math.random() * 10) + 40
			planet:setRadius(new_radius)
		end
	end
end

function HyperCircleRoom:draw()
	for _, planet in ipairs(planets) do
		planet:draw()
	end
end

function HyperCircleRoom:activate()
    -- body
end

function HyperCircleRoom:deactivate()
    -- body
end
