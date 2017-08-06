MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
    self.area = Area()

	--[[ bodies ]]--
	bodies = {}
	table.insert(bodies, Body(300, 200, 0, 1.5, 2))
	table.insert(bodies, Body(400, 300, 0, 2, 2))
	table.insert(bodies, Body(500, 400, 0, 1.25, 2))

	default_radius = 25
	selected_radius = 50

	for _, body in ipairs(bodies) do
		body:setRadius(default_radius)
	end
	selected_body = nil
	found_selected_body = false

	--[[ CAMERA ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		speed = 700,
		friction = 0,
		frictionMax = 1,
		frictionSpeed = .05
	}
	selection_range = 25
	bounds = {
		x = player.x - selection_range,
		y = player.y - selection_range,
		width = player.x + selection_range,
		height = player.y + selection_range
	}
	camera = Camera(player.x, player.y)

	--[[ INPUTS ]]--
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

	--[[ CROSSHAIR ]]--
	if found_selected_body then
		love.graphics.setLineWidth(6) -- TODO: Tween here instead of this
	else
		love.graphics.setLineWidth(2)
	end
	love.graphics.setColor(255, 255, 255, 150)
	love.graphics.line((bounds.x + bounds.width) / 2, bounds.y, (bounds.x + bounds.width) / 2, bounds.height)
	love.graphics.line(bounds.x, (bounds.y + bounds.height) / 2, bounds.width, (bounds.y + bounds.height) / 2)
	love.graphics.setLineWidth(1)
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

function MainRoom:inCameraSelectRange(obj)
	if obj.x > bounds.x and obj.y > bounds.y and obj.x < bounds.width and obj.y < bounds.height then
		return true
	else
		return false
	end
end

function MainRoom:bodyUpdate(dt)
	--[[ SELECTION ]]--
	found_selected_body = false

	--[[ MAIN LOOP ]]--
	for i, body in ipairs(bodies) do
		--[[ SELECTION ]]--
		if (MainRoom:inCameraSelectRange(body)) then
			found_selected_body = true
			selected_body = i
		end

		if selected_body == i then
			body:setRadius(selected_radius)
		else
			body:setRadius(default_radius)
		end

		--[[ UPDATE ]]--
		body:update(dt)
	end

	--[[ SELECTION ]]--
	if not found_selected_body then selected_body = nil end
end
