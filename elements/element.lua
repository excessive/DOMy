local path    = ... .. "."
local Class   = require(path.."thirdparty.hump.class")
local cpml    = require(path.."thirdparty.cpml")
local Element = Class {}

function Element:init(element, parent, gui)
	self.gui                = gui
	self.focus              = false
	self.type               = element[1]
	self.value              = ""
	self.parent             = parent          or false
	self.id                 = element.id      or false
	self.scroll_size        = cpml.vec2(0, 0) -- dp scrollable
	self.scroll_position    = cpml.vec2(0, 0) -- % scrolled
	self.children           = {}
	self.properties         = {}
	self.custom_properties  = {}
	self.default_properties = {
		display = "inline",
		visible = true,

		-- TOP, RIGHT, BOTTOM, LEFT
		margin  = { 0, 0, 0, 0 },
		border  = { 0, 0, 0, 0 },
		padding = { 0, 0, 0, 0 },
	}

	if element.value then
		self.value = element.value
	elseif type(element[2]) ~= "table" then
		self.value = element[2]
	end

	if type(element.class) ~= "table" then
		self.class = { element.class }
	else
		self.class = element.class
	end

	self.on_focus             = function(self, focus) end

	self.on_mouse_enter       = function(self) end
	self.on_mouse_over        = function(self) end
	self.on_mouse_leave       = function(self) end
	self.on_mouse_pressed     = function(self, button) end
	self.on_mouse_released    = function(self, button) end
	self.on_mouse_clicked     = function(self, button) end
	self.on_mouse_down        = function(self, button) end
	self.on_mouse_scroll      = function(self, direction) end

	self.on_key_pressed       = function(self, key) end
	self.on_key_released      = function(self, key) end
	self.on_key_down          = function(self, key) end
	self.on_text_input        = function(self, text) end

	self.on_touch_pressed     = function(self) end
	self.on_touch_released    = function(self) end
	self.on_touch_moved       = function(self) end
	self.on_touch_gestured    = function(self, gesture) end

	self.on_joystick_added    = function(self) end
	self.on_joystick_removed  = function(self) end
	self.on_joystick_pressed  = function(self, button) end
	self.on_joystick_released = function(self, button) end
	self.on_joystick_down     = function(self, button) end
	self.on_joystick_axis     = function(self, axis) end
	self.on_joystick_hat      = function(self, hat) end

	self.on_gamepad_pressed   = function(self, button) end
	self.on_gamepad_released  = function(self, button) end
	self.on_gamepad_down      = function(self, button) end
	self.on_gamepad_axis      = function(self, axis) end
end

function Element:_get_position()
	if self.parent then
		for k, child in ipairs(self.parent.children) do
			if child == self then
				return k
			end
		end
	end

	return false
end

function Element:has_property(property)
	return self.properties[property] ~= nil
end

function Element:get_property(property)
	return self.properties[property]
end

function Element:set_property(property, value)
	self.properties[property] = value
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

		local position = old:_get_position()
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

	local position = element:_get_position()

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
end

function Element:detach()
	if not self.parent then
		error("No parent to detatch from.")
	end

	table.remove(self.parent.children, self:_get_position())
	self.parent = false

	return self
end

function Element:destroy()
	-- Loop recursively through all children
	for i=1, #self.children do
		self.children[1]:destroy()
	end

	-- Remove self from parent
	if self.parent then
		table.remove(self.parent.children, self:_get_position())
		self.parent = false
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

	-- Clone callbacks
	clone.on_focus             = self.on_focus

	clone.on_mouse_enter       = self.on_mouse_enter
	clone.on_mouse_over        = self.on_mouse_over
	clone.on_mouse_leave       = self.on_mouse_leave
	clone.on_mouse_pressed     = self.on_mouse_pressed
	clone.on_mouse_released    = self.on_mouse_released
	clone.on_mouse_clicked     = self.on_mouse_clicked
	clone.on_mouse_down        = self.on_mouse_down
	clone.on_mouse_scroll      = self.on_mouse_scroll

	clone.on_key_pressed       = self.on_key_pressed
	clone.on_key_released      = self.on_key_released
	clone.on_key_down          = self.on_key_down
	clone.on_text_input        = self.on_text_input

	clone.on_touch_pressed     = self.on_touch_pressed
	clone.on_touch_released    = self.on_touch_released
	clone.on_touch_moved       = self.on_touch_moved
	clone.on_touch_gestured    = self.on_touch_gestured

	clone.on_joystick_added    = self.on_joystick_added
	clone.on_joystick_removed  = self.on_joystick_removed
	clone.on_joystick_pressed  = self.on_joystick_pressed
	clone.on_joystick_released = self.on_joystick_released
	clone.on_joystick_down     = self.on_joystick_down
	clone.on_joystick_axis     = self.on_joystick_axis
	clone.on_joystick_hat      = self.on_joystick_hat

	clone.on_gamepad_pressed   = self.on_gamepad_pressed
	clone.on_gamepad_released  = self.on_gamepad_released
	clone.on_gamepad_down      = self.on_gamepad_down
	clone.on_gamepad_axis      = self.on_gamepad_axis

	-- Deep clone all children
	if deep then
		for _, child in ipairs(self.children) do
			child:clone(deep, clone)
		end
	end

	-- Add self to parent
	if parent then
		parent:add_child(clone)
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
	local position = self:_get_position()

	if position then
		local prev = position - 1

		if prev > 0 then
			return self.parent.children[prev]
		end
	end

	return false
end

function Element:next_sibling()
	local position = self:_get_position()

	if position then
		local nxt = position + 1

		if nxt <= #self.parent.children then
			return self.parent.children[nxt]
		end
	end

	return false
end

function Element:scroll_into_view()
	-- If parent is scrollable, scroll it so that self is visible
	-- Self should be wholy visible or if too large, the top should match parent's top
end

return Element
