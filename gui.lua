local path     = (...):gsub('%.[^%.]+$', '') .. "."
local initial  = require(path.."properties.initial")
local patchy   = require(path.."thirdparty.patchy")
local lume     = require(path.."thirdparty.lume")
local elements = {}
local widgets  = {}
local GUI      = {}

function GUI:init(width, height)
	-- Load default elements
	local element_path  = path:gsub("%.", "/") .. "elements/"
	local element_files = love.filesystem.getDirectoryItems(element_path)

	for _, file in ipairs(element_files) do
		local name = file:sub(1, -5)
		if file ~= "element.lua" and file:sub(-4) == ".lua" then
			elements[name] = love.filesystem.load(element_path..file)(path)
		end
	end

	self._debug        = false
	self.last_focus    = false
	self.navigation    = false
	self.cache         = {}
	self.draw_order    = {}
	self.elements      = {}
	self.styles        = {}
	self.key_down      = {}
	self.joystick_down = {}
	self.gamepad_down  = {}
	self.mouse_down    = {}
	self.nav           = {
		up    = {},
		right = {},
		down  = {},
		left  = {},
	}
	self.pseudo        = {
		focus = false,
		hover = false,
	}
	self.srgb          = select(3, love.window.getMode()).srgb
	self.mx, self.my   = love.mouse.getPosition()

	-- Set size of GUI
	if width and height then
		self.width, self.height = width, height
	else
		self.width, self.height = love.graphics.getDimensions()
	end

	-- Prepare callbacks
	local Callback = require(path.."callback")
	local list     = self:get_callbacks()
	for _, v in ipairs(list) do
		self[v] = Callback[v]
	end

	-- Prepare file imports
	local Import = require(path.."import")
	for k in pairs(Import) do
		self["import_"..k] = Import[k]
	end

	-- Prepare pseudo checks
	local Pseudo = require(path.."pseudo")
	for k in pairs(Pseudo) do
		self["_check_pseudo_"..k] = Pseudo[k]
	end

	-- Add default widgets
	local widget_path  = path:gsub("%.", "/") .. "widgets/"
	self:add_widget_directory(widget_path)
end

function GUI:register_function(name, func)
	if not self[name] then
		self[name] = func
		return true
	end

	error(string.format("\"%s\" already defined.", name))
end

function GUI:register_callbacks(state, reject)
	-- If no state added, default to love global
	if not state then state = love end

	-- Grab all DOMy callbacks
	local callbacks = self:get_callbacks()

	-- Specify callbacks we do not want to register
	if reject and type(reject) == "table" then
		callbacks = lume.reject(callbacks, function(v)
			for _, cb in ipairs(reject) do
				if v == cb then
					return true
				end
			end
			return false
		end)
	end

	-- Register remaining callbacks if not already registered
	for _, cb in ipairs(callbacks) do
		if not state[cb] then
			state[cb] = function(ignore_me, ...)
				self[cb](self, ...)
			end
		end
	end
end

function GUI:get_callbacks()
	return {
		"update",
		"draw",
		"keypressed",
		"keyreleased",
		"textinput",
		"mousepressed",
		"mousereleased",
		"mousemoved",
		"joystickadded",
		"joystickremoved",
		"joystickpressed",
		"joystickreleased",
		"joystickaxis",
		"joystickhat",
		"gamepadpressed",
		"gamepadreleased",
		"gamepadaxis",
		"resize"
	}
end

function GUI:new_element(element, parent, position)
	-- If we just want a default element, just pass in the element type!
	if type(element) == "string" then
		element = { element }
	end

	-- If no element type is found, don't create that element
	if not elements[element[1]] then return false end

	-- Create the element and insert it into the global elements list
	local object = setmetatable({}, { __index = elements[element[1]] })
	object:init(element, parent, self)
	table.insert(self.elements, object)

	if parent then
		-- If the element has a parent, send it along
		parent:add_child(object, position)
	else
		-- Otherwise, add it to the draw stack
		table.insert(self.draw_order, object)
	end

	return object
end

function GUI:new_widget(widget)
	return widgets[widget]()
end

function GUI:bubble_event(element, event, ...)
	local bubble = true

	-- We only want to execute this once. If a child is entered, do not execute again
	if event == "on_mouse_enter" then
		if element.entered then
			bubble = false
		else
			element.entered = true
		end
	end

	-- If a child is left, we may not have left the parent!
	if event == "on_mouse_leave" then
		if element.entered and not element:is_binding(love.mouse.getPosition()) then
			element.entered = false
		else
			bubble = false
		end
	end

	if bubble and element[event] then
		if ... then
			bubble = element[event](element, unpack({ ... }))
		else
			bubble = element[event](element)
		end
	end

	if bubble and element.parent then
		self:bubble_event(element.parent, event, ...)
	end
end

function GUI:get_focus()
	return self.pseudo.focus
end

function GUI:set_focus(element)
	love.keyboard.setKeyRepeat(true)

	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_focus_leave")
	end

	self.last_focus   = element
	self.pseudo.focus = element
	self:bubble_event(self.pseudo.focus, "on_focus")

	return self.pseudo.focus
end

function GUI:remove_focus()
	if self.pseudo.focus then
		self:bubble_event(self.pseudo.focus, "on_focus_leave")
	end

	self.pseudo.focus = false

	love.keyboard.setKeyRepeat(true)
end

function GUI:get_cache(path)
	return self.cache[path]
end

function GUI:set_cache(path, data)
	if not self.cache[path] then
		self.cache[path] = data
	end
end

function GUI:remove_cache(path)
	self.cache[path] = nil
end

function GUI:get_navigation_key(direction)
	return self.nav[direction]
end

function GUI:add_navigation_key(direction, ...)
	for _, key in ipairs({ ... }) do
		table.insert(self.nav[direction], key)
	end
end

function GUI:remove_navigation_key(direction, ...)
	for _, key in ipairs({ ... }) do
		for i, v in ipairs(self.nav[direction]) do
			if key == v then
				table.remove(self.nav[direction], i)
				break
			end
		end
	end
end

function GUI:toggle_navigation()
	self.navigation = not self.navigation
end

function GUI:enable_navigation()
	self.navigation = true
end

function GUI:disable_navigation()
	self.navigation = false
end

function GUI:add_widget_directory(path)
	if path:sub(-1) ~= "/" then
		path = path .. "/"
	end

	-- add directory
	local folders = love.filesystem.getDirectoryItems(path)

	-- add associated widgets
	for _, widget in ipairs(folders) do
		if love.filesystem.isDirectory(path..widget) then
			widgets[widget] = love.filesystem.load(path..widget.."/markup.lua")

			self:import_styles(path..widget.."/styles.lua")
			--self:import_scripts(path..widget.."/scripts.lua")
		end
	end
end

function GUI:get_elements()
	local e = {}

	for k in pairs(elements) do
		table.insert(e, k)
	end

	return e
end

function GUI:get_widgets()
	local w = {}

	for k in pairs(widgets) do
		table.insert(w, k)
	end

	return w
end

function GUI:process_widget(data, widget)
	local function loop(element)
		-- loop through children
		for k, child in ipairs(element) do
			if type(child) == "table" then
				-- apply data as needed
				for i, property in pairs(data) do
					if child.class == element.class.."_"..i then
						-- If a collection of elements
						if type(property) == "table" and type(property[1]) ~= "string" then
							for _, p in ipairs(property) do
								table.insert(child, p)
							end
						else
							table.insert(child, property)
						end
					end
				end

				-- recursive loop
				loop(child)
			end
		end
	end

	local container = self:new_widget(widget)

	if data.id then
		container.id = data.id
	end

	loop(container)

	return container
end

function GUI:get_elements_by_bound(x, y)
	local filter = {}

	for _, element in ipairs(self.elements) do
		if element:is_binding(x, y) then
			table.insert(filter, element)
		end
	end

	return filter
end

function GUI:get_element_by_id(id, elements)
	elements = elements or self.elements

	for _, element in ipairs(elements) do
		if element.id == id then
			return element
		end
	end

	return false
end

function GUI:get_elements_by_type(type, elements)
	elements = elements or self.elements

	local filter = {}

	for _, element in ipairs(elements) do
		if element.type == type then
			table.insert(filter, element)
		end
	end

	return filter
end

function GUI:get_elements_by_class(class, elements)
	elements = elements or self.elements

	local filter = {}

	for _, element in ipairs(elements) do
		for _, eclass in ipairs(element.class) do
			if eclass == class then
				table.insert(filter, element)
				break
			end
		end
	end

	return filter
end

function GUI:get_elements_by_query(query, elements)
	elements = elements or self.elements

	-- https://love2d.org/forums/viewtopic.php?f=4&t=79562&p=179516#p179515
	local function get_groups(query)
		local groups = {}

		-- every group of one or more nonspace characters
		for match in query:gmatch("%S+") do
			local group = {
				elements = {},
				ids      = {},
				classes  = {},
				pseudos  = {},
			}

			-- match every keyword and their preceding but optional symbol
			for char, keyword in match:gmatch("([#%.:]?)([%w_]+)") do
				local category =          -- sort them by their symbol
				char == '#' and 'ids'     or
				char == '.' and 'classes' or
				char == ':' and 'pseudos' or
				'elements'                -- or lack thereof

				table.insert(group[category], keyword)
			end

			table.insert(groups, group)
		end

		return groups
	end

	local groups  = get_groups(query)
	local section = {}

	for k, group in ipairs(groups) do
		section[k] = elements

		if #group.ids > 0 then
			section[k] = { self:get_element_by_id(group.ids[1], section[k]) }
		end

		if #group.elements > 0 then
			section[k] = self:get_elements_by_type(group.elements[1], section[k])
		end

		if #group.classes > 0 then
			for _, class in ipairs(group.classes) do
				section[k] = self:get_elements_by_class(class, section[k])
			end
		end

		if #group.pseudos > 0 then
			for _, pseudo in ipairs(group.pseudos) do
				local selector, value = pseudo:match("([^%(%s]+)%(([^%)]*)%)")

				if selector then
					section[k] = self["_check_pseudo_"..selector](self, section[k], value)
				else
					section[k] = self["_check_pseudo_"..pseudo](self, section[k])
				end
			end
		end
	end

	-- Search family for a particular element
	local function check_hierarchy(element, seek)
		local element = element.parent

		if element then
			if element == seek then
				return true
			else
				return check_hierarchy(element, seek)
			end
		end

		return false
	end

	local filter = {}

	-- Build a filter based on hierarchy
	for i=1, #section do
		local current = #section - i + 1
		local parent = current - 1
		local finish  = 1

		-- If there is no descendent selector, just return the group
		if #section == 1 then
			return section[1]
		elseif parent > 0 then
			for _, element in ipairs(section[current]) do
				for _, parent in ipairs(section[parent]) do
					if check_hierarchy(element, parent) then
						table.insert(filter, element)
					end
				end
			end
		end
	end

	return filter
end

function GUI:set_styles()
	for _, element in ipairs(self.elements) do
		for k in pairs(element.styles) do
			element.styles[k] = nil
		end
	end

	for _, style in ipairs(self.styles) do
		local filter = self:get_elements_by_query(style.query)

		for _, element in ipairs(filter) do
			if element then
				table.insert(element.styles, style.properties)
			end
		end
	end
end

function GUI:apply_styles()
	local function check_percent(element, value, axis)
		if type(value) == "string" and value:sub(-1) == "%" then
			value = tonumber(value:sub(1, -2)) / 100

			if value then
				local px = 0
				local py = 0
				local pw = self.width
				local ph = self.height

				if element.parent then
					px, py, pw, ph = element.parent:_get_content_position()
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

	local function check_property(element, property, value, axis)
		element.properties[property] = check_percent(element, value, axis)
	end

	local function check_vec2(element, property, value)
		element.properties[property] = {
			check_percent(element, value[1], "x"),
			check_percent(element, value[2], "y"),
		}
	end

	-- Expand margin/border/padding to longform
	local function expand_box(element, property, value)
		local ep     = element.properties
		local top    = string.format("%s_top",    property)
		local right  = string.format("%s_right",  property)
		local bottom = string.format("%s_bottom", property)
		local left   = string.format("%s_left",   property)

		if type(value) == "number" or type(value) == "string" then
			ep[top]    = check_percent(element, value, "y")
			ep[right]  = check_percent(element, value, "x")
			ep[bottom] = check_percent(element, value, "y")
			ep[left]   = check_percent(element, value, "x")
		elseif #value == 1 then
			ep[top]    = check_percent(element, value[1], "y")
			ep[right]  = check_percent(element, value[1], "x")
			ep[bottom] = check_percent(element, value[1], "y")
			ep[left]   = check_percent(element, value[1], "x")
		elseif #value == 2 then
			ep[top]    = check_percent(element, value[1], "y")
			ep[right]  = check_percent(element, value[2], "x")
			ep[bottom] = check_percent(element, value[1], "y")
			ep[left]   = check_percent(element, value[2], "x")
		else
			ep[top]    = check_percent(element, value[1], "y")
			ep[right]  = check_percent(element, value[2], "x")
			ep[bottom] = check_percent(element, value[3], "y")
			ep[left]   = check_percent(element, value[4], "x")
		end
	end

	-- Expand border_color to longform
	local function expand_border_color(element, value)
		local ep     = element.properties
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
		local ep     = element.properties
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
	local function set_property(element, property, value)
		if not element then return end

		local ep = element.properties
		ep[property] = value

		if property == "margin"  or
		   property == "border"  or
		   property == "padding" then
			expand_box(element, property, value)
		elseif property == "border_color" then
			expand_border_color(element, value)
		elseif property == "border_radius" then
			expand_border_radius(element, value)
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
				check_property(element, property, value, "y")
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
				check_property(element, property, value, "x")
		elseif property == "background_position"
			or property == "background_size" then
				check_vec2(element, property, value)
		elseif property == "background_path" then
			if not self:get_cache(value) then
				if value:sub(-5) == "9.png" then
					self:set_cache(value, patchy.load(value))
				else
					self:set_cache(value, love.graphics.newImage(value))
				end
			end

			ep.background_image = self:get_cache(value)
		elseif property == "font_path" then
			local font_size = (element.custom_properties.font_size ~= "inherit" and element.custom_properties.font_size)
				or (ep.font_size ~= "inherit" and ep.font_size)
				or (element.default_properties.font_size ~= "inherit" and element.default_properties.font_size)
				or initial.font_size

			if not self:get_cache(value..font_size) then
				if value == "default" then
					self:set_cache(value..font_size, love.graphics.newFont(font_size))
				else
					self:set_cache(value..font_size, love.graphics.newFont(value, font_size))
				end
			end

			ep.font = self:get_cache(value..font_size)
		elseif property == "font_size" then
			local font_path = (element.custom_properties.font_path ~= "inherit" and element.custom_properties.font_path)
				or (ep.font_path ~= "inherit" and ep.font_path)
				or (element.default_properties.font_path ~= "inherit" and element.default_properties.font_path)
				or "default"

			if not self:get_cache(font_path..value) then
				if font_path == "default" then
					self:set_cache(font_path..value, love.graphics.newFont(value))
				else
					self:set_cache(font_path..value, love.graphics.newFont(font_path, value))
				end
			end

			ep.font = self:get_cache(font_path..value)
		elseif property == "cursor" then
			ep.cursor = love.mouse.getSystemCursor(value)
		elseif property == "nav_up"
			or property == "nav_right"
			or property == "nav_down"
			or property == "nav_left" then
				ep[property] = self:get_element_by_id(value)
		elseif property == "overflow" then
			ep.overflow_x = value
			ep.overflow_y = value

			if value == "scroll" then
				element.on_mouse_scrolled = element.default_on_mouse_scrolled
			end
		end
	end

	local function loop_elements(element)
		local function check_value(element, property, value)
			if value == "initial" then
				value = initial[property] or value
			end

			if value == "inherit" then
				if element.parent then
					value = element.parent.properties[property] or nil
				end
			end

			return value
		end

		for k in pairs(element.properties) do
			element.properties[k] = nil
		end

		-- Apply default properties
		for property, value in pairs(element.default_properties) do
			value = check_value(element, property, value)
			set_property(element, property, value)
		end

		-- Apply query properties
		for _, style in ipairs(element.styles) do
			for property, value in pairs(style) do
				value = check_value(element, property, value)
				set_property(element, property, value)
			end
		end

		-- Apply custom properties
		for property, value in pairs(element.custom_properties) do
			value = check_value(element, property, value)
			set_property(element, property, value)
		end

		-- Apply styles to children
		if #element.children > 0 then
			for _, e in ipairs(element.children) do
				loop_elements(e)
			end
		end
	end

	-- Apply styles in draw order
	for _, element in ipairs(self.draw_order) do
		loop_elements(element)
	end
end

function GUI:_font_getWrap(font, text, width)
	local lines      = {}
	local act_width  = 0
	local line_width = 0

	for word in text:gmatch("%S+") do
		local w = font:getWidth(" " .. word)

		if line_width + w > width or line_width == 0 then
			table.insert(lines, word)
			line_width = font:getWidth(word)
		else
			lines[#lines] = lines[#lines] .. " " .. word
			line_width = line_width + w
		end
	end

	for k, line in ipairs(lines) do
		local w = font:getWidth(line)

		if w > act_width then
			act_width = w
		end
	end

	return act_width, lines
end

return GUI
