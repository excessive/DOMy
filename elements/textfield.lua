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
	self.default_properties.display = "block"

	-- Callbacks
	self.draw             = self.textfield_draw
	self.on_key_pressed   = self.default_on_key_pressed
	self.on_text_input    = self.default_on_text_input
	self.on_mouse_clicked = self.default_on_mouse_clicked
end

function Input:textfield_draw()
	self:default_draw()

	if not self.focus then return end

	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)
	local index, x, y    = self:get_cursor_position()
	if y == 0 then y = 1 end

	local str = lines[y] or ""
	local sx  = cx + ep.font:getWidth(str:sub(1,x))
	local sy1 = cy + height * (y-1)
	local sy2 = cy + height * y

	love.graphics.push("all")
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.line(sx, sy1, sx, sy2)
	love.graphics.pop()
end

function Input:default_on_key_pressed(key)
	local isDown = love.keyboard.isDown
	local ep     = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)
	local index, x, y    = self:get_cursor_position()

	local str = lines[y] or ""

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

	if key == "return" then
		local value1 = self.value:sub(1, index)
		local value2 = self.value:sub(index+1, -1)
		self.value   = value1 .. "\n" .. value2
		self.cursor  = self.cursor + 1
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
end

function Input:default_on_text_input(text)
	local index, x, y = self:get_cursor_position()
	local value1      = self.value:sub(1, index)
	local value2      = self.value:sub(index+1, -1)
	self.value        = value1 .. text .. value2
	self.cursor       = self.cursor + 1
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
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)

	local mx = x - cx
	local my = y - cy

	local line = math.ceil(my / height)
	local str  = lines[line]

	local index = 0
	for i=1, line-1 do
		index = index + #lines[i]
	end

	for i = 1, #str do
		local s = str:sub(1, i)

		if ep.font:getWidth(s) > mx then
			self.cursor = index + i - 1
			break
		else
			self.cursor = index + i
		end
	end
end

function Input:get_cursor_position()
	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)
	local index, x, y    = self.cursor, 0, 0

	local count = index

	for i=1, #lines do
		y = y + 1

		if count - #lines[i] <= 0 then
			x = count
			break
		else
			count = count - #lines[i]
		end
	end

	return self.cursor, x, y
end

return Input
