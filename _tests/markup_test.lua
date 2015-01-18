local dom = require "DOMinatrix"
local gui = dom.new()
gui:import_markup("DOMinatrix/_tests/markup.lua")

-- Print all elements
---------------------
--[[
false	1
two		2
false	3
false	4
five	5
five>1	>1
false	>>1
false	>>2
false	>>3
false	>2
false	6
false	seven
false	8
false	9
false	10
--]]
for _, element in ipairs(gui.elements) do
	print(element.id, element.value)
end
print()
