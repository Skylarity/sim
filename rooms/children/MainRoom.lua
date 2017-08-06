MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
    self.area = Area()

	--[[ bodies ]]--
	bodies = {}
	table.insert(bodies, Body(300, 200, 0, 1.5, 2))
	table.insert(bodies, Body(400, 300, 0, 2, 2))
	table.insert(bodies, Body(500, 400, 0, 1.25, 2))
	for _, body in ipairs(bodies) do
		body:setRadius(25)
	end

	--[[ CAMERA ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		speed = 700,
		friction = 0,
		frictionMax = 1,
		frictionSpeed = .05
	}
	camera = Camera(player.x, player.y)

	--[[ INPUTS ]]--
	-- body
	input:bind('space', 'circle')
	input:bind('mouse1', 'circle')

	-- Camera
	MainRoom:cameraControlsInit()
end

function MainRoom:update(dt)
	MainRoom:cameraControl(dt)
	MainRoom:bodyUpdate(dt)
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
	for _, body in ipairs(bodies) do
		body:draw()
	end
end

function MainRoom:drawHud()
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 100)
	love.graphics.setColor(255, 255, 255, 255)
	for i, body in ipairs(bodies) do
		love.graphics.print("Body " .. i .. " radius - " .. string.format("%.2f", body.radius), 10, i * 16)
	end
end

function MainRoom:cameraControlsInit()
	local cameraControlButtons = {
		'up',
		'down',
		'left',
		'right',
		'w',
		's',
		'a',
		'd'
	}

	input:bind('up', 'camUp')
	input:bind('down', 'camDown')
	input:bind('left', 'camLeft')
	input:bind('right', 'camRight')
	input:bind('w', 'camUp')
	input:bind('s', 'camDown')
	input:bind('a', 'camLeft')
	input:bind('d', 'camRight')

	for _, control in ipairs(cameraControlButtons) do
		input:bind(control, 'camMoving')
	end
end

function MainRoom:cameraControl(dt)
	if (input:down('camMoving')) then
		if player.friction < player.frictionMax then
			player.friction = player.friction + player.frictionSpeed
		end
	else
		if player.friction > 0 then
			player.friction = player.friction - player.frictionSpeed
		end
		if player.friction < 0 then player.friction = 0 end
	end
	if (input:down('camUp')) then player.y = player.y - (player.speed * player.friction * dt) end
	if (input:down('camDown')) then player.y = player.y + (player.speed * player.friction * dt) end
	if (input:down('camLeft')) then player.x = player.x - (player.speed * player.friction * dt) end
	if (input:down('camRight')) then player.x = player.x + (player.speed * player.friction * dt) end

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function MainRoom:bodyUpdate(dt)
	local pressed = false
	if input:pressed('circle') then
		pressed = true
	else
		pressed = false
	end

	for _, body in ipairs(bodies) do
		body:update(dt)

		if pressed then
			local new_radius = (love.math.random() * 25) + 25
			local new_outer_radius = new_radius + (love.math.random() * 10) + 40
			body:setRadius(new_radius)
		end
	end
end
