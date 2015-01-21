local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local dom = require "DOMinatrix"
local gui = dom.new()
gui:import_markup("DOMinatrix/_tests/markup.lua")

print("BEGIN ELEMENT TEST")

local e = gui:get_element_by_id("five")

-- Element Has Children
assert(e:has_children() == true, string.format("true expected, got %s", e:has_children()))
print("Passed: Has Children")

-- Prepend Child to Element
local o = gui:new_element("element")
o.value = "Prepended"
o.id    = "prepend"
e:prepend_child(o)
assert(e.children[1].value == "Prepended", string.format("Prepended expected, got %s", e.children[1].value))
print("Passed: Prepend Child")

-- Append Child to Element
local o = gui:new_element({ "element", value="Appended", id="append" })
e:append_child(o)
assert(e.children[#e.children].value == "Appended", string.format("Appended expected, got %s", e.children[#e.children].value))
print("Passed: Append Child")

-- Add Child to Element
local o = gui:new_element("element")
o.value = "Added"
e:add_child(o, 2)
assert(e.children[2].value == "Added", string.format("Added expected, got %s", e.children[2].value))
print("Passed: Add Child")

-- Remove Child from Element
local o = gui:get_element_by_id("prepend")
e:remove_child(o)
e:remove_child(#e.children)
assert(e.children[1].value           == "Added", string.format("Added expected, got %s", e.children[1].value))
assert(e.children[#e.children].value == ">2",    string.format(">2 expected, got %s",    e.children[#e.children].value))
print("Passed: Remove Child")

-- Replace One Element with Another
local o = gui:new_element({ "element", "Replaced", id="replace" })
e:replace_child(1, o)
assert(e.children[1].value           == "Replaced", string.format("Replaced expected, got %s", e.children[1].value))
assert(e.children[#e.children].value == ">2",       string.format(">2 expected, got %s",       e.children[#e.children].value))
print("Passed: Replace Child")

-- Insert Element Before Another
local o = gui:new_element({ "element", "Before", id="before" })
o:insert_before(e.children[2])
assert(e.children[2].value == "Before", string.format("Before expected, got %s", e.children[2].value))
assert(e.children[3].value == ">1",     string.format(">1 expected, got %s",     e.children[3].value))
print("Passed: Insert Before")

-- Insert Element After Another
local o = gui:new_element({ "element", "After", id="after" })
o:insert_after(e.children[3])
assert(e.children[3].value == ">1",    string.format(">1 expected, got %s",    e.children[3].value))
assert(e.children[4].value == "After", string.format("After expected, got %s", e.children[4].value))
print("Passed: Insert After")

-- Attach an Element Hierarchy to Another
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:attach(o)
assert(softcompare(t.value, 2),                                   string.format("2 expected, got %s",   t.value))
assert(t.parent.value                                   == ">1",  string.format(">1 expected, got %s",  t.parent.value))
assert(o.children[1].value                              == ">>1", string.format(">>1 expected, got %s", o.children[1].value))
assert(o.children[2]:previous_sibling().value           == ">>1", string.format(">>1 expected, got %s", o.children[2]:previous_sibling().value))
assert(o.children[2].value                              == ">>2", string.format(">>2 expected, got %s", o.children[2].value))
assert(o.children[2]:next_sibling().value               == ">>3", string.format(">>3 expected, got %s", o.children[2]:next_sibling().value))
assert(o.children[3].value                              == ">>3", string.format(">>3 expected, got %s", o.children[3].value))
assert(o.children[#o.children]:previous_sibling().value == ">>3", string.format(">>3 expected, got %s", o.children[#o.children]:previous_sibling().value))
assert(softcompare(o.children[#o.children].value, 2),             string.format(" expected, got %s",    o.children[#o.children].value))
print("Passed: Attach Child")

-- Detatch and Element Hierarchy from Another
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:detach(o)
assert(softcompare(t.value, 2),                                   string.format("2 expected, got %s",     t.value))
assert(t.parent                                         == false, string.format("false expected, got %s", t.parent))
assert(o.children[1].value                              == ">>1", string.format(">>1 expected, got %s",   o.children[1].value))
assert(o.children[2]:previous_sibling().value           == ">>1", string.format(">>1 expected, got %s",   o.children[2]:previous_sibling().value))
assert(o.children[2].value                              == ">>2", string.format(">>2 expected, got %s",   o.children[2].value))
assert(o.children[2]:next_sibling().value               == ">>3", string.format(">>3 expected, got %s",   o.children[2]:next_sibling().value))
assert(o.children[3].value                              == ">>3", string.format(">>3 expected, got %s",   o.children[3].value))
assert(o.children[#o.children]:previous_sibling().value == ">>2", string.format(">>2 expected, got %s",   o.children[#o.children]:previous_sibling().value))
assert(o.children[#o.children].value                    == ">>3", string.format(">>3 expected, got %s",   o.children[#o.children].value))
print("Passed: Detach Child")

-- Destroy an Element
local o = gui:get_element_by_id("five>1")
o:destroy()
assert(o.parent    == false, string.format("false expected, got %s", o.parent))
assert(#o.children == 0, string.format("0 expected, got %s",         #o.children))
print("Passed: Destroy Element")

-- Clone Element
-- local o = e:clone_element()
-- assert(A BUNCH OF THINGS)
print("CLONE ELEMENT NOT YET IMPLEMENTED")


-- Check Properties
assert(e:has_property("width")   == true,  string.format("true expected, got %s",  e:has_property("width")))
assert(e:has_property("height")  == true,  string.format("true expected, got %s",  e:has_property("height")))
assert(e:has_property("kek")     == false, string.format("false expected, got %s", e:has_property("kek")))
assert(e:has_property("visible") == true,  string.format("true expected, got %s",  e:has_property("visible")))
print("Passed: Check Properties")

-- Get Propery Values
assert(e:get_property("width")   == 0,    string.format("0 expected, got %s",    e:get_property("width")))
assert(e:get_property("height")  == 0,    string.format("0 expected, got %s",    e:get_property("height")))
assert(e:get_property("kek")     == nil,  string.format("nil expected, got %s",  e:get_property("kek")))
assert(e:get_property("visible") == true, string.format("true expected, got %s", e:get_property("visible")))
print("Passed: Get Property Values")

-- Set Property Values
e:set_property("width",   150)
e:set_property("height",  100)
e:set_property("kek",     "top")
e:set_property("visible", false)
assert(e:get_property("width")   == 150,   string.format("150 expected, got %s",   e:get_property("width")))
assert(e:get_property("height")  == 100,   string.format("100 expected, got %s",   e:get_property("height")))
assert(e:get_property("kek")     == "top", string.format("top expected, got %s",   e:get_property("kek")))
assert(e:get_property("visible") == false, string.format("false expected, got %s", e:get_property("visible")))
print("Passed: Set Property Values")

-- Remove Propery Values
e:remove_property("kek")
assert(e:get_property("kek") == nil, string.format("nil expected, got %s", e:get_property("kek")))
print("Passed: Remove Property Values")

print("END ELEMENT TEST")
print()

