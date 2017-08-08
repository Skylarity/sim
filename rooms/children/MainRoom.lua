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
	MainRoom:updateCamBounds()
	camera = Camera(player.x, player.y)

	--[[ CROSSHAIR ]]--
	initial_line_weight = 2
	crosshair = {
		min_line_weight = initial_line_weight,
		max_line_weight = 6,
		line_weight = initial_line_weight
	}

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
	love.graphics.print(cam_bounds.x1 .. " " .. cam_bounds.y1 .. " " .. cam_bounds.x2 .. " " .. cam_bounds.y2)

	--[[ CROSSHAIR ]]--
	if selected_body then
		timer:tween('crosshair_line_width', 1, crosshair, {line_weight = crosshair.max_line_weight}, 'out-elastic')
	else
		timer:tween('crosshair_line_width', 1, crosshair, {line_weight = crosshair.min_line_weight}, 'out-elastic')
	end
	love.graphics.setLineWidth(crosshair.line_weight)
	love.graphics.setColor(255, 255, 255, 150)
	love.graphics.rectangle('line', (love.graphics.getWidth() / 2) - selection_range, (love.graphics.getHeight() / 2) - selection_range, selection_range * 2, selection_range * 2)
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
	MainRoom:updateCamBounds()

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function MainRoom:inCameraSelectRange(obj)
	if obj.x > cam_bounds.x1 and obj.y > cam_bounds.y1 and obj.x < cam_bounds.x2 and obj.y < cam_bounds.y2 then
		return true
	else
		return false
	end
end

function MainRoom:updateCamBounds()
	selection_range = 25
	cam_bounds = {
		x1 = player.x - selection_range,
		y1 = player.y - selection_range,
		x2 = player.x + selection_range,
		y2 = player.y + selection_range
	}
end

function MainRoom:bodyUpdate(dt)
	--[[ SELECTION ]]--
	found_selected_body = false

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
