require 'helpers.helpers'
Object = require 'lib.classic.classic'
Camera = require 'lib.hump.camera'
Input = require 'lib.boipushy.Input'
Timer = require 'lib.enhanced_timer.EnhancedTimer'
Moses = require 'lib.moses.Moses'

function love.load()
	--[[ REQUIRES ]]--
	local files = {}
	recursiveEnumerate('objects', files)
	recursiveEnumerate('rooms', files)
	requireFiles(files)

	--[[ INITIALIZATION ]]--
	input = Input()
	timer = Timer()

	--[[ ROOMS ]]--
	rooms = {}
	current_room = nil

	goToRoom('MainRoom', 'main')
end

function love.update(dt)
	timer:update(dt)
	if current_room then current_room:update(dt) end
end

function love.draw()
	if current_room then current_room:draw() end
end
