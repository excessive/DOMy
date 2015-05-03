local path    = (...):gsub('%.[^%.]+$', '')
      -- back it up, back it up, back it up...
      path    = path:sub(1,path:match("^.*()%."))
local Class   = require(path.."thirdparty.hump.class")
local cpml    = require(path.."thirdparty.cpml")
local lume    = require(path.."thirdparty.lume")
local patchy  = require(path.."thirdparty.patchy")
local Initial = require(path.."properties.initial")
local Element = Class {}

local function get_opacity(element, opacity)
	if not element then return opacity end
	local opacity = (opacity or 1) * element.properties.opacity
	return get_opacity(element.parent, opacity)
end

local function set_properties(new_properties, properties)
	if not new_properties then return properties end

	local properties = properties or {}

	for k in pairs(new_properties) do
		properties[k] = new_properties[k]
	end

	return properties
end

function Element:init(element, parent, gui)
	self.gui                = gui
	self.focus              = false
	self.hover              = false
	self.entered            = false
	self.enabled            = true
	self.type               = element[1]
	self.value              = ""
	self.parent             = parent or false
	self.position           = cpml.vec2(0, 0)
	self.scroll_position    = cpml.vec2(0, 0) -- dp scrolled
	self.element_position   = {}
	self.border_position    = {}
	self.content_position   = {}
	self.offset             = {}
	self.scissor            = {}
	self.stencil            = {}
	self.children           = {}
	self.styles             = {}
	self.default_properties = {
		display  = "inline",
		visible  = true,
		position = "default",
		overflow = "visible",
		opacity  = 1,

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

	self.update         = self.default_update
	self.draw           = self.default_draw
	self.on_focus       = self.default_on_focus
	self.on_focus_leave = self.default_on_focus_leave
end

function Element:default_update(dt)
	local ep = self.properties

	self:_set_position()

	-- Position start & end of element
	local x, y, w, h, ox, oy = self:_get_position("element")

	-- Border start & end of element
	local bx, by, bw, bh = self:_get_position("border")

	-- Content start & end of element
	local cx, cy, cw, ch = self:_get_position("content")

	local sw, sh = cw, ch

	if overflow_x == "visible" then
		sw = self.gui.width - cx
	end

	if overflow_y == "visible" then
		sh = self.gui.height - cy
	end

	local opacity = get_opacity(self)

	-- If we have a border radius, set this to true
	local stencil_set = false

	-- Set clip space to element bounds
	self:_set_scissor("element", self.parent,  x,  y,  w,  h, ox, oy)
	self:_set_scissor("border",  self.parent, bx, by, bw, bh, ox, oy)
	self:_set_scissor("content", self.parent, cx, cy, sw, sh, ox, oy)

	-- Set Border Radius stencil
	if ep.border_top_left_radius
	or ep.border_top_right_radius
	or ep.border_bottom_right_radius
	or ep.border_bottom_left_radius then
		local tl = ep.border_top_left_radius     or 0
		local tr = ep.border_top_right_radius    or 0
		local br = ep.border_bottom_right_radius or 0
		local bl = ep.border_bottom_left_radius  or 0
		self:_set_stencil(x, y, w, h, 25, tl, tr, br, bl)
	end
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

	local cc = self.gui.srgb and love.math.gammaToLinear or function(...) return ... end
	local ep = self.properties

	-- Position start & end of element
	local x, y, w, h, ox, oy = self:_get_position("element")

	-- Border start & end of element
	local bx, by, bw, bh = self:_get_position("border")

	-- Content start & end of element
	local cx, cy, cw, ch = self:_get_position("content")

	local opacity = get_opacity(self)

	-- If we have a border radius, set this to true
	local stencil_set = false

	-- Set clip space to element bounds
	love.graphics.setScissor(self:_get_scissor("element"))

	-- Set Border Radius stencil
	if ep.border_top_left_radius
	or ep.border_top_right_radius
	or ep.border_bottom_right_radius
	or ep.border_bottom_left_radius then
		love.graphics.setStencil(self:_get_stencil())
		stencil_set = true
	end

	-- Draw Background
	if ep.background_color then
		local lr, lg, lb = cc(ep.background_color)
		love.graphics.setColor(lr, lg, lb, (ep.background_color[4] or 255)*opacity)
		love.graphics.rectangle("fill", bx, by, bw, bh)
		love.graphics.setColor(cc(255, 255, 255, 255*opacity))
	end

	-- Draw Background Image
	if ep.background_image then
		local bix, biy = x, y
		local biw, bih

		-- If 9patch image
		if ep.background_image.type == "9patch" then
			biw, bih = w, h
		else
			biw, bih = ep.background_image:getDimensions()
		end

		-- Set Background Offset
		if ep.background_position then
			bix = bix + ep.background_position[1]
			biy = biy + ep.background_position[2]
		end

		-- Set Background Size
		if ep.background_size then
			if ep.background_size[1] < biw then
				bw = ep.background_size[1]
			end

			if ep.background_size[2] < bih then
				bh = ep.background_size[2]
			end
		end

		if ep.background_image_color then
			local lr, lg, lb = cc(ep.background_image_color)
			love.graphics.setColor(lr, lg, lb, (ep.background_image_color[4] or 255)*opacity)
		end

		-- If 9patch image
		if ep.background_image.type == "9patch" then
			ep.background_image:draw(bix, biy, biw, bih)
		else
			love.graphics.draw(ep.background_image, bix, biy)
		end
	end

	-- Draw Border (Top)
	if ep.border_top > 0 then
		local y = y + ep.border_top / 2
		local lr, lg, lb = cc(ep.border_top_color)
		love.graphics.setColor(lr, lg, lb, (ep.border_top_color[4] or 255)*opacity)
		love.graphics.setLineWidth(ep.border_top)
		love.graphics.line(x, y, x+w, y)
	end

	-- Draw Border (Right)
	if ep.border_right > 0 then
		local x = x - ep.border_right / 2
		local lr, lg, lb = cc(ep.border_right_color)
		love.graphics.setColor(lr, lg, lb, (ep.border_right_color[4] or 255)*opacity)
		love.graphics.setLineWidth(ep.border_right)
		love.graphics.line(x+w, y, x+w, y+h)
	end

	-- Draw Border (Bottom)
	if ep.border_bottom > 0 then
		local y = y - ep.border_bottom / 2
		local lr, lg, lb = cc(ep.border_bottom_color)
		love.graphics.setColor(lr, lg, lb, (ep.border_bottom_color[4] or 255)*opacity)
		love.graphics.setLineWidth(ep.border_bottom)
		love.graphics.line(x+w, y+h, x, y+h)
	end

	-- Draw Border (Left)
	if ep.border_left > 0 then
		local x = x + ep.border_left / 2
		local lr, lg, lb = cc(ep.border_left_color)
		love.graphics.setColor(lr, lg, lb, (ep.border_left_color[4] or 255)*opacity)
		love.graphics.setLineWidth(ep.border_left)
		love.graphics.line(x, y+h, x, y)
	end

	-- Draw Image
	if ep.image then
		-- Set clip space to border bounds
		love.graphics.setScissor(self:_get_scissor("border"))

		love.graphics.setColor(cc(255, 255, 255, 255*opacity))
		love.graphics.draw(ep.image, x, y)
	end

	-- Set clip space to content bounds
	local overflow_x, overflow_y, parent = self:_get_overflow()

	-- Draw Text
	if self.value then
		-- Set clip space to content bounds
		love.graphics.setScissor(self:_get_scissor("content"))

		-- Set Manipulatable Text
		local value = tostring(self.value)

		-- Set Font
		if ep.font then
			love.graphics.setFont(ep.font)
		end

		-- Set Line Height
		local line_height = ep.font:getLineHeight()
		ep.font:setLineHeight(ep.line_height)

		-- Set Text Offset
		local text_offset = cy + (ep.font:getHeight() * ep.font:getLineHeight() - ep.font:getHeight()) / 2

		-- Set Text Transform
		if ep.text_transform == "uppercase" then
			value = value:upper()
		elseif ep.text_transform == "lowercase" then
			value = value:lower()
		elseif ep.text_transform == "capitalize" then
			value = value:lower():gsub("(%a)([%w_']*)", function(a,b) return a:upper()..b:lower() end)
		end

		-- Overflow Text
		local overflow = cw

		if ep.overflow_y == "hidden" or ep.overflow_y == "scroll" then
			overflow = ep.font:getWidth(self.value)
		end

		local scrollx = cx + self.scroll_position.x
		--local scrolly = cy + self.scroll_position.y

		-- Set Text Shadow
		if ep.text_shadow then
			local lr, lg, lb = cc(ep.text_shadow_color)
			love.graphics.setColor(lr, lg, lb, (ep.text_shadow_color[4] or 255)*opacity)
			love.graphics.printf(value, scrollx + ep.text_shadow[1], text_offset + ep.text_shadow[2], (overflow >= 0 and overflow or 0), ep.text_align)
		end

		-- Set Text Color
		if ep.text_color then
			local lr, lg, lb = cc(ep.text_color)
			love.graphics.setColor(lr, lg, lb, (ep.text_color[4] or 255)*opacity)
		end

		-- Print text
		love.graphics.printf(value, scrollx, text_offset, (overflow >= 0 and overflow or 0), ep.text_align)
		ep.font:setLineHeight(line_height)
	end

	-- Reset Stencil
	if stencil_set then
		love.graphics.setStencil()
	end

	-- DEBUG
	if self.gui._debug then
		love.graphics.setScissor()
		love.graphics.setColor(cc(255, 0, 0, 191))
		love.graphics.rectangle("line", x-ep.margin_left, y-ep.margin_top, w+ep.margin_left+ep.margin_right, h+ep.margin_top+ep.margin_bottom)
		love.graphics.setColor(cc(0, 0, 255, 191))
		love.graphics.rectangle("line", cx, cy, cw, ch)
		love.graphics.setColor(cc(255, 255, 255, 255))
	end
	-- DEBUG

	love.graphics.setColor(255, 255, 255, 255)
end

function Element:default_on_focus()
	self.focus = true
end

function Element:default_on_focus_leave()
	self.focus = false
end

function Element:default_on_mouse_scrolled(button)
	local overflow_x, overflow_y, parent = self:_get_overflow()
	if overflow_y ~= "scroll" then return end

	local ep = self.properties
	local cx, cy, cw, ch = self:_get_content_position()
	local csw, csh       = self:_get_content_size()
	local scroll_size_y  = -csh + ch

	if ch >= csh then return end

	if button == "wd" then
		self.scroll_position.y = self.scroll_position.y - 30

		if  self.scroll_position.y < scroll_size_y then
			self.scroll_position.y = scroll_size_y
		end
	end

	if button == "wu" then
		self.scroll_position.y = self.scroll_position.y + 30

		if  self.scroll_position.y > 0 then
			self.scroll_position.y = 0
		end
	end
end

function Element:is_enabled()
	return self.enabled
end

function Element:enable()
	self.enabled = true
end

function Element:disable()
	self.enabled = false
end

function Element:has_class(class)
	for _, c in ipairs(self.class) do
		if c == class then
			return true
		end
	end

	return false
end

function Element:add_class(class)
	if type(class) == "string" then
		table.insert(self.class, class)
	end
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

-- We cannot use ipairs here because destroying
-- an element in order will mess up the ipairs
-- and not give the best results. Instead we
-- use Lume's r[everse]ipairs function to solve
-- this problem.
function Element:destroy()
	-- Loop recursively through all children
	for _, child in lume.ripairs(self.children) do
		child:destroy()
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

function Element:destroy_children()
	for _, child in lume.ripairs(self.children) do
		child:destroy()
	end
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

function Element:is_descendant(element)
	if self.parent then
		if self.parent == element then
			return true
		else
			return Element.is_descendant(self.parent, element)
		end
	else
		return false
	end
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

	local ex, ey, ew, eh = self:_get_position("element")

	-- Delay for 1 frame
	if  not ex or
		not ey or
		not ew or
		not eh then
		return false
	end

	if ex <= x and ex + ew >= x and ey <= y and ey + eh >= y then
		return true
	end

	return false
end

function Element:is_content_binding(x, y)
	if not self.visible then return end

	local cx, cy, cw, ch = self:_get_position("content")

	-- Delay for 1 frame
	if  not cx or
		not cy or
		not cw or
		not ch then
		return false
	end

	if cx <= x and cx + cw >= x and cy <= y and cy + ch >= y then
		return true
	end

	return false
end

function Element:scroll_into_view()
	-- If parent is scrollable, scroll it so that self is visible
	-- Self should be wholy visible or if too large, the top should match parent's top
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

function Element:_set_position()
	local ep = self.properties

	self.offset.x, self.offset.y = self:_get_relative_position()

	self.element_position.x = self.position.x + self.offset.x
	self.element_position.y = self.position.y + self.offset.y
	self.element_position.w = ep.width
	self.element_position.h = ep.height

	self.border_position.x = self.element_position.x + ep.border_left + (self.offset.x or 0)
	self.border_position.y = self.element_position.y + ep.border_top  + (self.offset.y or 0)
	self.border_position.w = self.element_position.w - ep.border_left - ep.border_right
	self.border_position.h = self.element_position.h - ep.border_top  - ep.border_bottom

	self.content_position.x = self.border_position.x + ep.padding_left
	self.content_position.y = self.border_position.y + ep.padding_top
	self.content_position.w = self.border_position.w - ep.padding_left - ep.padding_right
	self.content_position.h = self.border_position.h - ep.padding_top  - ep.padding_bottom
end

function Element:_get_position(layer)
	layer = layer .. "_position"
	return self[layer].x, self[layer].y, self[layer].w, self[layer].h, self.offset.x, self.offset.y
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
	if not self then return "visible", "visible" end

	if self.properties.overflow_x ~= "visible"
	or self.properties.overflow_y ~= "visible" then
		return self.properties.overflow_x, self.properties.overflow_y, self
	end

	return Element._get_overflow(self.parent)
end

function Element:_get_scissor(layer)
	assert(self.scissor[layer], "Scissor layer \"" .. layer .. "\" hasn't been set yet.")
	return self.scissor[layer].x, self.scissor[layer].y, self.scissor[layer].w, self.scissor[layer].h
end

function Element:_set_scissor(layer, parent, x, y, w, h, ox, oy)
	local sx, sy, sw, sh = x, y, w, h

	if parent then
		local pp = parent.properties
		local cx, cy, cw, ch = parent:_get_position("content")

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

	if not self.scissor[layer] then self.scissor[layer] = {} end

	self.scissor[layer].x = sx
	self.scissor[layer].y = sy
	self.scissor[layer].w = sw
	self.scissor[layer].h = sh
end

function Element:_get_stencil()
	return function() love.graphics.polygon("fill", self.stencil) end
end

-- https://gist.github.com/gvx/9072860
-- memoize caches results from a function given a specific set of args
-- get_stencil_clip does a bunch of heavy math to gather a list of vertices
-- and benefits significantly from caching
Element._set_stencil = lume.memoize(function (self, x, y, w, h, precision, tl, tr, br, bl)
	local corners = { tl, tr, br, bl }
	local polygon = {}

	-- true if on x/y, false if on w/h; TL, TR, BR, BL
	local xs = { true, false, false, true  }
	local ys = { true, true,  false, false }

	-- Loop through each corner and calculate points based on [r]adius!
	for i, r in ipairs(corners) do
		if r == 0 then
			table.insert(polygon, xs[i] and x or x+w)
			table.insert(polygon, ys[i] and y or y+h)
		else
			for j = 0, precision do
				local angle = (j / precision + (i - 3)) * math.pi / 2
				table.insert(polygon, (xs[i] and x+r or x+w-r) + r * math.cos(angle))
				table.insert(polygon, (ys[i] and y+r or y+h-r) + r * math.sin(angle))
			end
		end
	end

	self.stencil = polygon
end)

function Element:apply_styles()
	local ep = self.properties

	local function check_percent(value, axis)
		if type(value) == "string" and value:sub(-1) == "%" then
			value = tonumber(value:sub(1, -2)) / 100

			if value then
				local px = 0
				local py = 0
				local pw = self.width
				local ph = self.height

				if element.parent then
					px, py, pw, ph = self.parent:_get_content_position()
				end

				if axis == "x" then
					value = value * pw
				elseif axis == "y" then
					value = value * ph
				end
			end
		end

		return value
	end

	local function check_property(property, value, axis)
		ep[property] = check_percent(value, axis)
	end

	local function check_vec2(property, value)
		ep[property] = {
			check_percent(value[1], "x"),
			check_percent(value[2], "y"),
		}
	end

	-- Expand margin/border/padding to longform
	local function expand_box(property, value)
		local top    = string.format("%s_top",    property)
		local right  = string.format("%s_right",  property)
		local bottom = string.format("%s_bottom", property)
		local left   = string.format("%s_left",   property)

		if type(value) == "number" or type(value) == "string" then
			ep[top]    = check_percent(value, "y")
			ep[right]  = check_percent(value, "x")
			ep[bottom] = check_percent(value, "y")
			ep[left]   = check_percent(value, "x")
		elseif #value == 1 then
			ep[top]    = check_percent(value[1], "y")
			ep[right]  = check_percent(value[1], "x")
			ep[bottom] = check_percent(value[1], "y")
			ep[left]   = check_percent(value[1], "x")
		elseif #value == 2 then
			ep[top]    = check_percent(value[1], "y")
			ep[right]  = check_percent(value[2], "x")
			ep[bottom] = check_percent(value[1], "y")
			ep[left]   = check_percent(value[2], "x")
		else
			ep[top]    = check_percent(value[1], "y")
			ep[right]  = check_percent(value[2], "x")
			ep[bottom] = check_percent(value[3], "y")
			ep[left]   = check_percent(value[4], "x")
		end
	end

	-- Expand border_color to longform
	local function expand_border_color(value)
		local top    = "border_top_color"
		local right  = "border_right_color"
		local bottom = "border_bottom_color"
		local left   = "border_left_color"

		if type(value[1]) == "number" then
			ep[top]    = value
			ep[right]  = value
			ep[bottom] = value
			ep[left]   = value
		elseif #value == 1 then
			ep[top]    = value[1]
			ep[right]  = value[1]
			ep[bottom] = value[1]
			ep[left]   = value[1]
		elseif #value == 2 then
			ep[top]    = value[1]
			ep[right]  = value[2]
			ep[bottom] = value[1]
			ep[left]   = value[2]
		else
			ep[top]    = value[1]
			ep[right]  = value[2]
			ep[bottom] = value[3]
			ep[left]   = value[4]
		end
	end

	-- Expand border_radius to longform
	local function expand_border_radius(element, value)
		local top    = "border_top_left_radius"
		local right  = "border_top_right_radius"
		local bottom = "border_bottom_right_radius"
		local left   = "border_bottom_left_radius"

		if type(value) == "number" then
			ep[top]    = value
			ep[right]  = value
			ep[bottom] = value
			ep[left]   = value
		elseif #value == 1 then
			ep[top]    = value[1]
			ep[right]  = value[1]
			ep[bottom] = value[1]
			ep[left]   = value[1]
		elseif #value == 2 then
			ep[top]    = value[1]
			ep[right]  = value[2]
			ep[bottom] = value[1]
			ep[left]   = value[2]
		else
			ep[top]    = value[1]
			ep[right]  = value[2]
			ep[bottom] = value[3]
			ep[left]   = value[4]
		end
	end

	-- Check all properties for special cases
	local function set_property(property, value)
		ep[property] = value

		if property == "margin"  or
		   property == "border"  or
		   property == "padding" then
			expand_box(property, value)
		elseif property == "border_color" then
			expand_border_color(value)
		elseif property == "border_radius" then
			expand_border_radius(value)
		elseif property == "top"
			or property == "bottom"
			or property == "margin_top"
			or property == "margin_bottom"
			or property == "border_top"
			or property == "border_bottom"
			or property == "padding_top"
			or property == "padding_bottom"
			or property == "height"
			or property == "min_height"
			or property == "max_height" then
				check_property(property, value, "y")
		elseif property == "right"
			or property == "left"
			or property == "margin_right"
			or property == "margin_left"
			or property == "border_right"
			or property == "border_left"
			or property == "padding_right"
			or property == "padding_left"
			or property == "width"
			or property == "min_width"
			or property == "max_width" then
				check_property(property, value, "x")
		elseif property == "background_position"
			or property == "background_size" then
				check_vec2(property, value)
		elseif property == "background_path" then
			if not self.gui:get_cache(value) then
				if value:sub(-5) == "9.png" then
					self.gui:set_cache(value, patchy.load(value))
				else
					self.gui:set_cache(value, love.graphics.newImage(value, {srgb=self.gui.srgb}))
				end
			end

			ep.background_image = self.gui:get_cache(value)
		elseif property == "font_path" then
			local font_size = (self.custom_properties.font_size ~= "inherit" and self.custom_properties.font_size)
				or (ep.font_size ~= "inherit" and ep.font_size)
				or (self.default_properties.font_size ~= "inherit" and self.default_properties.font_size)
				or Initial.font_size
			if not self.gui:get_cache(value..font_size) then
				if value == "default" then
					self.gui:set_cache(value..font_size, love.graphics.newFont(font_size))
				else
					self.gui:set_cache(value..font_size, love.graphics.newFont(value, font_size))
				end
			end

			ep.font = self.gui:get_cache(value..font_size)
		elseif property == "font_size" then
			local font_path = (self.custom_properties.font_path ~= "inherit" and self.custom_properties.font_path)
				or (ep.font_path ~= "inherit" and ep.font_path)
				or (self.default_properties.font_path ~= "inherit" and self.default_properties.font_path)
				or "default"

			if not self.gui:get_cache(font_path..value) then
				if font_path == "default" then
					self.gui:set_cache(font_path..value, love.graphics.newFont(value))
				else
					self.gui:set_cache(font_path..value, love.graphics.newFont(font_path, value))
				end
			end

			ep.font = self.gui:get_cache(font_path..value)
		elseif property == "cursor" then
			ep.cursor = love.mouse.getSystemCursor(value)
		elseif property == "nav_up"
			or property == "nav_right"
			or property == "nav_down"
			or property == "nav_left" then
				ep[property] = self.gui:get_element_by_id(value)
		elseif property == "overflow" then
			ep.overflow_x = value
			ep.overflow_y = value

			if value == "scroll" then
				self.on_mouse_scrolled = self.default_on_mouse_scrolled
			end
		end
	end

	local function check_value(property, value)
		if value == "initial" then
			return Initial[property]
		end

		if value == "inherit" then
			if self.parent then
				return check_value(property, self.parent.properties[property])
			else
				return Initial[property]
			end
		end

		if value == "none" then
			return
		end

		return value
	end

	for k in pairs(self.properties) do
		self.properties[k] = nil
	end

	-- We need to gather up all the styles and order them
	local function priority_styles(styles)
		local list = {
			"width",
			"height",
			"margin",
			"margin_top",
			"margin_right",
			"margin_bottom",
			"margin_left",
			"border",
			"border_top",
			"border_right",
			"border_bottom",
			"border_left",
			"padding",
			"padding_top",
			"padding_right",
			"padding_bottom",
			"padding_left",
		}

		for k = #list, 1, -1 do
			if styles[list[k]] then
				local value = check_value(list[k], styles[list[k]])
				set_property(list[k], value)
			else
				table.remove(list, k)
			end
		end

		for property, value in pairs(styles) do
			local found = false

			for k, style in ipairs(list) do
				if property == style then
					found = true
					break
				end
			end

			if not found then
				value = check_value(property, value)
				set_property(property, value)
			end
		end
	end

	-- Apply default properties
	priority_styles(self.default_properties)

	-- Apply query properties
	for _, style in ipairs(self.styles) do
		priority_styles(style)
	end

	-- Apply custom properties
	priority_styles(self.custom_properties)
end

return Element
