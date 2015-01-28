local elements = {}
local GUI      = {}

-- https://github.com/stevedonovan/Penlight/blob/master/lua/pl/path.lua#L286
local function format_path(path)
	local np_gen1, np_gen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
	local np_pat1, np_pat2 = np_gen1:gsub('SEP', '/'), np_gen2:gsub('SEP', '/')
	local k

	repeat -- /./ -> /
		path, k = path:gsub(np_pat2, '/')
	until k == 0

	repeat -- A/../ -> (empty)
		path, k = path:gsub(np_pat1, '')
	until k == 0

	if path == '' then path = '.' end

	return path
end

function GUI:init(path)
	-- Load the default element classes
	local new_path      = path:gsub("%.", "/") .. "elements/"
	local element_files = love.filesystem.getDirectoryItems(new_path)

	for _, file in ipairs(element_files) do
		local name = file:sub(1, -5)
		elements[name] = love.filesystem.load(new_path .. file)(path)
	end

	self.elements = {}
end

function GUI:update(dt)

end

function GUI:draw()
	--!!! ALL OF THIS CODE IS TEMPORARY AND SUBJECT TO CHANGE !!!

	--[[         ~~ BOX MODEL ~~

	{                 WIDTH                 }
	+---------------------------------------+ ~~~
	|                MARGIN                 |
	|   +-------------------------------+   |
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
	|   +-------------------------------+   |
	|                MARGIN                 |
	+---------------------------------------+ ~~~
	{                 WIDTH                 }

	--]]

	local function draw_element(element, x, y)
		local ep = element.properties

		-- TL position of element
		x = x or 0
		y = y or 0

		-- Full size of element
		local w = ep.width
		local h = ep.height

		-- Content start of element
		local sw = x + ep.padding[4] + ep.border[4]
		local sh = y + ep.padding[1] + ep.border[1]

		-- Content end of element
		local ew = x + w - (sw - w) - ep.padding[2] - ep.border[2]
		local eh = y + h - (sh - h) - ep.padding[3] - ep.border[3]

		love.graphics.rectangle("line", x, y, w, h)
		if ep.text_color then
			love.graphics.setColor(ep.text_color)
		end
		love.graphics.printf(tostring(element.value), sw, sh, ew)
		love.graphics.setColor({ 255, 255, 255, 255})

		-- Accumulated Child positions
		local cw = 0
		local ch = 0
		for _, child in ipairs(element.children) do
			local cp = child.properties

			if cp.display == "inline" then
				draw_element(child, ep.margin[4] + sw + cw, sh + ep.margin[1])
			elseif cp.display == "block" then
				draw_element(child, ep.margin[4] + sw, sh + ch + ep.margin[1])
			end

			cw = cw + child.properties.width  + ep.margin[2] + ep.margin[4]
			ch = ch + child.properties.height + ep.margin[1] + ep.margin[3]
		end
	end

	-- Accumulated root positions
	local rw = 0
	local rh = 0
	for _, element in ipairs(self.elements) do
		if not element.parent then
			local ep = element.properties
			local d = ep.display
			if d == "inline" then
				draw_element(element, ep.margin[4] + rw, ep.margin[1])
			elseif d == "block" then
				draw_element(element, ep.margin[4], rh + ep.margin[1])
			end

			rw = rw + ep.width  + ep.margin[2] + ep.margin[4]
			rh = rh + ep.height + ep.margin[1] + ep.margin[3]
		end
	end
end

function GUI:import_markup(file)
	-- This function will return true if every key is a properly formatted table
	-- This does not take into account if the proposed element is a valid element
	local function check_syntax(t, root)
		for k, v in ipairs(t) do
			-- All elements in root must be tables
			if root and type(v) ~= "table" then
				print("Invalid root")
				return false
			end

			-- Key 1 is reserved for the element type
			if not root and k == 1 and type(v) ~= "string" then
				print("Invalid type")
				return false
			end

			-- Key 2 can be the element value or a child element
			if type(v) == "table" then
				if not check_syntax(v) then return false end
			elseif k > 2 then
				print("Invalid child")
				return false
			end
		end

		return true
	end

	-- Loops through the markup to generate element objects
	-- Assign parent and child relationships when necessary
	local function create_object(t, parent)
		for k, v in ipairs(t) do
			if type(v) == "table" then
				local object = self:new_element(v, parent)
				create_object(v, object)
			end
		end
	end

	local markup = love.filesystem.load(file)
	assert(markup, string.format("Markup file (%s) not found.", file))

	markup = markup()
	assert(check_syntax(markup, true), string.format("File (%s) contains invalid markup.", file))

	create_object(markup, false)
end

function GUI:import_styles(file)
	-- https://love2d.org/forums/viewtopic.php?f=4&t=79562&p=179516#p179515
	local function get_groups(query)
		local str = "frame#character image.icon:last"
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
			for char, keyword in match:gmatch("([#%.:]?)([%w-_]+)") do
				local category =                -- sort them by their symbol
				char == '#' and 'ids'     or
				char == '.' and 'classes' or
				char == ':' and 'pseudos' or
				'elements'                   -- or lack thereof

				table.insert(group[category], keyword)
			end

			table.insert(groups, group)
		end

		return groups
	end

	local function filter_query(query)
		local groups = get_groups(query)
		local filter

		for level, group in ipairs(groups) do
			if #group.ids > 0 then
				filter = { self:get_element_by_id(group.ids[1], filter) }
			end

			if #group.elements > 0 then
				filter = self:get_elements_by_type(group.elements[1], filter)
			end

			if #group.classes > 0 then
				for _, class in ipairs(group.classes) do
					filter = self:get_elements_by_class(class, filter)
				end
			end

			if #group.pseudos > 0 then
				for _, pseudo in ipairs(group.pseudos) do
					--[[
					Selector				Example					Example description
					-------------------------------------------------------------------
					:active					a:active				Selects the active link
					:checked				input:checked			Selects every checked <input> element
					:disabled				input:disabled			Selects every disabled <input> element
					:empty					p:empty					Selects every <p> element that has no children
					:enabled				input:enabled			Selects every enabled <input> element
					:first-child			p:first-child			Selects every <p> elements that is the first child of its parent
					:first-of-type			p:first-of-type			Selects every <p> element that is the first <p> element of its parent
					:focus					input:focus				Selects the <input> element that has focus
					:hover					a:hover					Selects links on mouse over
					:in-range				input:in-range			Selects <input> elements with a value within a specified range
					:invalid				input:invalid			Selects all <input> elements with an invalid value
					:lang(language)			p:lang(it)				Selects every <p> element with a lang attribute value starting with "it"
					:last-child				p:last-child			Selects every <p> elements that is the last child of its parent
					:last-of-type			p:last-of-type			Selects every <p> element that is the last <p> element of its parent
					:link					a:link					Selects all unvisited links
					:not(selector)			:not(p)					Selects every element that is not a <p> element
					:nth-child(n)			p:nth-child(2)			Selects every <p> element that is the second child of its parent
					:nth-last-child(n)		p:nth-last-child(2)		Selects every <p> element that is the second child of its parent, counting from the last child
					:nth-last-of-type(n)	p:nth-last-of-type(2)	Selects every <p> element that is the second <p> element of its parent, counting from the last child
					:nth-of-type(n)			p:nth-of-type(2)		Selects every <p> element that is the second <p> element of its parent
					:only-of-type			p:only-of-type			Selects every <p> element that is the only <p> element of its parent
					:only-child				p:only-child			Selects every <p> element that is the only child of its parent
					:optional				input:optional			Selects <input> elements with no "required" attribute
					:out-of-range			input:out-of-range		Selects <input> elements with a value outside a specified range
					:read-only				input:read-only			Selects <input> elements with a "readonly" attribute specified
					:read-write				input:read-write		Selects <input> elements with no "readonly" attribute
					:required				input:required			Selects <input> elements with a "required" attribute specified
					:root					root					Selects the document's root element
					:target					#news:target			Selects the current active #news element (clicked on a URL containing that anchor name)
					:valid					input:valid				Selects all <input> elements with a valid value
					:visited				a:visited				Selects all visited links
					--]]

					if pseudo == "last" then
						filter = { filter[#filter] }
					end
				end
			end

			if level > 1 then
				local kill = {}

				for i, element in ipairs(filter) do
					local ok = element

					for j=1, level do
						ok = ok.parent

						if not ok and j < level then
							table.insert(kill, i)
							break
						end
					end
				end

				for i=1, #kill do
					table.remove(filter, kill[#kill - i + 1])
				end
			end
		end

		return filter
	end

	local styles = love.filesystem.load(file)
	assert(styles, string.format("Styles file (%s) not found.", file))

	-- lol
	local global = {
		"bit", "math", "string", "table",
		"type", "tonumber", "tostring",
		"pairs", "ipairs",
		"pcall", "xpcall",
		"next", "select", "unpack",
	}

	-- Sandbox
	local env = {}

	-- Some useful globals
	for _, v in ipairs(global) do
		env[v] = _G[v]
	end

	-- Import styles from another file
	env.import = function(file, styles)
		local import  = love.filesystem.load(file)
		local ok, err = pcall(import)

		if ok then
			env.append(import, styles)
		else
			error(err)
		end
	end

	-- Extend styles from one style to another
	-- This should search for a nested query if an ancestor is found
	--   Example: ".red .large" should search for a ".large" declaration within ".red"
	env.extend = function(from, to, styles)
		local function search(t, limit)
			for _, style in ipairs(styles) do
				for i, query in ipairs(style) do
					if query == t and (limit and i <= limit) then
						return style[#style]
					end
				end
			end
		end

		local f = search(from)
		local t = search(to, 1)

		env.mixin(f, t)
	end

	-- Mix styles into element
	env.mixin = function(from, to)
		for k, v in pairs(from) do
			if not to[k] then
				to[k] = v
			end
		end
	end

	-- Prepend data to a table
	env.prepend = function(from, to)
		for i, style in ipairs(from) do
			table.insert(to, i, style)
		end
	end

	-- Append data to a table
	env.append = function(from, to)
		for i, style in ipairs(from) do
			table.insert(to, style)
		end
	end

	setfenv(styles, env)

	local ok, err = pcall(styles)

	if ok then
		for _, style in pairs(err) do
			for _, query in ipairs(style) do
				if type(query) ~= "table" then
					local filter     = filter_query(query)
					local properties = style[#style]

					for _, element in ipairs(filter) do
						for property, value in pairs(properties) do
							element.properties[property] = value
						end
					end
				end
			end
		end
	end
end

function GUI:import_scripts(file)
	local scripts = love.filesystem.load(file)
	assert(scripts, string.format("Scripts file (%s) not found.", file))

	scripts = scripts()
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

	-- If the element has a parent, send it along
	if parent then
		parent:add_child(object, position)
	end

	return object
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

function GUI:get_elements_by_query(query) -- CSS-stype selectors such as ".header > p"
end

function GUI:set_absolute_location(element)
end

return GUI
