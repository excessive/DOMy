local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local Text     = assert(love.filesystem.load(new_path.."elements/text.lua"))(path)
local Input    = Class {}

Input:include(Text)

function Input:init(element, parent, gui)
	Text.init(self, element, parent, gui)

	-- List of cursors
	self.cursor = {}

	-- Display
	self.default_properties.display = "block"

	-- Callbacks
	self.draw             = self.custom_draw
	self.on_key_pressed   = self.default_on_key_pressed
	self.on_text_input    = self.default_on_text_input
	self.on_mouse_clicked = self.default_on_mouse_clicked
end

function Input:default_on_key_pressed(key)
	local isDown = love.keyboard.isDown
	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)

	local index, x, y = self:get_cursor_position(1)

	local str = lines[y] or ""
	local sx  = ep.font:getWidth(str:sub(1,x))
	local sy  = height * (y-1)

	if key == "backspace" and index > 0 then
		local value1 = self.value:sub(1, index-1)
		local value2 = self.value:sub(index+1, -1)
		self.value = value1..value2
		self.cursor[1] = self.cursor[1] - 1
	end

	if key == "delete" and index < #self.value then
		local value1 = self.value:sub(1, index)
		local value2 = self.value:sub(index+2, -1)
		self.value = value1..value2
	end

	if key == "up" then

	end

	if key == "down" then

	end

	if key == "left" and index > 0 then
		self.cursor[1] = self.cursor[1] - 1
	end

	if key == "right" and index < #self.value then
		self.cursor[1] = self.cursor[1] + 1
	end

	if key == "x" and (isDown("lctrl") or isDown("rctrl")) then

	end

	if key == "c" and (isDown("lctrl") or isDown("rctrl")) then

	end

	if key == "v" and (isDown("lctrl") or isDown("rctrl")) then
		local value1 = self.value:sub(1, index)
		local paste  = love.system.getClipboardText()
		local value2 = self.value:sub(index+1, -1)
		self.value = value1..paste..value2
		self.cursor[1] = self.cursor[1] + #paste
	end
end

function Input:default_on_text_input(text)
	self.value = self.value .. text
end

function Input:default_on_mouse_clicked(button, x, y)
	if button == "l" then
		self:set_cursor_position(x, y)
	end
end

function Input:set_cursor_position(x, y)
	if self.value == "" then self.cursor[1] = 0 end
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
			self.cursor[1] = index + i - 1
			break
		else
			self.cursor[1] = index + i
		end
	end
end

function Input:get_cursor_position(cursor)
	if not self.cursor[cursor] then return 0, 0, 1 end

	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)
	local index, x, y    = self.cursor[cursor], 0, 0

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

	return self.cursor[cursor], x, y
end

function Input:custom_draw()
	self:default_draw()

	local ep = self.properties

	local cx, cy, cw, ch = self:_get_content_position()
	local height         = ep.font:getHeight() * ep.font:getLineHeight()
	local width, lines   = self.gui:_font_getWrap(ep.font, self.value, cw)

	local index, x, y = self:get_cursor_position(1)
	--print(index, x, y)

	local str = lines[y] or ""

	if str then
		local sx    = cx + ep.font:getWidth(str:sub(1,x))
		local sy1   = cy + height * (y-1)
		local sy2   = cy + height * y

		love.graphics.push("all")
		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.line(sx, sy1, sx, sy2)
		love.graphics.pop()
	end
end

return Input
