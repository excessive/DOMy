local path     = (...):gsub('%.[^%.]+$', '') .. "."
local Display  = require(path.."properties.display")
local lume     = require(path.."thirdparty.lume")
local elements = {}
local widgets  = {}
local GUI      = {}

function GUI:init(width, height)
	-- Load default elements
	local element_list = {
		"block",
		"button",
		"image",
		"inline",
		"text",
		"textfield",
		"textinput"
	}
	for _, file in ipairs(element_list) do
		elements[file] = require(path.."elements." .. file)
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
	if not elements[element[1]] then
		return false
	end

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

	-- Apply any styles associated with element
	object:apply_styles()

	-- Apply position
	local ep = object.properties
	local d  = ep.display
	local x  = 0
	local y  = 0
	local w  = self.width  - x
	local h  = self.height - y

	if self.parent then
		d = "child"
		x, y, w, h = self.parent:_get_position("content")
	end

	-- Parent box
	local parent = {
		x = x,
		y = y,
		w = w,
		h = h,
	}

	object.visible = Display.get_visible(object)
	Display[ep.display](object, d, x, y, 0, parent)

	return object
end

function GUI:clear_styles()
	self.styles = {}
	self:resize()
end

function GUI:new_widget(widget)
	return widgets[widget]()
end

function GUI:bubble_event(element, event, ...)
	local bubble = true

	-- We only want to execute these once. If a child is entered, do not execute again
	if event == "on_focus" then
		if element.focus then
			bubble = false
		else
			element.focus = true
		end
	end

	if event == "on_mouse_enter" then
		if element.entered then
			bubble = false
		else
			element.entered = true
		end
	end

	-- If a child is left, we may not have left the parent!
	if event == "on_focus_leave" then
		if element.focus and (not self.pseudo.focus or (self.pseudo.focus and not self.pseudo.focus:is_descendant(element))) then
			element.focus = false
		else
			bubble = false
		end
	end

	if event == "on_mouse_leave" then
		if element.entered and (not self.pseudo.hover or (self.pseudo.hover and not self.pseudo.hover:is_descendant(element))) then
			element.entered = false
		else
			bubble = false
		end
	end

	-- Bubble events
	if bubble and element[event] then
		if ... then
			bubble = element[event](element, unpack({ ... }))
		else
			bubble = element[event](element)
		end
	end

	if bubble ~= false and element.parent then
		self:bubble_event(element.parent, event, ...)
	end
end

function GUI:get_focus()
	return self.pseudo.focus
end

function GUI:set_focus(element)
	love.keyboard.setKeyRepeat(true)

	local old_focus   = self.pseudo.focus
	self.last_focus   = element
	self.pseudo.focus = element

	if old_focus then
		self:bubble_event(old_focus, "on_focus_leave")
	end

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

			if love.filesystem.isFile(path..widget.."/styles.lua") then
				self:import_styles(path..widget.."/styles.lua")
			end

			if love.filesystem.isFile(path..widget.."/scripts.lua") then
				self:import_scripts(path..widget.."/scripts.lua")
			end
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
	local function loop(element, parent)
		-- Convert class to table
		if not element.class then
			error("Widget elements must contain a valid class.")
		elseif type(element.class) == "string" then
			element.class = { element.class }
		end

		-- Loop through children
		for k, child in ipairs(element) do
			if type(child) == "table" then
				-- Convert class to table
				if not child.class then
					error("Widget elements must contain a valid class.")
				elseif type(child.class) == "string" then
					child.class = { child.class }
				end

				-- Insert elements
				local class

				for i, property in pairs(data) do
					temp = string.format("%s_%s", parent, i)
					for _, c in ipairs(child.class) do
						if c == temp then
							class = temp

							--if i ~= "class"
							if i ~= "class" and type(property) == "table" then
								if type(property[1]) == "string" then
									-- An element
									table.insert(child, property)
								else
									-- A collection of elements
									for _, p in ipairs(property) do
										table.insert(child, p)
									end
								end
							else
								child[i] = property
							end
						end
					end
				end

				-- recursive loop
				if class then
					loop(child, class)
				end
			end
		end
	end

	local container = self:new_widget(widget)

	if type(container.class) == "string" then
		container.class = { container.class }
	end

	if #container.class > 1 then
		error("Container may only contain one class.")
	end

	if data.id then
		container.id = data.id
	end

	loop(container, container.class[1])

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
	local function loop_elements(element)
		element:apply_styles()

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
