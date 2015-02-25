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
	element.position.x = parent.x + ep.margin_left
	element.position.y = y        + ep.margin_top + nl

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
	y = element.position.y + ep.height + ep.margin_bottom
	nl = 0

	return d, x, y, nl
end

function Display.block_set_width(element, parent)
	local ep = element.properties
	ep.width = parent.w - (ep.margin_left + ep.margin_right)

	if element.parent then
		local pp = element.parent.properties
		ep.width = ep.width - pp.padding_left - pp.border_left
	end
end

function Display.block_set_height(element, parent)
	local ep  = element.properties
	local epp = ep.padding_top + ep.padding_bottom + ep.border_top + ep.border_bottom

	-- Calculate total height of children
	for _, child in ipairs(element.children) do
		local cp = child.properties

		-- Determine width of child
		if not cp.width then
			if cp.display == "block" or cp.display == "flex" then
				local p = { w = ep.width - ep.margin_right }
				Display.block_set_width(child, p)
			elseif cp.display == "inline" or cp.display == "inline_flex" then
				Display.inline_set_width(child)
			end
		end

		-- Determine height of child
		if not cp.height then
			if cp.display == "block" or cp.display == "flex" then
				local p = { w = ep.width - ep.margin_right }
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
		local width, lines = font:getWrap(element.value, ep.width - ep.border_left - ep.border_right - ep.padding_left - ep.padding_right)
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
		element.position.x = parent.x + ep.margin_left
		element.position.y = y        + ep.margin_top
	elseif d == "child" then
		element.position.x = parent.x + ep.margin_left
		element.position.y = parent.y + ep.margin_top
	elseif x + ep.width + ep.margin_left + ep.margin_right > parent.x + parent.w then
		element.position.x = parent.x + ep.margin_left
		element.position.y = y        + ep.margin_top + nl

		nl = 0
	else
		element.position.x = x + ep.margin_left
		element.position.y = y
	end

	-- If not a flexbox, propogate to children
	if ep.display == "inline" then
		local cx, cy, cw, ch = Display.get_content_box(element)
		Display.position_elements(element.children, "child", cx, cy, cw, ch)
	end

	-- Return position for next element
	d  = "inline"
	x  = element.position.x + ep.margin_right + ep.width
	y  = element.position.y

	if nl < ep.height + ep.margin_bottom then
		nl = ep.height + ep.margin_bottom
	end

	return d, x, y, nl
end

function Display.inline_set_width(element)
	local ep  = element.properties
	local epp = ep.padding_left + ep.padding_right + ep.border_left + ep.border_right
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

		local w = cp.width + cp.margin_left + cp.margin_right + epp

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
			ep.width = pp.width - ep.margin_left - ep.margin_right - pp.border_left - pp.border_right - pp.padding_left - pp.padding_right
		end
	end
end

function Display.inline_set_height(element)
	local ep  = element.properties
	local epp = ep.padding_top + ep.padding_bottom + ep.border_top + ep.border_bottom

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
		local width, lines = font:getWrap(element.value, ep.width - ep.border_left - ep.border_right - ep.padding_left - ep.padding_right)
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
		local w  = cp.width  + cp.margin_left + cp.margin_right
		local h  = cp.height + cp.margin_top + cp.margin_right

		if cp.display == "block" or x + w > ep.width then
			lines = lines + 1
			table.insert(width, 0)
			table.insert(height, 0)
			x = cp.width + cp.margin_left + cp.margin_right
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
	local x  = element.position.x + ep.padding_left + ep.border_left
	local y  = element.position.y + ep.padding_top + ep.border_top
	local w  = ep.width  - ep.padding_left - ep.border_left - ep.padding_right - ep.border_right
	local h  = ep.height - ep.padding_top - ep.border_top - ep.padding_right - ep.border_right

	return x, y, w, h
end

return Display
