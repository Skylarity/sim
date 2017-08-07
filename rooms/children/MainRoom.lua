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

	--[[ CAMERA ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		xspeed = 0,
		yspeed = 0,
		maxSpeed = 700
	}
	selection_range = 25
	cam_bounds = {
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
	if selected_body then
		love.graphics.setLineWidth(6) -- TODO: Tween here instead of this
	else
		love.graphics.setLineWidth(2)
	end
	love.graphics.setColor(255, 255, 255, 150)
	love.graphics.line((cam_bounds.x + cam_bounds.width) / 2, cam_bounds.y, (cam_bounds.x + cam_bounds.width) / 2, cam_bounds.height)
	love.graphics.line(cam_bounds.x, (cam_bounds.y + cam_bounds.height) / 2, cam_bounds.width, (cam_bounds.y + cam_bounds.height) / 2)
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
	local camera_acceleration = .2
	if (input:down('camLeft')) then timer:tween('camera_speed_l', camera_acceleration, player, {xspeed = -(player.maxSpeed)}, 'linear') end
	if (input:down('camRight')) then timer:tween('camera_speed_r', camera_acceleration, player, {xspeed = player.maxSpeed}, 'linear') end
	if (input:down('camUp')) then timer:tween('camera_speed_u', camera_acceleration, player, {yspeed = -(player.maxSpeed)}, 'linear') end
	if (input:down('camDown')) then timer:tween('camera_speed_d', camera_acceleration, player, {yspeed = player.maxSpeed}, 'linear') end
	if not input:down('camLeft') and not input:down('camRight') then
		timer:tween('camera_speed_l', camera_acceleration, player, {xspeed = 0}, 'linear')
		timer:tween('camera_speed_r', camera_acceleration, player, {xspeed = 0}, 'linear')
	end
	if not input:down('camUp') and not input:down('camDown') then
		timer:tween('camera_speed_u', camera_acceleration, player, {yspeed = 0}, 'linear')
		timer:tween('camera_speed_d', camera_acceleration, player, {yspeed = 0}, 'linear')
	end
	player.x = player.x + (player.xspeed * dt)
	player.y = player.y + (player.yspeed * dt)

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function MainRoom:inCameraSelectRange(obj)
	if obj.x > cam_bounds.x and obj.y > cam_bounds.y and obj.x < cam_bounds.width and obj.y < cam_bounds.height then
		return true
	else
		return false
	end
end

function MainRoom:bodyUpdate(dt)
	--[[ SELECTION ]]--
	local found_selected_body = false

	--[[ MAIN LOOP ]]--
	for i, body in ipairs(bodies) do
		--[[ SELECTION ]]--
		if not found_selected_body and (MainRoom:inCameraSelectRange(body)) then
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
