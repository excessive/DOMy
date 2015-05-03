local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local Text     = require(path.."elements.text")
local Input    = Class {}

Input:include(Text)

function Input:init(element, parent, gui)
	Text.init(self, element, parent, gui)

	-- Text cursor
	self.cursor = 0

	-- Display
	self.default_properties.display = "inline"
	self.default_properties.overflow = "scroll"

	-- Callbacks
	self.update           = self.textinput_update
	self.draw             = self.textinput_draw
	self.on_key_pressed   = self.default_on_key_pressed
	self.on_text_input    = self.default_on_text_input
	self.on_mouse_clicked = self.default_on_mouse_clicked
end

function Input:textinput_update(dt)
	self:default_update(dt)

	self.value = self.value:gsub("%\n", " ")
end

function Input:textinput_draw()
	self:default_draw()

	if not self.focus then return end

	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local index          = self:get_cursor_position()

	local sx  = cx + ep.font:getWidth(self.value:sub(1,index)) + self.scroll_position.x
	local sy1 = cy
	local sy2 = cy + height

	love.graphics.push("all")
	love.graphics.setScissor(cx, cy, cw, ch)
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.line(sx, sy1, sx, sy2)
	love.graphics.pop()
end

function Input:default_on_key_pressed(key)
	if not self.visible then return end

	local isDown = love.keyboard.isDown
	local ep     = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local index          = self:get_cursor_position()

	if key == "backspace" and index > 0 then
		local value1 = self.value:sub(1, index-1)
		local value2 = self.value:sub(index+1, -1)
		self.value   = value1..value2
		self.cursor  = self.cursor - 1
	end

	if key == "delete" and index < #self.value then
		local value1 = self.value:sub(1, index)
		local value2 = self.value:sub(index+2, -1)
		self.value   = value1..value2
	end

	if key == "left" and index > 0 then
		self.cursor = self.cursor - 1
	end

	if key == "right" and index < #self.value then
		self.cursor = self.cursor + 1
	end

	if key == "x" and (isDown("lctrl") or isDown("rctrl")) then

	end

	if key == "c" and (isDown("lctrl") or isDown("rctrl")) then

	end

	if key == "v" and (isDown("lctrl") or isDown("rctrl")) then
		local value1 = self.value:sub(1, index)
		local paste  = love.system.getClipboardText()
		local value2 = self.value:sub(index+1, -1)
		self.value   = value1..paste..value2
		self.cursor  = self.cursor + #paste
	end

	self:scroll()
end

function Input:default_on_text_input(text)
	if not self.visible then return end

	local index  = self:get_cursor_position()
	local value1 = self.value:sub(1, index)
	local value2 = self.value:sub(index+1, -1)
	self.value   = value1 .. text .. value2
	self.cursor  = self.cursor + 1
end

function Input:default_on_mouse_clicked(button, x, y)
	if button == "l" then
		self:set_cursor_position(x, y)
	end
end

function Input:set_cursor_position(x, y)
	if self.value == "" then
		self.cursor = 0
		return
	end

	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local mx = x - cx

	for i = 1, #self.value do
		local s = self.value:sub(1, i)

		if ep.font:getWidth(s) > mx then
			self.cursor = i - 1
			break
		else
			self.cursor = i
		end
	end
end

function Input:get_cursor_position()
	return self.cursor
end

function Input:scroll()
	local ep = self.properties
	local cx, cy, cw, ch = self:_get_content_position()
	local index = self:get_cursor_position()

	local scroll = self.scroll_position
	local cpos = scroll.x + ep.font:getWidth(self.value:sub(1,index))
	local W = cw - ep.font:getWidth("W")

	if cpos > W then
		scroll.x = scroll.x - (cpos - W)
	end

	if cpos <= 0 then
		scroll.x = scroll.x + math.abs(cpos)
	end
end

return Input
