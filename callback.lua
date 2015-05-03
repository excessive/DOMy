local path     = (...):gsub('%.[^%.]+$', '') .. "."
local Display  = require(path.."properties.display")
local Callback = {}

function Callback.update(self, dt)
	for _, element in ipairs(self.elements) do
		element:update(dt)
	end

	if self.pseudo.hover then
		local mx, my = love.mouse.getPosition()
		self:bubble_event(self.pseudo.hover, "on_mouse_over", mx, my)
	end

	if self.pseudo.focus then
		-- Loop through active keys
		for key in pairs(self.key_down) do
			self:bubble_event(self.pseudo.focus, "on_key_down", key)
		end

		-- Loop through active mouse buttons
		for button, element in pairs(self.mouse_down) do
			if self.pseudo.focus == element then
				local mx, my = love.mouse.getPosition()
				self:bubble_event(self.pseudo.focus, "on_mouse_down", button, mx, my)
			end
		end

		-- Loop through active joystick buttons
		for _, joystick in pairs(self.joystick_down) do
			for button in pairs(joystick.button) do
				self:bubble_event(self.pseudo.focus, "on_joystick_down", joystick, button)
			end

			for axis in pairs(joystick.axis) do
				self:bubble_event(self.pseudo.focus, "on_joystick_axis", joystick, axis, value)
			end

			for hat in pairs(joystick.hat) do
				self:bubble_event(self.pseudo.focus, "on_joystick_hat", joystick, hat, direction)
			end
		end

		-- Loop through active gamepad buttons
		for _k, gamepad in pairs(self.gamepad_down) do
			for button, value in pairs(gamepad) do
				self:bubble_event(self.pseudo.focus, "on_gamepad_down", gamepad, button, value)
			end
		end
	end

	-- !!! THIS IS ONLY TEMPORARY UNTIL WE GET A BETTER UPDATE SYSTEM IN PLACE !!!
	self:resize()
end

function Callback.draw(self)
	local function draw_element(element)
		if not element.visible then return end

		element:draw()

		if #element.children > 0 then
			for _, e in ipairs(element.children) do
				draw_element(e)
			end
		end
	end

	-- Straight lines, yo
	love.graphics.setLineStyle("rough")

	-- All root objects
	for _, element in ipairs(self.draw_order) do
		draw_element(element)
	end

	-- Reset scissor after all elements are drawn
	love.graphics.setScissor()
end

function Callback.keypressed(self, key, isrepeat)
	if self.pseudo.focus then
		self.key_down[key] = true
		self:bubble_event(self.pseudo.focus, "on_key_pressed", key)

		if self.navigation then
			for direction, keys in pairs(self.nav) do
				for _, k in ipairs(keys) do
					if k == key then
						self:set_focus((self.pseudo.focus.properties["nav_"..direction] or self.pseudo.focus))
						break
					end
				end
			end
		end
	elseif self.last_focus then
		if self.navigation then
			for direction, keys in pairs(self.nav) do
				for _, k in ipairs(keys) do
					if k == key then
						self:set_focus((self.last_focus.properties["nav_"..direction] or self.last_focus))
						break
					end
				end
			end
		end
	end
end

function Callback.keyreleased(self, key)
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_key_released", key)
	end

	self.key_down[key] = nil
end

function Callback.textinput(self, text)
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_text_input", text)
	end
end

function Callback.mousepressed(self, x, y, button)
	local pressed = false

	local function check_binding(elements)
		for _, element in ipairs(elements) do
			if element:is_binding(x, y) then
				pressed = element
				check_binding(element.children)

				break
			end
		end
	end

	local i = #self.draw_order
	while i >= 1 do
		local element = self.draw_order[i]
		check_binding({ element })

		i = i - 1
		if pressed then break end
	end

	if pressed then
		if button == "wu" or button == "wd" then
			self:bubble_event(pressed, "on_mouse_scrolled", button)
		else
			self.mouse_down[button] = pressed
			self:bubble_event(pressed, "on_mouse_pressed", button, x, y)
		end
	else
		if button ~= "wu" and button ~= "wd" then
			self:remove_focus()
		end
	end
end

function Callback.mousereleased(self, x, y, button)
	local pressed = false

	local function check_binding(elements)
		for _, element in ipairs(elements) do
			if element:is_binding(x, y) then
				pressed = element
				check_binding(element.children)

				break
			end
		end
	end

	local i = #self.draw_order
	while i >= 1 do
		local element = self.draw_order[i]
		check_binding({ element })

		i = i - 1
		if pressed then break end
	end

	if pressed then
		self:bubble_event(pressed, "on_mouse_released", button, x, y)

		if self.mouse_down[button] == pressed then
			self:set_focus(pressed)
			self:bubble_event(pressed, "on_mouse_clicked", button, x, y)
		end
	end

	self.mouse_down[button] = nil
end

function Callback.mousemoved(self, x, y, dx, dy)
	local hover  = false

	local function check_binding(elements)
		for _, element in ipairs(elements) do
			if element:is_binding(x, y) then
				hover = element
				check_binding(element.children)
				element.hover = true
			else
				element.hover = false
			end
		end
	end

	local i = #self.draw_order
	while i >= 1 do
		local element = self.draw_order[i]
		check_binding({ element })

		i = i - 1
		if hover then break end
	end

	if self.pseudo.hover ~= hover then
		if self.pseudo.hover then
			local old_hover = self.pseudo.hover
			self.pseudo.hover = hover

			self:bubble_event(old_hover, "on_mouse_leave")
			love.mouse.setCursor()
		else
			self.pseudo.hover = hover
		end

		if self.pseudo.hover then
			self:bubble_event(self.pseudo.hover, "on_mouse_enter")

			if self.pseudo.hover.properties.cursor then
				love.mouse.setCursor(self.pseudo.hover.properties.cursor)
			end
		end
	end
end

function Callback.joystickadded(self, joystick)
	self.joystick_down[joystick]        = {}
	self.joystick_down[joystick].button = {}
	self.joystick_down[joystick].hat    = {}
	self.joystick_down[joystick].axis   = {}

	if joystick:isGamepad() then
		self.gamepad_down[joystick] = {}
	end

	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_joystick_added", joystick)
	end
end

function Callback.joystickremoved(self, joystick)
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_joystick_removed", joystick)
	end

	self.joystick_down[joystick] = nil

	if joystick:isGamepad() then
		self.gamepad_down[joystick] = nil
	end
end

function Callback.joystickpressed(self, joystick, button)
	if self.pseudo.focus then
		self.joystick_down[joystick].button[button] = true
		self:bubble_event(self.pseudo.focus, "on_joystick_pressed", joystick, button)
	end
end

function Callback.joystickreleased(self, joystick, button)
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_joystick_released", joystick, button)
	end

	self.joystick_down[joystick].button[button] = nil
end

function Callback.joystickaxis(self, joystick, axis, value)
	if self.pseudo.focus then
		self.joystick_down[joystick].axis[axis] = value
	end
end

function Callback.joystickhat(self, joystick, hat, direction)
	if self.pseudo.focus then
		self.joystick_down[joystick].hat[hat] = direction
	end
end

function Callback.gamepadpressed(self, joystick, button)
	if self.pseudo.focus then
		self.gamepad_down[joystick][button] = true
		self:bubble_event(self.pseudo.focus, "on_gamepad_pressed", joystick, button)
	end
end

function Callback.gamepadreleased(self, joystick, button)
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_gamepad_released", joystick, button)
	end

	self.gamepad_down[joystick][button] = nil
end

function Callback.gamepadaxis(self, joystick, axis, value)
	if self.pseudo.focus then
		self.gamepad_down[joystick][axis] = value
	end
end

function Callback.resize(self, w, h)
	self.width  = w or self.width  or love.graphics.getWidth()
	self.height = h or self.height or love.graphics.getHeight()

	self:set_styles()
	self:apply_styles()

	Display.position_elements(self.draw_order, nil, 0, 0, self.width, self.height)
end

return Callback
