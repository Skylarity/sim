HyperCircleRoom = Room:extend()

function HyperCircleRoom:new()
    self.super.new(self)
    self.area = Area()

	hyper_circle = HyperCircle(area, 400, 300, 50, 2, 100)
	input:bind('mouse1', 'circle')
end

function HyperCircleRoom:update(dt)
	hyper_circle:update(dt)
	if input:pressed('circle') then
		local new_radius = love.math.random() * 25 + 25
		local new_outer_radius = new_radius + love.math.random() * 10 + 40
		timer:tween('radius', 1, hyper_circle, {radius = new_radius}, 'out-elastic')
		timer:tween('outer_radius', 2, hyper_circle, {outer_radius = new_outer_radius}, 'out-elastic')
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
