local path    = (...):gsub('%.[^%.]+$', '') .. "."
local Flex    = require(path.."flex")
local Display = {}

function Display.position_elements(elements, d, x, y)
	if #elements == 0 then return end

	local d  = d or "inline"
	local x  = x or 0
	local y  = y or 0
	local nl = 0 -- new line

	-- Parent box
	local parent = {
		x = x,
		y = y,
	}

	if elements[1].parent then
		parent.w = elements[1].parent.properties.width
		parent.h = elements[1].parent.properties.height
	else
		parent.w = love.graphics.getWidth()  - x
		parent.h = love.graphics.getHeight() - y
	end

	for _, element in ipairs(elements) do
		local ep  = element.properties

		if Display[ep.display] then
			d, x, y, nl = Display[ep.display](element, d, x, y, nl, parent)
		end
	end
end

--==[[ DISPLAY BLOCK ]]==--

function Display.block(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Element position
	element.position.x = parent.x + ep.margin[4]
	element.position.y = y        + ep.margin[1] + nl

	-- Determine width of element
	if not ep.width then
		Display.block_set_width(element, parent)
	end

	-- Determine height of element
	if not ep.height then
		Display.block_set_height(element, parent)
	end

	-- If not a flexbox, propogate to children
	if ep.display == "block" then
		local cx, cy, cw, ch = Display.get_content_box(element)
		Display.position_elements(element.children, "child", cx, cy, cw, ch)
	end

	-- Return position for next element
	d = "block"
	x = parent.x
	y = element.position.y + ep.height + ep.margin[3]
	nl = 0

	return d, x, y, nl
end

function Display.block_set_width(element, parent)
	local ep = element.properties
	ep.width = parent.w - (ep.margin[4] + ep.margin[2])

	if element.parent then
		local pp = element.parent.properties
		ep.width = ep.width - pp.padding[4] - pp.border[4]
	end
end

function Display.block_set_height(element, parent)
	local ep  = element.properties
	local epp = ep.padding[1] + ep.padding[3] + ep.border[1] + ep.border[3]

	-- Calculate total height of children
	for _, child in ipairs(element.children) do
		local cp = child.properties

		-- Determine width of child
		if not cp.width then
			if cp.display == "block" or cp.display == "flex" then
				local p = { w = ep.width - ep.margin[2] }
				Display.block_set_width(child, p)
			elseif cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_width(child)
			end
		end

		-- Determine height of child
		if not cp.height then
			if cp.display == "block" or cp.display == "flex" then
				local p = { w = ep.width - ep.margin[2] }
				Display.block_set_height(child, p)
			elseif cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_height(child)
			end
		end
	end

	-- Determine height of element
	local width, height = Display.get_wrap(element)
	local ch = 0
	for _, h in ipairs(height) do
		ch = ch + h
	end
	ep.height = ch + epp

	-- If element has a value and no children
	if ep.height == epp and element.value then
		local font         = love.graphics.getFont()
		local width, lines = font:getWrap(element.value, ep.width - ep.border[4] - ep.border[2] - ep.padding[4] - ep.padding[2])
		local height       = font:getHeight()

		ep.height = ep.height + (height * lines)
	end
end

--==[[ DISPLAY INLINE ]]==--

function Display.inline(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Determine width of element
	if not ep.width then
		Display.inline_set_width(element)
	end

	-- Determine height of element
	if not ep.height then
		Display.inline_set_height(element)
	end

	-- Determine element position
	if d == "block" then
		element.position.x = parent.x + ep.margin[4]
		element.position.y = y        + ep.margin[1]
	elseif d == "child" then
		element.position.x = parent.x + ep.margin[4]
		element.position.y = parent.y + ep.margin[1]
	elseif x + ep.width + ep.margin[4] + ep.margin[2] > parent.x + parent.w then
		element.position.x = parent.x + ep.margin[4]
		element.position.y = y        + ep.margin[1] + nl

		nl = 0
	else
		element.position.x = x + ep.margin[4]
		element.position.y = y
	end

	-- If not a flexbox, propogate to children
	if ep.display == "inline" then
		local cx, cy, cw, ch = Display.get_content_box(element)
		Display.position_elements(element.children, "child", cx, cy, cw, ch)
	end

	-- Return position for next element
	d  = "inline"
	x  = element.position.x + ep.margin[2] + ep.width
	y  = element.position.y

	if nl < ep.height + ep.margin[3] then
		nl = ep.height + ep.margin[3]
	end

	return d, x, y, nl
end

function Display.inline_set_width(element)
	local ep  = element.properties
	local epp = ep.padding[4] + ep.padding[2] + ep.border[4] + ep.border[2]
	ep.width  = epp

	-- Set width to largest child
	for _, child in ipairs(element.children) do
		local cp = child.properties

		-- Determine width of child
		if not cp.width then
			if cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_width(child)
			end
		end

		local w = cp.width + cp.margin[4] + cp.margin[2] + epp

		if w > ep.width then
			ep.width = w
		end
	end

	-- Set width to value size if larger than largest child
	if element.value then
		local font = love.graphics.getFont()
		local w    = font:getWidth(element.value) + epp

		if w > ep.width then
			ep.width = w
		end
	end

	-- If parent has a set width, don't overshoot it
	if element.parent then
		local pp = element.parent.properties
		if ep.width > pp.width then
			ep.width = pp.width - ep.margin[4] - ep.margin[2] - pp.border[4] - pp.border[2] - pp.padding[4] - pp.padding[2]
		end
	end
end

function Display.inline_set_height(element)
	local ep  = element.properties
	local epp = ep.padding[1] + ep.padding[3] + ep.border[1] + ep.border[3]

	for _, child in ipairs(element.children) do
		local cp = child.properties

		-- Determine width of child
		if not cp.width then
			if cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_width(child)
			end
		end

		-- Determine height of child
		if not cp.height then
			if cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_height(child)
			end
		end
	end

	-- Determine height of element
	local width, height = Display.get_wrap(element)
	local ch = 0
	for _, h in ipairs(height) do
		ch = ch + h
	end
	ep.height = ch + epp

	-- If element has a value and no children
	if ep.height == epp and element.value then
		local font         = love.graphics.getFont()
		local width, lines = font:getWrap(element.value, ep.width - ep.border[4] - ep.border[2] - ep.padding[4] - ep.padding[2])
		local height       = font:getHeight()

		ep.height = ep.height + (height * lines)
	end
end

--==[[ DISPLAY FLEX ]]==--

function Display.flex(element, d, x, y, nl, parent)
	d, x, y, nl = Display.block(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Return position for next element
	return d, x, y
end

function Display.inline_flex(element, d, x, y, nl, parent)
	d, x, y, nl = Display.inline(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Return position for next element
	return d, x, y, nl
end

--==[[ HELPER FUNCTIONS ]]==--

-- https://love2d.org/wiki/Font%3agetWrap
function Display.get_wrap(element)
	local ep     = element.properties
	local width  = {}
	local height = {}
	local lines  = 0
	local x      = 0

	for _, child in ipairs(element.children) do
		local cp = child.properties
		local w  = cp.width  + cp.margin[4] + cp.margin[2]
		local h  = cp.height + cp.margin[1] + cp.margin[3]

		if cp.display == "block" or x + w > ep.width then
			lines = lines + 1
			table.insert(width, 0)
			table.insert(height, 0)
			x = cp.width + cp.margin[4] + cp.margin[2]
		else
			if lines == 0 then
				lines = lines + 1
				table.insert(width, 0)
				table.insert(height, 0)
			end

			x = x + w
		end

		if x > width[lines] then
			width[lines] = x
		end

		if h > height[lines] then
			height[lines] = h
		end
	end

	return width, height
end

function Display.get_content_box(element)
	local ep = element.properties
	local x  = element.position.x + ep.padding[4] + ep.border[4]
	local y  = element.position.y + ep.padding[1] + ep.border[1]
	local w  = ep.width  - ep.padding[4] - ep.border[4] - ep.padding[2] - ep.border[2]
	local h  = ep.height - ep.padding[1] - ep.border[1] - ep.padding[3] - ep.border[3]

	return x, y, w, h
end

return Display
