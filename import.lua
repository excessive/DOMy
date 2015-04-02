local Import = {}
local path    = (...):gsub('%.[^%.]+$', '')
local cpml    = require(path..".thirdparty.cpml")

function Import.markup(self, file)
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
	local function create_object(t, parent)
		for k, v in ipairs(t) do
			if type(v) == "table" then
				local is_element = false

				-- Check to see if valid element
				for _, e in ipairs(self:get_elements()) do
					if v[1] == e then
						is_element = true
						local object = self:new_element(v, parent)
						create_object(v, object)
						break
					end
				end

				-- If not element, check for valid widget
				if not is_element then
					for _, w in ipairs(self:get_widgets()) do
						if v[1] == w then
							t[k] = self:process_widget(v, w)
							local object = self:new_element(t[k], parent)
							create_object(t[k], object)
							break
						end
					end
				end
			end
		end
	end

	local markup

	if type(file) == "string" then
		markup = love.filesystem.load(file)
		assert(markup, string.format("Markup file (%s) not found.", file))
	else
		markup = function() return file end
	end


	local ok, err = pcall(markup)

	if ok then
		assert(check_syntax(err, true), string.format("File (%s) contains invalid markup.", file))
		create_object(err, false)
	else
		error(err)
	end
end

function Import.styles(self, file)
	local function parse_stylesheet(style, list, prepend)
		list = list or {}

		for _, query in ipairs(style) do
			-- Check all query selectors (no styles)
			if type(query) ~= "table" then
				if prepend then
					query = prepend .. " " .. query
				end

				local properties = {}

				-- Grab all of the properties (no nests!) from the style
				for property, value in pairs(style[#style]) do
					if type(property) ~= "number" then
						properties[property] = value
					end
				end

				local found = false

				-- If we already defined the style, append and overwrite new styles
				for i in ipairs(list) do
					if list[i].query == query then
						found = i
						break
					end
				end

				if not found then
					table.insert(list, { query=query, properties=properties })
				else
					for property, value in pairs(properties) do
						list[found].properties[property] = value
					end
				end

				-- If we have a nested table, do some recursion!
				for _, property in ipairs(style[#style]) do
					if type(property) == "table" then
						parse_stylesheet(property, list, query)
					end
				end
			end
		end

		return list
	end

	-- lol
	local global = {
		"bit", "math", "string", "table",
		"type", "tonumber", "tostring",
		"pairs", "ipairs", "getfenv",
		"pcall", "xpcall", "print",
		"next", "select", "unpack",
		"love",
	}

	-- Sandbox
	local env = {}

	-- Some useful globals
	for _, v in ipairs(global) do
		env[v] = _G[v]
	end

	-- Bring in various CPML functions
	env.alpha      = cpml.color.alpha
	env.clamp      = cpml.utils.clamp
	env.darken     = cpml.color.darken
	env.hsv        = cpml.color.from_hsv
	env.hsva       = cpml.color.from_hsva
	env.hue        = cpml.color.hue
	env.invert     = cpml.color.invert
	env.lighten    = cpml.color.lighten
	env.mul        = cpml.color.mul
	env.opacity    = cpml.color.opacity
	env.saturation = cpml.color.saturation
	env.value      = cpml.color.value

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

	local styles

	if type(file) == "string" then
		styles = love.filesystem.load(file)
		assert(styles, string.format("Styles file (%s) not found.", file))
	else
		styles = function() return file end
	end

	setfenv(styles, env)

	local ok, err = pcall(styles)

	if ok then
		-- This is not nil! It accumulates!
		local parsed

		-- Parse stylesheet
		for _, style in pairs(err) do
			parsed = parse_stylesheet(style, parsed)
		end

		-- Update global lookup
		for i, style in pairs(parsed) do

			local found = false

			for k in ipairs(self.styles) do
				if self.styles[k].query == style.query then
					found = k
					break
				end
			end

			if not found then
				table.insert(self.styles, { query=style.query, properties=style.properties })
			else
				for property, value in pairs(style.properties) do
					self.styles[found].properties[property] = value
				end
			end
		end

		self:set_styles()
	else
		error(err)
	end
end

function Import.scripts(self, file)
	-- Sandbox
	local env = {}

	for k in pairs(_G) do
		env[k] = _G[k]
	end

	env.gui = self

	local scripts

	if type(file) == "string" then
		scripts = love.filesystem.load(file)
		assert(scripts, string.format("Scripts file (%s) not found.", file))
	else
		scripts = function() return file end
	end

	setfenv(scripts, env)

	local ok, err = pcall(scripts)

	if not ok then
		error(err)
	end
end

return Import
