--[[ LOADING ]]--

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)

    for _, item in ipairs(items) do
        local file = folder .. '/' .. item

        if love.filesystem.isFile(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

--[[ ROOMS ]]--

function addRoom(room_type, room_name, ...)
    local room = _G[room_type](room_name, ...)
    rooms[room_name] = room
    return room
end

function goToRoom(room_type, room_name, ...)
    if current_room and rooms[room_name] then
        if current_room.deactivate then current_room:deactivate() end
        current_room = rooms[room_name]
        if current_room.activate then current_room:activate() end
    else
        current_room = addRoom(room_type, room_name, ...)
    end
end

--[[ GENERAL ]]--

function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

-- Angles
-- returns the degrees between (0,0) and pt (note: 0 degrees is 'east')
function angleOfPoint( pt )
   local x, y = pt.x, pt.y
   local radian = math.atan2(y,x)
   local angle = radian*180/math.pi
   if angle < 0 then angle = 360 + angle end
   return angle
end

-- returns the degrees between two points (note: 0 degrees is 'east')
function angleBetweenPoints( a, b )
   local x, y = b.x - a.x, b.y - a.y
   return angleOfPoint( { x=x, y=y } )
end

-- returns the smallest angle between the two angles
-- ie: the difference between the two angles via the shortest distance
function smallestAngleDiff( target, source )
   local a = target - source

   if (a > 180) then
      a = a - 360
   elseif (a < -180) then
      a = a + 360
   end

   return a
end
