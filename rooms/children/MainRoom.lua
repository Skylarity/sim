MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
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
	-- Planet
	input:bind('space', 'circle')
	input:bind('mouse1', 'circle')

	-- Camera
	MainRoom:cameraControls()
end

function MainRoom:update(dt)
	--[[ PLANET RENDERING ]]--
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

	--[[ CAMERA CONTROLS ]]--
	if (input:down('camUp')) then player.y = player.y - player.speed end
	if (input:down('camDown')) then player.y = player.y + player.speed end
	if (input:down('camLeft')) then player.x = player.x - player.speed end
	if (input:down('camRight')) then player.x = player.x + player.speed end

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function MainRoom:draw()
	camera:draw(MainRoom.drawWorld)
	MainRoom.drawHud()
end

function MainRoom:activate()
    -- body
end

function MainRoom:deactivate()
    -- body
end

function MainRoom:drawWorld()
	for _, planet in ipairs(planets) do
		planet:draw()
	end
end

function MainRoom:drawHud()
	love.graphics.print("HUD", 10, 10)
end

function MainRoom:cameraControls()
	input:bind('up', 'camUp')
	input:bind('down', 'camDown')
	input:bind('left', 'camLeft')
	input:bind('right', 'camRight')
	input:bind('w', 'camUp')
	input:bind('s', 'camDown')
	input:bind('a', 'camLeft')
	input:bind('d', 'camRight')
end
