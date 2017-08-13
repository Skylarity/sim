MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
    self.area = Area()

	--[[ FONTS ]]--
	MainRoom.ui_font = love.graphics.newFont(16)

	--[[ SELECTION ]]--
	selected_body = nil

	--[[ BODIES ]]--
	bodies = {}
	for i=1, love.math.random(6, 10) do
		local coords = {
			x = love.math.random(0, love.graphics.getWidth()),
			y = love.math.random(0, love.graphics.getHeight())
		}
		table.insert(bodies, Body(coords.x,
									coords.y,
									25,
									50,
									(love.math.random() + 1.5) - .5,
									2))
	end

	for _, body in ipairs(bodies) do
		body:setRadius(body.default_radius)
	end

	--[[ CAMERA/PLAYER ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		xspeed = 0,
		yspeed = 0,
		maxSpeed = 700,
		moving_to_body = false,
		stations = {},
		resources = {
			minerals = 0,
			farmed_goods = 0
		}
	}
	MainRoom:updateCamBounds()
	camera = Camera(player.x, player.y)

	--[[ RESOURCES ]]--
	timer:every('resources', 1, function()
		for i, station in ipairs(player.stations) do
			player.resources.minerals = player.resources.minerals + (bodies[station.body_id].resources.minerals)
			player.resources.farmed_goods = player.resources.farmed_goods + (bodies[station.body_id].resources.farmland)
		end
	end)

	--[[ CROSSHAIR ]]--
	initial_line_weight = 2
	crosshair = {
		min_line_weight = initial_line_weight,
		max_line_weight = 6,
		line_weight = initial_line_weight
	}

	--[[ INPUTS ]]--
	input:bind('mouse1', 'click')
	-- Camera
	MainRoom:cameraControlsInit()
	-- Stations
	input:bind('space', 'station')
end

function MainRoom:update(dt)
	MainRoom:cameraControl(dt)
	MainRoom:bodyUpdate(dt)
	MainRoom:stationUpdate(dt)
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
	for i, body in ipairs(bodies) do
		if selected_body ~= i then body:draw() end
	end
	if selected_body then bodies[selected_body]:draw() end

	for i, station in ipairs(player.stations) do
		station:draw()
	end
end

function MainRoom:drawHud()
	--[[ RESET ]]--
	love.graphics.setFont(MainRoom.ui_font)
	love.graphics.setColor(255, 255, 255, 255)

	--[[ UI ]]--
	-- Resources
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle('fill', 0, love.graphics.getHeight() - 32, love.graphics.getWidth(), 32)
	love.graphics.setColor(255, 255, 255, 255)
	local resource_string = 'Minerals: ' .. string.format("%.2f", player.resources.minerals) .. " - " .. "Food: " .. string.format("%.2f", player.resources.farmed_goods)
	love.graphics.printf(resource_string, 0, love.graphics.getHeight() - 8 - 16, love.graphics.getWidth(), 'center')

	--[[ CROSSHAIR ]]--
	if selected_body then
		timer:tween('crosshair_line_width', .1, crosshair, {line_weight = crosshair.max_line_weight})
	else
		timer:tween('crosshair_line_width', .1, crosshair, {line_weight = crosshair.min_line_weight})
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
	if selected_body then
		if not player.moving_to_body then
			player.moving_to_body = true
			timer:tween('move_to_body', .2, player, {x = bodies[selected_body].x, y = bodies[selected_body].y}, 'linear', function()
				player.moving_to_body = false
			end)
		end
	end

	if input:released('click') then
		local cx, cy = camera:position()
		local new_x, new_y = 0, 0
		new_x = love.mouse.getX() - (love.graphics.getWidth() / 2) + cx
		new_y = love.mouse.getY() - (love.graphics.getHeight() / 2) + cy
		timer:tween('camera_move_to_click', .2, player, {x = new_x, y = new_y})
	end

	if input:down('camMoving') then
		timer:cancel('camera_move_to_click')
		timer:cancel('move_to_body')
		player.moving_to_body = false
	end

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

function MainRoom:inSelectRange(obj, bounds)
	if obj.x > bounds.x1 and obj.y > bounds.y1 and obj.x < bounds.x2 and obj.y < bounds.y2 then
		return true
	else
		return false
	end
end

function MainRoom:inCameraSelectRange(obj)
	return MainRoom:inSelectRange(obj, cam_bounds)
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
			body:select(true)
		else
			body:select(false)
		end

		--[[ UPDATE ]]--
		body:update(dt)
	end

	--[[ SELECTION ]]--
	if not found_selected_body then
		selected_body = nil
	end
end

function MainRoom:stationUpdate(dt)
	if input:pressed('station') and selected_body then
		table.insert(player.stations, Station(bodies[selected_body].x,
										bodies[selected_body].y,
										bodies[selected_body],
										selected_body))

		--[[ Gross code that auto-spaces the stations out ]]--
		local station_count = 0
		for i, station in ipairs(player.stations) do
			if station.body_id == selected_body then
				station_count = station_count + 1
			end
		end
		local j = 0
		for i, station in ipairs(player.stations) do
			if station.body_id == selected_body then
				j = j + 1
				station.angle = ((math.pi * 2) / station_count) * j
			end
		end
		--[[ /Gross code ]]--
	end

	for i, station in ipairs(player.stations) do
		station:update(dt)
	end
end
