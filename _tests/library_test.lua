local dom = require "DOMinatrix"
local gui = dom.new()
gui:import_markup("DOMinatrix/_tests/markup.lua")

-- Grab an element
------------------
--[[
5
>1
>2
--]]
local e = gui:get_element_by_id("five")
print(e.value)
print(e.first_child.value)
print(e.last_child.value)
print()

-- Insert a new element
-----------------------
--[[
>1
>2
--]]
local o = gui:new_element("element", e, 2)
o.value = "Wassup?!"
print(e.first_child.value)
print(e.last_child.value)
print()

-- Insert a new element
-----------------------
--[[
negz
>2
--]]
local o = gui:new_element("element", e, -20)
o.value = "negz"
print(e.first_child.value)
print(e.last_child.value)
print()

-- Insert a new element
-----------------------
--[[
negz
poz
--]]
local o = gui:new_element("element", e, 20)
o.value = "poz"
print(e.first_child.value)
print(e.last_child.value)
print()

-- Check element's siblings
---------------------------
--[[
negz
>1
Wassup?!
--]]
print(e.children[2].previous_sibling.value)
print(e.children[2].value)
print(e.children[2].next_sibling.value)
print()

-- Create a new root element
----------------------------
--[[
11
false
--]]
local o = gui:new_element("element")
o.value = "11"
print(o.value)
print(o.parent)
print()
