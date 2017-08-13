MainRoom = Room:extend()

function MainRoom:new()
    MainRoom.super.new(self)
    self.area = Area()

	--[[ FONTS ]]--
	ui_font_size = 16
	MainRoom.ui_font = love.graphics.newFont('fonts/RobotoMono-Bold.ttf', ui_font_size)
	love.graphics.setFont(MainRoom.ui_font)

	--[[ INPUTS ]]--
	input:bind('mouse1', 'click')
	-- Camera
	MainRoom:cameraControlsInit()
	-- Stations
	input:bind('space', 'station')

	--[[ CAMERA/PLAYER ]]--
	world = {
		bounds = {
			x1 = 0,
			y1 = 0,
			x2 = 2000,
			y2 = 2000
		}
	}
	player = {
		x = world.bounds.x2 / 2,
		y = world.bounds.y2 / 2,
		xspeed = 0,
		yspeed = 0,
		maxSpeed = 700,
		moving_to_body = false,
		stations = {},
		resources = {
			minerals = 0,
			farmed_goods = 0
		},
		found_bodies = {}
	}
	MainRoom:updateCamBounds()
	camera = Camera(player.x, player.y)
	local s_crt = shine.crt()
	local s_filmgrain = shine.filmgrain({
		opacity = 0.24
	})
	local s_scanlines = shine.scanlines()
	local s_sep_chroma = shine.separate_chroma({
		angle = math.rad(45),
		radius = 2.5
	})
	cam_effects = s_filmgrain:chain(s_sep_chroma):chain(s_scanlines):chain(s_crt)

	--[[ MOUSE ]]--
	love.mouse.setVisible(false)
	mouse_radius = 4

	--[[ CROSSHAIR ]]--
	initial_line_weight = 2
	crosshair = {
		min_line_weight = initial_line_weight,
		max_line_weight = 6,
		line_weight = initial_line_weight,
		color = {r = 255, g = 255, b = 255, a = 150}
	}

	--[[ RESOURCES ]]--
	timer:every('resources', 1, function()
		for i, station in ipairs(player.stations) do
			player.resources.minerals = player.resources.minerals + (bodies[station.body_id].resources.minerals)
			player.resources.farmed_goods = player.resources.farmed_goods + (bodies[station.body_id].resources.farmland)
		end
	end)

	--[[ SELECTION ]]--
	selected_body = nil

	--[[ BODIES ]]--
	body_default_radius, body_selected_radius = 50, 75
	bodies = {}
	for i=1, 10 do
		local body = Body(0, -- x
			0, -- y
			body_default_radius, -- default radius
			body_selected_radius, -- selected radius
			2, -- outer radius multiplier
			2) -- line width

		local coords, coords_conflict = nil, nil
		repeat
			coords = {
				x = love.math.random(world.bounds.x1, world.bounds.x2),
				y = love.math.random(world.bounds.y1, world.bounds.y2)
			}
			local buffer = body_selected_radius * 4
			local bounds = {
				x1 = coords.x - buffer,
				y1 = coords.y - buffer,
				x2 = coords.x + buffer,
				y2 = coords.y + buffer
			}

			for i, other_body in ipairs(bodies) do
				if MainRoom:inSelectRange(other_body, bounds) then
					coords_conflict = true
					break
				else
					coords_conflict = false
				end
			end
		until not coords_conflict

		body.x = coords.x
		body.y = coords.y
		table.insert(bodies, body)
	end

	for _, body in ipairs(bodies) do
		body:setRadius(body.default_radius)
	end
end

function MainRoom:update(dt)
	MainRoom:cameraControl(dt)
	MainRoom:bodyUpdate(dt)
	MainRoom:stationUpdate(dt)
end

function MainRoom:draw()
	cam_effects:draw(function()
		camera:draw(MainRoom.drawWorld)
		MainRoom.drawHud()
	end)
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
	-- love.graphics.setFont(MainRoom.ui_font)
	love.graphics.setColor(255, 255, 255, 255)

	local width, width_half = love.graphics.getWidth(), love.graphics.getWidth() / 2
	local height, height_half = love.graphics.getHeight(), love.graphics.getHeight() / 2
	local text_pad = 8
	local bg_color = {r = 0, g = 0, b = 0, a = 100}

	--[[ CROSSHAIR ]]--
	if selected_body then
		timer:tween('crosshair_line_width', .1, crosshair, {line_weight = crosshair.max_line_weight})
	else
		timer:tween('crosshair_line_width', .1, crosshair, {line_weight = crosshair.min_line_weight})
	end
	love.graphics.setLineWidth(crosshair.line_weight)
	love.graphics.setColor(crosshair.color.r, crosshair.color.g, crosshair.color.b, crosshair.color.a)
	love.graphics.rectangle('line', (width / 2) - selection_range, (height / 2) - selection_range, selection_range * 2, selection_range * 2)

	love.graphics.setLineWidth(1)
	love.graphics.setColor(crosshair.color.r, crosshair.color.g, crosshair.color.b, crosshair.color.a * .75)
	local crosshair_offset = 10
	love.graphics.line(width_half, crosshair_offset, width_half, height_half - selection_range - crosshair_offset)
	love.graphics.line(crosshair_offset, height_half, width_half - selection_range - crosshair_offset, height_half)
	love.graphics.line(width_half, height_half + selection_range + crosshair_offset, width_half, height - crosshair_offset)
	love.graphics.line(width_half + selection_range + crosshair_offset, height_half, width - crosshair_offset, height_half)

	--[[ FOUND BODIES ]]--
	love.graphics.setColor(crosshair.color.r, crosshair.color.g, crosshair.color.b, crosshair.color.a * .75)
	love.graphics.setLineWidth(1)
	local arc_width = math.rad(6)
	for i, body in ipairs(bodies) do
		if body.found and i ~= selected_body then
			-- TODO
			local starting_angle = angleBetweenPoints(player, body)
			love.graphics.arc('line', width_half, height_half, selection_range * 2, starting_angle - (arc_width / 2), starting_angle + (arc_width / 2))
		end
	end

	--[[ UI ]]--
	-- Coordinates
	love.graphics.setColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
	love.graphics.rectangle('fill', 0, 0, width, ui_font_size * 2)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setLineWidth(2)
	love.graphics.line(0, ui_font_size * 2, width, ui_font_size * 2)

	local coord_string = "location: (" .. string.format("%.0f", player.x) .. ", " .. string.format("%.0f", player.y) .. ")"
	love.graphics.printf(coord_string, text_pad, text_pad, width, 'left')

	-- Resources
	love.graphics.setColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
	love.graphics.rectangle('fill', 0, height - (ui_font_size * 2), width, ui_font_size * 2)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setLineWidth(2)
	love.graphics.line(0, height - (ui_font_size * 2), width, height - (ui_font_size * 2))

	local mineral_string = 'minerals: ' .. string.format("%.0f", player.resources.minerals)
	local food_string = "food: " .. string.format("%.0f", player.resources.farmed_goods)
	love.graphics.printf(mineral_string, text_pad, height - text_pad - ui_font_size, width_half - (text_pad * 2), 'right')
	love.graphics.printf(food_string, width_half + text_pad, height - text_pad - ui_font_size, width - text_pad, 'left')

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setLineWidth(2)
	love.graphics.line(width_half, height - (ui_font_size * 2), width_half, height)

	-- Selected body
	if selected_body then
		-- Window
		love.graphics.setColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
		love.graphics.rectangle('fill', 0, ui_font_size * 2, width_half, height - ((ui_font_size * 2) * 2))
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setLineWidth(2)
		love.graphics.line(width_half, ui_font_size * 2, width_half, height - (ui_font_size * 2))

		-- Text
		local body_name = 'celestial body: ' .. bodies[selected_body].id
		local body_minerals = bodies[selected_body].resources.minerals .. "% minerals"
		local body_farmland = bodies[selected_body].resources.farmland .. "% farmable land"

		local body_text = body_name .. "\n\n" .. body_minerals .. "\n" .. body_farmland
		love.graphics.printf(body_text, text_pad, (ui_font_size * 2) + text_pad, width_half - text_pad, "left")
	end

	--[[ MOUSE ]]--
	-- !!! ALWAYS DRAW LAST !!! --
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', love.mouse.getX() - mouse_radius, love.mouse.getY() - mouse_radius, mouse_radius * 2, mouse_radius * 2)
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

	local new_x, new_y = player.x + (player.xspeed * dt), player.y + (player.yspeed * dt)
	if new_x < 0 then new_x = 0 elseif new_x > world.bounds.x2 then new_x = world.bounds.x2 end
	if new_y < 0 then new_y = 0 elseif new_y > world.bounds.y2 then new_y = world.bounds.y2 end
	player.x = new_x
	player.y = new_y
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

			body:setFound(true)
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
