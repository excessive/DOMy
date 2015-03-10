local path    = (...):gsub('%.[^%.]+$', '')
local Class   = require(path..".thirdparty.hump.class")
local cpml    = require(path..".thirdparty.cpml")
local Element = Class {}

function Element:init(element, parent, gui)
	self.gui                = gui
	self.focus              = false
	self.enabled            = true
	self.type               = element[1]
	self.value              = ""
	self.parent             = parent or false
	self.position           = cpml.vec2(0, 0)
	self.scroll_position    = cpml.vec2(0, 0) -- dp scrolled
	self.children           = {}
	self.default_properties = {
		display  = "inline",
		visible  = true,
		position = "default",
		overflow = "visible",

		-- TOP, RIGHT, BOTTOM, LEFT
		margin  = 0,
		border  = 0,
		padding = 0,

		-- Flex Container
		flex_direction  = "row",
		flex_wrap       = "none",
		justify_content = "start",
		align_items     = "stretch",
		align_content   = "stretch",

		-- Flex Item
		order       = 1,
		flex_grow   = 0,
		flex_shrink = 0,
		flex_basis  = "auto",
		align_self  = "auto",

		-- Font
		font_path   = "default",
		font_size   = 12,
		line_height = 1,
		text_align  = "left",
		text_shadow = false,

		-- Color
		border_color = { 255, 255, 255, 255 },
		text_color   = { 255, 255, 255, 255 },
		text_shadow_color = { 0, 0, 0, 255 },
	}
	self.custom_properties = {}
	self.properties        = {}

	for k, v in pairs(element) do
		if type(k) == "string" then
			self[k] = v
		end
	end

	if self.value == "" and type(element[2]) ~= "table" then
		self.value = element[2]
	end

	if type(element.class) ~= "table" then
		self.class = { element.class }
	else
		self.class = element.class
	end

	self.update = self.default_update
	self.draw   = self.default_draw
end

function Element:default_update(dt)

end

function Element:default_draw()
	--[[         ~~ BOX MODEL ~~

		{             WIDTH             }
	+---------------------------------------+
	|                MARGIN                 |
	|   +-------------------------------+   | ~~~
	|   |/////////// BORDER ////////////|   |
	|   |///+-----------------------+///|   |
	|   |///|        PADDING        |///|   |  H
	|   |///|   +---------------+   |///|   |  E
	|   |///|   |               |   |///|   |  I
	|   |///|   |    CONTENT    |   |///|   |  G
	|   |///|   |               |   |///|   |  H
	|   |///|   +---------------+   |///|   |  T
	|   |///|        PADDING        |///|   |
	|   |///+-----------------------+///|   |
	|   |/////////// BORDER ////////////|   |
	|   +-------------------------------+   | ~~~
	|                MARGIN                 |
	+---------------------------------------+
		{             WIDTH             }

	--]]

	local function get_scissor_clip(parent, x, y, w, h, ox, oy)
		local sx, sy, sw, sh = x, y, w, h

		if parent then
			local pp = parent.properties
			local cx, cy, cw, ch = parent:_get_content_area(ox, oy)

			if sx < cx then
				sx = cx
			end

			if sy < cy then
				sy = cy
			end

			if sx + sw - cx > cw then
				sw = sw - ((sx + sw) - (cx + cw))
			end

			if sy + sh - cy > ch then
				sh = sh - ((sy + sh) - (cy + ch))
			end
		end

		if sw < 0 then sw = 0 end
		if sh < 0 then sh = 0 end

		return sx, sy, sw, sh
	end

	local function set_properties(new_properties, properties)
		if not new_properties then return properties end

		local properties = properties or {}

		for k in pairs(new_properties) do
			properties[k] = new_properties[k]
		end

		return properties
	end

	local cc = self.gui.srgb and love.math.gammaToLinear or function(...) return ... end
	local ep = self.properties

	-- Position & size of element
	local x, y, w, h, ox, oy = self:_get_position()

	-- Content start & end of element
	local cx, cy, cw, ch = self:_get_content_area()

	-- Set clip space to element bounds
	love.graphics.setScissor(get_scissor_clip(self.parent, x, y, w, h, ox, oy))

	-- Draw Background
	if ep.background_color then
		love.graphics.push("all")
		love.graphics.setColor(cc(ep.background_color))
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.pop()
	end

	-- Draw Background Image
	if ep.background_image then
		local bx, by = x, y
		local bw, bh = ep.background_image:getDimensions()

		-- Set Background Offset
		if ep.background_position then
			bx = bx + ep.background_position[1]
			by = by + ep.background_position[2]
		end

		-- Set Background Size
		if ep.background_size then
			if ep.background_size[1] < bw then
				bw = ep.background_size[1]
			end

			if ep.background_size[2] < bh then
				bh = ep.background_size[2]
			end
		end

		if ep.background_image_color then
			love.graphics.push("all")
			love.graphics.setColor(ep.background_image_color)
		end

		local quad = love.graphics.newQuad(0, 0, bw, bh, ep.background_image:getDimensions())
		love.graphics.draw(ep.background_image, quad, bx, by)

		if ep.background_image_color then
			love.graphics.pop()
		end
	end

	-- Draw Image
	if ep.image then
		love.graphics.draw(ep.image, x, y)
	end

	-- Draw Border (Top)
	if ep.border_top > 0 then
		local x = x + ep.border_top / 2
		local y = y + ep.border_top / 2
		love.graphics.push("all")
		love.graphics.setColor(cc(ep.border_top_color))
		love.graphics.setLineWidth(ep.border_top)
		love.graphics.setLineStyle("rough")
		love.graphics.line(x, y, x+w, y)
		love.graphics.pop()
	end

	-- Draw Border (Right)
	if ep.border_right > 0 then
		local x = x - ep.border_top / 2
		local y = y + ep.border_top / 2
		love.graphics.push("all")
		love.graphics.setColor(cc(ep.border_right_color))
		love.graphics.setLineWidth(ep.border_right)
		love.graphics.setLineStyle("rough")
		love.graphics.line(x+w, y, x+w, y+h)
		love.graphics.pop()
	end

	-- Draw Border (Bottom)
	if ep.border_bottom > 0 then
		local x = x - ep.border_top / 2
		local y = y - ep.border_top / 2
		love.graphics.push("all")
		love.graphics.setColor(cc(ep.border_bottom_color))
		love.graphics.setLineWidth(ep.border_bottom)
		love.graphics.setLineStyle("rough")
		love.graphics.line(x+w, y+h, x, y+h)
		love.graphics.pop()
	end

	-- Draw Border (Left)
	if ep.border_left > 0 then
		local x = x + ep.border_top / 2
		local y = y - ep.border_top / 2
		love.graphics.push("all")
		love.graphics.setColor(cc(ep.border_left_color))
		love.graphics.setLineWidth(ep.border_left)
		love.graphics.setLineStyle("rough")
		love.graphics.line(x, y+h, x, y)
		love.graphics.pop()
	end

	-- Set clip space to content bounds
	local overflow, parent = self:_get_overflow()

	if overflow == "visible" then
		love.graphics.setScissor()
	elseif overflow == "hidden" or overflow == "scroll" then
		love.graphics.setScissor(get_scissor_clip(self.parent, cx, cy, cw, ch, ox, oy))
	end

	-- Draw Text
	if self.value then
		love.graphics.push("all")

		-- Set Text Color
		if ep.text_color then
			love.graphics.setColor(cc(ep.text_color))
		end

		-- Set Font
		if ep.font then
			love.graphics.setFont(ep.font)
		end

		-- Set Line Height
		local line_height = ep.font:getLineHeight()
		ep.font:setLineHeight(ep.line_height)

		local text_offset = cy + (ep.font:getHeight() * ep.font:getLineHeight() - ep.font:getHeight()) / 2

		if ep.text_shadow then
			love.graphics.push("all")
			love.graphics.setColor(cc(ep.text_shadow_color))
			love.graphics.printf(tostring(self.value), cx + ep.text_shadow[1], text_offset + ep.text_shadow[2], cw, ep.text_align)
			love.graphics.pop()
		end

		love.graphics.printf(tostring(self.value), cx, text_offset, (cw >= 0 and cw or 0), ep.text_align)
		ep.font:setLineHeight(line_height)
		love.graphics.pop()
	end

	-- Reset clip space
	love.graphics.setScissor()

	-- DEBUG
	if self.gui._debug then
		love.graphics.push("all")
		love.graphics.setColor(cc(255, 255, 0, 63))
		love.graphics.rectangle("line", x-ep.margin_left, y-ep.margin_top, w+ep.margin_left+ep.margin_right, h+ep.margin_top+ep.margin_bottom)
		love.graphics.setColor(cc(0, 255, 255, 63))
		love.graphics.rectangle("line", cx, cy, cw, ch)
		love.graphics.setColor(cc(255, 255, 255, 255))
		love.graphics.pop()
	end
	-- DEBUG
end

function Element:default_on_mouse_scrolled(button)
	if self:_get_overflow() ~= "scroll" then return end

	local ep = self.properties
	local cx, cy, cw, ch = self:_get_content_area()
	local csw, csh       = self:_get_content_size()
	local scroll_size_y  = -csh + ch

	if ch >= csh then return end

	if button == "wu" then
		self.scroll_position.y = self.scroll_position.y - 30

		if  self.scroll_position.y < scroll_size_y then
			self.scroll_position.y = scroll_size_y
		end
	end

	if button == "wd" then
		self.scroll_position.y = self.scroll_position.y + 30

		if  self.scroll_position.y > 0 then
			self.scroll_position.y = 0
		end
	end
end

function Element:_get_sibling_position()
	if self.parent then
		for k, child in ipairs(self.parent.children) do
			if child == self then
				return k
			end
		end
	end

	return false
end

function Element._get_relative_position(element, ox, oy)
	if not element then return ox, oy end

	local ep = element.properties

	ox = ox or 0
	oy = oy or 0

	if ep.position == "relative" then
		ox = ox + (ep.left or 0) - (ep.right  or 0)
		oy = oy + (ep.top  or 0) - (ep.bottom or 0)
	end

	return Element._get_relative_position(element.parent, ox, oy)
end

function Element:_get_position()
	local ox, oy = self:_get_relative_position()
	local x = self.position.x + ox
	local y = self.position.y + oy
	local w = self.properties.width
	local h = self.properties.height

	return x, y, w, h, ox, oy
end

function Element:_get_content_area(ox, oy)
	local x, y, w, h = self:_get_position()

	local ep = self.properties
	local cx = x + ep.padding_left + ep.border_left + (ox or 0)
	local cy = y + ep.padding_top  + ep.border_top  + (oy or 0)
	local cw = w - ep.padding_left - ep.border_left - ep.padding_right  - ep.border_right
	local ch = h - ep.padding_top  - ep.border_top  - ep.padding_bottom - ep.border_bottom

	return cx, cy, cw, ch
end

function Element:_get_content_size()
	local w, h = 0, 0
	for _, element in ipairs(self.children) do
		local ep = element.properties

		if ep.position == "default" or ep.position == "relative" then
			local ew = ep.width + ep.margin_left + ep.margin_right
			if w < ew then w = ew end

			h = h + ep.height + ep.margin_top + ep.margin_bottom
		end
	end

	return w, h
end

function Element._get_overflow(self)
	if not self then return "visible" end

	if self.properties.overflow ~= "visible" then
		return self.properties.overflow, self
	end

	return Element._get_overflow(self.parent)
end

function Element:enable()
	self.enabled = true
end

function Element:disable()
	self.enabled = false
end

function Element_is_enabled()
	return self.enabled
end

function Element:has_property(property)
	return self.properties[property] ~= nil
end

function Element:get_property(property)
	return self.properties[property]
end

function Element:set_property(property, value)
	self.properties[property]        = value
	self.custom_properties[property] = value
end

function Element:remove_property(property)
	self.properties[property] = nil
end

function Element:has_children()
	return #self.children > 0
end

function Element:prepend_child(element)
	return self:add_child(element, 1)
end

function Element:append_child(element)
	return self:add_child(element)
end

function Element:add_child(element, position)
	-- Detatch from current parent
	if element.parent and element.parent ~= self then
		element:detatch()
	end

	element.parent = self

	-- If we inserted the element into a specific slot, then we put it there
	-- If there is no specified position, we append it at the end
	if type(position) == "number" then
		if position > #self.children then
			position = #self.children + 1
		end

		if position < 1 then
			position = 1
		end

		table.insert(self.children, position, element)
	else
		table.insert(self.children, element)
	end

	return self
end

function Element:remove_child(element)
	return self:replace_child(element)
end

function Element:replace_child(old, new)
	local child

	-- If we want to replace a child via position, verify position is within bounds
	if type(old) == "number" then
		if #self.children == 0 or old < 1 or old > #self.children then
			error("Invalid position: "..old..".")
		end

		child = self.children[old]
		child:destroy()

		if new then
			table.insert(self.children, old, new)
		end
	else
		if old.parent ~= self then
			error("Element does not belong to this parent.")
		end

		local position = old:_get_sibling_position()
		child = old
		child:destroy()

		if new then
			table.insert(self.children, position, new)
		end
	end

	return self
end

function Element:insert_before(element)
	if not element.parent then
		error("Element does not have a parent.")
	end

	local position = element:_get_sibling_position()

	if position < 1 then
		position = 1
	end

	element.parent:add_child(self, position)

	return self
end

function Element:insert_after(element)
	if not element.parent then
		error("Element does not have a parent.")
	end

	-- If element has a sibling after it, simply call insert_before() on that sibling!
	-- Otherwise just append to element's parent
	if element:next_sibling() then
		self:insert_before(element:next_sibling())
	else
		element.parent:append_child(self)
	end

	return self
end

function Element:attach(element, position)
	element:add_child(self, position)

	-- Remove self from draw stack
	for k, e in ipairs(self.gui.draw_order) do
		if self == e then
			table.remove(self.gui.draw_order, k)
			break
		end
	end
end

function Element:detach()
	if not self.parent then
		error("No parent to detatch from.")
	end

	table.insert(self.gui.draw_order, self)
	table.remove(self.parent.children, self:_get_sibling_position())
	self.parent = false

	return self
end

function Element:destroy()
	-- Loop recursively through all children
	for i=1, #self.children do
		self.children[1]:destroy()
	end

	if self.parent then
		-- Remove self from parent
		table.remove(self.parent.children, self:_get_sibling_position())
		self.parent = false
	else
		-- Remove self from draw stack
		for k, e in ipairs(self.gui.draw_order) do
			if self == e then
				table.remove(self.gui.draw_order, k)
				break
			end
		end
	end

	-- Goodbye, cruel world.
	-- I'm leaving you today.
	-- Goodbye...
	-- Goodbye...
	-- Goodbye.
end

function Element:clone(deep, parent)
	local clone = self.gui:new_element(self.type)
	clone.value = self.value

	-- Clone classes
	for _, class in ipairs(self.class) do
		table.insert(clone.class, class)
	end

	-- Clone properties
	for k, property in pairs(self.properties) do
		-- Some properties such as margin and padding are tables
		if type(property) == "table" then
			clone.properties[k] = {}

			for i, p in pairs(property) do
				clone.properties[k][i] = p
			end
		else
			clone.properties[k] = property
		end
	end

	-- Deep clone all children
	if deep then
		for _, child in ipairs(self.children) do
			child:clone(deep, clone)
		end
	end

	if parent then
		-- Add self to parent
		parent:add_child(clone)
	else
		-- Add self to draw stack
		table.insert(self.gui.draw_order, clone)
	end

	return clone
end

function Element:first_child()
	if #self.children > 0 then
		return self.children[1]
	end

	return false
end

function Element:last_child()
	if #self.children > 0 then
		return self.children[#self.children]
	end

	return false
end

function Element:previous_sibling()
	local position = self:_get_sibling_position()

	if position then
		local prev = position - 1

		if prev > 0 then
			return self.parent.children[prev]
		end
	end

	return false
end

function Element:next_sibling()
	local position = self:_get_sibling_position()

	if position then
		local nxt = position + 1

		if nxt <= #self.parent.children then
			return self.parent.children[nxt]
		end
	end

	return false
end

function Element:bring_to_front()
	if not self.parent then
		for k, element in ipairs(self.gui.draw_order) do
			if self == element then
				table.remove(self.gui.draw_order, k)
				table.insert(self.gui.draw_order, self)
				break
			end
		end
	else
		self.parent:bring_to_front()
	end
end

function Element:send_to_back()
	if not self.parent then
		for k, element in ipairs(self.gui.draw_order) do
			if self == element then
				table.remove(self.gui.draw_order, k)
				table.insert(self.gui.draw_order, self, 1)
				break
			end
		end
	else
		self.parent:send_to_back()
	end
end

function Element:set_index(index)
	if not self.parent then
		for k, element in ipairs(self.gui.draw_order) do
			if self == element then
				table.remove(self.gui.draw_order, k)
				table.insert(self.gui.draw_order, self, index)
				break
			end
		end
	else
		self.parent:set_index(index)
	end
end

function Element:exchange_with(index)
	if not self.parent then
		for k, element in ipairs(self.gui.draw_order) do
			if self == element then
				local exchange = self.gui.draw_order[index]

				table.remove(self.gui.draw_order, k)
				table.insert(self.gui.draw_order, exchange, k)

				table.remove(self.gui.draw_order, index)
				table.insert(self.gui.draw_order, self, index)
				break
			end
		end
	else
		self.parent:exchange_with(index)
	end
end

function Element:is_binding(x, y)
	if not self.visible then return end

	local ex = self.position.x
	local ey = self.position.y
	local ew = self.properties.width
	local eh = self.properties.height

	if ex <= x and ex + ew >= x and ey <= y and ey + eh >= y then
		return true
	end

	return false
end

function Element:scroll_into_view()
	-- If parent is scrollable, scroll it so that self is visible
	-- Self should be wholy visible or if too large, the top should match parent's top
end

function Element:add_class(class)
	if type(class) == "string" then
		table.insert(self.class, class)
	end
end

function Element:has_class(class)
	for _, c in ipairs(self.class) do
		if c == class then
			return true
		end
	end

	return false
end

function Element:remove_class(class)
	if type(class) == "string" then
		for k, v in ipairs(self.class) do
			if class == v then
				table.remove(self.class, k)
			end
		end
	end
end

return Element
