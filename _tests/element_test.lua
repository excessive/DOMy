local dom = require "DOMinatrix"
local gui = dom.new()
gui:import_markup("DOMinatrix/_tests/markup.lua")

local e = gui:get_element_by_id("five")

-- Element Has Children
-----------------------
--[[
true
--]]
print(e:has_children())
print()

-- Prepend Child to Element
---------------------------
--[[
Prepended
--]]
local o = gui:new_element("element")
o.value = "Prepended"
o.id    = "prepend"
e:prepend_child(o)
print(e.children[1].value)
print()

-- Append Child to Element
--------------------------
--[[
Appended
--]]
local o = gui:new_element({ "element", value="Appended", id="append" })
e:append_child(o)
print(e.children[#e.children].value)
print()

-- Add Child to Element
-----------------------
--[[
Added
--]]
local o = gui:new_element("element")
o.value = "Added"
e:add_child(o, 2)
print(e.children[2].value)
print()

-- Remove Child from Element
--------
--[[
Added
>2
--]]
local o = gui:get_element_by_id("prepend")
e:remove_child(o)
e:remove_child(#e.children)
print(e.children[1].value)
print(e.children[#e.children].value)
print()

-- Replace One Element with Another
-----------------------------------
--[[
Replaced
>2
--]]
local o = gui:new_element({ "element", "Replaced", id="replace" })
e:replace_child(1, o)
print(e.children[1].value)
print(e.children[#e.children].value)
print()

-- Insert Element Before Another
--------------------------------
--[[
Before
>1
--]]
local o = gui:new_element({ "element", "Before", id="before" })
o:insert_before(e.children[2])
print(e.children[2].value)
print(e.children[3].value)
print()

-- Insert Element After Another
-------------------------------
--[[
>1
After
--]]
local o = gui:new_element({ "element", "After", id="after" })
o:insert_after(e.children[3])
print(e.children[3].value)
print(e.children[4].value)
print()

-- Attach an Element Hierarchy to Another
-----------------------------------------
--[[
2
>1
>>1
>>1
>>2
>>3
>>3
>>3
2
--]]
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:attach(o)
print(t.value)
print(t.parent.value)
print(o.children[1].value)
print(o.children[2].previous_sibling.value)
print(o.children[2].value)
print(o.children[2].next_sibling.value)
print(o.children[3].value)
print(o.children[#o.children].previous_sibling.value)
print(o.children[#o.children].value)
print()

-- Detatch and Element Hierarchy from Another
---------------------------------------------
--[[
2
false
>>1
>>1
>>2
>>3
>>3
>>2
>>3
--]]
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:detach(o)
print(t.value)
print(t.parent)
print(o.children[1].value)
print(o.children[2].previous_sibling.value)
print(o.children[2].value)
print(o.children[2].next_sibling.value)
print(o.children[3].value)
print(o.children[#o.children].previous_sibling.value)
print(o.children[#o.children].value)
print()

-- Destroy an Element
---------------------
--[[
false
0
--]]
local o = gui:get_element_by_id("five>1")
o:destroy()
print(o.parent)
print(#o.children)
print()

--[=[

--
--------
--[[

--]]
e:clone_element()

--]=]

-- Check Properties
-------------------
--[[
true
true
false
true
--]]
print(e:has_property("width"))
print(e:has_property("height"))
print(e:has_property("kek"))
print(e:has_property("visible"))
print()

-- Get Propery Values
---------------------
--[[
0
0
nil
true
--]]
print(e:get_property("width"))
print(e:get_property("height"))
print(e:get_property("kek"))
print(e:get_property("visible"))
print()

-- Set Property Values
----------------------
--[[
150
100
top
false
--]]
e:set_property("width",   150)
e:set_property("height",  100)
e:set_property("kek",     "top")
e:set_property("visible", false)
print(e:get_property("width"))
print(e:get_property("height"))
print(e:get_property("kek"))
print(e:get_property("visible"))
print()

-- Remove Propery Values
------------------------
--[[
nil
--]]
e:remove_property("kek")
print(e:get_property("kek"))
print()

