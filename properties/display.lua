local path    = (...):gsub('%.[^%.]+$', '') .. "."
local Flex    = require(path.."flex")
local Display = {}

function Display.position_elements(elements, d, x, y, w, h)
	if #elements == 0 then return end

	local d  = d or "inline"
	local x  = x or 0
	local y  = y or 0
	local nl = 0 -- new line

	-- Parent box
	local parent = {
		x = x,
		y = y,
		w = w or love.graphics.getWidth()  - x,
		h = h or love.graphics.getHeight() - y,
	}

	for _, element in ipairs(elements) do
		element.visible = Display.get_visible(element)
		if element.visible then
			local ep  = element.properties

			if Display[ep.display] then
				d, x, y, nl = Display[ep.display](element, d, x, y, nl, parent)
			end
		end
	end
end

--==[[ DISPLAY BLOCK ]]==--

function Display.block(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Determine width of element
	if not ep.width then
		Display.block_set_width(element, parent)
	end

	-- Width within bounds
	if ep.min_width and ep.width < ep.min_width then
		ep.width = ep.min_width
	end

	if ep.max_width and ep.width > ep.max_width then
		ep.width = ep.max_width
	end

	-- Determine height of element
	if not ep.height then
		Display.block_set_height(element, parent)
	end

	-- Height within bounds
	if ep.min_height and ep.height < ep.min_height then
		ep.height = ep.min_height
	end

	if ep.max_height and ep.height > ep.max_height then
		ep.height = ep.max_height
	end

	-- Element position
	if ep.position == "absolute" then
		Display.absolute(element)
	else
		element.position.x = parent.x + ep.margin_left
		element.position.y = y        + ep.margin_top + nl
	end

	-- If not a flexbox, propogate to children
	if ep.display == "block" then
		local cx, cy, cw, ch = Display.get_content_box(element)
		Display.position_elements(element.children, "child", cx, cy, cw, ch)
	end

	-- Return position for next element
	if ep.position ~= "absolute" and ep.position ~= "fixed" then
		d = "block"
		x = parent.x
		y = element.position.y + ep.height + ep.margin_bottom
		nl = 0
	end

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
		local width, lines = ep.font:getWrap(element.value, ep.width - ep.border_left - ep.border_right - ep.padding_left - ep.padding_right)
		local height       = ep.font:getHeight()
		ep.height          = ep.height + (height * lines * ep.line_height)
	end
end

--==[[ DISPLAY INLINE ]]==--

function Display.inline(element, d, x, y, nl, parent)
	local ep  = element.properties

	-- Determine width of element
	if not ep.width then
		Display.inline_set_width(element, parent)
	end

	-- Width within bounds
	if ep.min_width and ep.width < ep.min_width then
		ep.width = ep.min_width
	end

	if ep.max_width and ep.width > ep.max_width then
		ep.width = ep.max_width
	end

	-- Determine height of element
	if not ep.height then
		Display.inline_set_height(element, parent)
	end

	-- Height within bounds
	if ep.min_height and ep.height < ep.min_height then
		ep.height = ep.min_height
	end

	if ep.max_height and ep.height > ep.max_height then
		ep.height = ep.max_height
	end

	-- Determine element position
	if ep.position == "absolute" then
		Display.absolute(element)
	else
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
	end

	-- If not a flexbox, propogate to children
	if ep.display == "inline" then
		local cx, cy, cw, ch = Display.get_content_box(element)
		Display.position_elements(element.children, "child", cx, cy, cw, ch)
	end

	if ep.position ~= "absolute" and ep.position ~= "fixed" then
		-- Return position for next element
		d  = "inline"
		x  = element.position.x + ep.margin_right + ep.width
		y  = element.position.y

		if nl < ep.height + ep.margin_bottom then
			nl = ep.height + ep.margin_bottom
		end
	end

	return d, x, y, nl
end

function Display.inline_set_width(element)
	local ep  = element.properties
	local epp = ep.padding_left + ep.padding_right + ep.border_left + ep.border_right
	local new_width = epp

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

		if w > new_width then
			new_width = w
		end
	end

	-- Set width to value size if larger than largest child
	if element.value then
		local w = ep.font:getWidth(element.value) + epp

		if w > new_width then
			new_width = w
		end
	end

	-- If parent has a set width, don't overshoot it
	if element.parent then
		local pp  = element.parent.properties
		local ppp = pp.border_left + pp.border_right + pp.padding_left + pp.padding_right

		if pp.width and new_width > pp.width - ppp and pp.width > pp.margin_left + pp.margin_right then
			new_width = pp.width - ppp - ep.margin_left - ep.margin_right
		end
	end

	ep.width = new_width
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
		local width, lines = ep.font:getWrap(element.value, ep.width - ep.border_left - ep.border_right - ep.padding_left - ep.padding_right)
		local height       = ep.font:getHeight()
		ep.height          = ep.height + (height * lines * ep.line_height)
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

function Display.absolute(element)
	local ep       = element.properties
	local relative = Display.get_relative(element)
	local cx, cy, cw, ch

	if relative then
		cx, cy, cw, ch = Display.get_content_box(relative)
	else
		cx, cy = 0, 0
		cw, ch = love.graphics.getDimensions()
	end

	if ep.left then
		element.position.x = cx + ep.left + ep.margin_left
	elseif ep.right then
		element.position.x = cx + cw - (ep.width + ep.right + ep.margin_right)
	else
		element.position.x = cx
	end

	if ep.top then
		element.position.y = cy + ep.top + ep.margin_top
	elseif ep.bottom then
		element.position.y = cy + ch - (ep.height + ep.bottom + ep.margin_bottom)
	else
		element.position.y = cy
	end
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
		local h  = cp.height + cp.margin_top + cp.margin_bottom

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
	local h  = ep.height - ep.padding_top - ep.border_top - ep.padding_bottom - ep.border_bottom

	return x, y, w, h
end

function Display.get_visible(element)
	if not element then return true end

	if element.properties.visible == true then
		return Display.get_visible(element.parent)
	else
		return false
	end
end

function Display.get_relative(element)
	if not element then return false end

	if element.properties.position == "relative" then
		return element
	else
		Display.get_relative(element.parent)
	end
end

return Display
