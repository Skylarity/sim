HpBarRoom = Room:extend()

function HpBarRoom:new()
    self.super.new(self)
    self.area = Area()

	input:bind('mouse1', 'damage')
	input:bind('r', 'reset')

	hp = {
		front = 100,
		back = 100,
		neg_color = {r = 255, g = 70, b = 70, a = 150},
		pos_color = {r = 70, g = 255, b = 70, a = 255},
		front_color = {r = 255, g = 70, b = 70, a = 255},
		back_color = {r = 255, g = 70, b = 70, a = 150}
	}
end

function HpBarRoom:update(dt)
	if input:pressed('damage') then
		local new_hp = hp.front + ((love.math.random() * 20) - 10)
		if new_hp <= 0 then new_hp = 0 end
		if new_hp >= 100 then new_hp = 100 end

		if new_hp >= hp.front then
			timer:tween('hp_color', .2, hp.front_color, hp.pos_color, 'out-quad')
		elseif new_hp < hp.front then
			timer:tween('hp_color', .2, hp.front_color, hp.neg_color, 'out-quad')
		end

		timer:tween('front_hp', .2, hp, {front = new_hp}, 'out-quad')
		timer:tween('back_hp', .8, hp, {back = new_hp}, 'in-out-quad')
	end

	if input:pressed('reset') then
		timer:tween('front_hp', 1, hp, {front = 100}, 'out-quad')
		timer:tween('back_hp', 2, hp, {back = 100}, 'in-out-quad')
	end
end

function HpBarRoom:draw()
	love.graphics.setColor(hp.back_color.r, hp.back_color.g, hp.back_color.b, hp.back_color.a)
	love.graphics.rectangle('fill', 400 - 200, 300 - 50, (4) * hp.back, 100)
	love.graphics.setColor(hp.front_color.r, hp.front_color.g, hp.front_color.b, hp.front_color.a)
	love.graphics.rectangle('fill', 400 - 200, 300 - 50, (4) * hp.front, 100)
end

function HpBarRoom:activate()
    -- body
end

function HpBarRoom:deactivate()
    -- body
end
