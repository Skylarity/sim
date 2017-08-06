HyperCircleRoom = Room:extend()

function HyperCircleRoom:new()
    HyperCircleRoom.super.new(self)
    self.area = Area()

	--[[ PLANETS ]]--
	planets = {}
	table.insert(planets, HyperCircle(300, 200, 0, 0, 2, 1.5))
	table.insert(planets, HyperCircle(400, 300, 0, 0, 2, 2))
	table.insert(planets, HyperCircle(500, 400, 0, 0, 2, 1.25))
	for _, planet in ipairs(planets) do
		planet:setRadius(25)
	end

	--[[ CAMERA ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		speed = 10
	}
	camera = Camera(player.x, player.y)

	--[[ INPUTS ]]--
	input:bind('space', 'circle')
	input:bind('mouse1', 'circle')

	input:bind('up', 'moveUp')
	input:bind('down', 'moveDown')
	input:bind('left', 'moveLeft')
	input:bind('right', 'moveRight')
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

	if (input:down('moveUp')) then player.y = player.y - player.speed end
	if (input:down('moveDown')) then player.y = player.y + player.speed end
	if (input:down('moveLeft')) then player.x = player.x - player.speed end
	if (input:down('moveRight')) then player.x = player.x + player.speed end

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function HyperCircleRoom:draw()
	--[[ BEGIN DRAWING THROUGH CAMERA ]]--
	camera:attach()
	--[[ DRAW WORLD HERE ]]--

	for _, planet in ipairs(planets) do
		planet:draw()
	end

	--[[ END DRAWING THROUGH CAMERA ]]--
	camera:detach()
	--[[ DRAW HUD HERE ]]--

	love.graphics.print("HUD", 10, 10)
end

function HyperCircleRoom:activate()
    -- body
end

function HyperCircleRoom:deactivate()
    -- body
end
