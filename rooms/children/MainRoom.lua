MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
    self.area = Area()

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

	--[[ CAMERA ]]--
	player = {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		xspeed = 0,
		yspeed = 0,
		maxSpeed = 700,
		moving_to_body = false,
		ships = {}
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
	-- Ships
	input:bind('space', 'ship')
end

function MainRoom:update(dt)
	MainRoom:cameraControl(dt)
	MainRoom:bodyUpdate(dt)
	MainRoom:shipUpdate(dt)
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

	for i, ship in ipairs(player.ships) do
		ship:draw()
	end
end

function MainRoom:drawHud()
	--[[ RESET ]]--
	love.graphics.setColor(255, 255, 255, 255)

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
	if input:down('camMoving') then
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

function MainRoom:shipUpdate(dt)
	if input:pressed('ship') and selected_body then
		table.insert(player.ships, Ship(bodies[selected_body].x,
										bodies[selected_body].y,
										bodies[selected_body]))
	end

	for i, ship in ipairs(player.ships) do
		ship:update(dt)
	end
end
