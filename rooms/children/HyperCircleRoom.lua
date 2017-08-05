HyperCircleRoom = Room:extend()

function HyperCircleRoom:new()
    self.super.new(self)
    self.area = Area()

	hyper_circle = HyperCircle(self.area, 400, 300, 50, 2, 100)
	input:bind('mouse1', 'circle')
end

function HyperCircleRoom:update(dt)
	hyper_circle:update(dt)
	if input:pressed('circle') then
		love.graphics.setColor((love.math.random() * 105) + 150, (love.math.random() * 105) + 150, (love.math.random() * 105) + 150, 255)

		local new_radius = (love.math.random() * 25) + 25
		local new_outer_radius = new_radius + (love.math.random() * 10) + 40
		hyper_circle:setRadius(new_radius)
	end
end

function HyperCircleRoom:draw()
    hyper_circle:draw()
end

function HyperCircleRoom:activate()
    -- body
end

function HyperCircleRoom:deactivate()
    -- body
end
