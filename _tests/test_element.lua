local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local function output(exp, got) return string.format("'%s' expected, got '%s'", exp, got) end
local dom = require "DOMy"
local gui = dom.new()
gui:import_markup("DOMy/_tests/markup.lua")

print()

print("BEGIN ELEMENT TEST")

local e = gui:get_element_by_id("five")

-- Element Has Children
assert(e:has_children() == true, output("true", e:has_children()))
print("Passed: Has Children")

-- Prepend Child to Element
local o = gui:new_element("inline")
o.value = "Prepended"
o.id    = "prepend"
e:prepend_child(o)
assert(e.children[1].value == "Prepended", output("Prepended", e.children[1].value))
print("Passed: Prepend Child")

-- Append Child to Element
local o = gui:new_element({ "inline", value="Appended", id="append" })
e:append_child(o)
assert(e.children[#e.children].value == "Appended", output("Appended", e.children[#e.children].value))
print("Passed: Append Child")

-- Add Child to Element
local o = gui:new_element("inline")
o.value = "Added"
e:add_child(o, 2)
assert(e.children[2].value == "Added", output("Added", e.children[2].value))
print("Passed: Add Child")

-- Remove Child from Element
local o = gui:get_element_by_id("prepend")
e:remove_child(o)
e:remove_child(#e.children)
assert(e.children[1].value           == "Added", output("Added", e.children[1].value))
assert(e.children[#e.children].value == ">2",    output(">2",    e.children[#e.children].value))
print("Passed: Remove Child")

-- Replace One Element with Another
local o = gui:new_element({ "inline", "Replaced", id="replace" })
e:replace_child(1, o)
assert(e.children[1].value           == "Replaced", output("Replaced", e.children[1].value))
assert(e.children[#e.children].value == ">2",       output(">2",       e.children[#e.children].value))
print("Passed: Replace Child")

-- Insert Element Before Another
local o = gui:new_element({ "inline", "Before", id="before" })
o:insert_before(e.children[2])
assert(e.children[2].value == "Before", output("Before", e.children[2].value))
assert(e.children[3].value == ">1",     output(">1",     e.children[3].value))
print("Passed: Insert Before")

-- Insert Element After Another
local o = gui:new_element({ "inline", "After", id="after" })
o:insert_after(e.children[3])
assert(e.children[3].value == ">1",    output(">1",    e.children[3].value))
assert(e.children[4].value == "After", output("After", e.children[4].value))
print("Passed: Insert After")

-- Attach an Element Hierarchy to Another
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:attach(o)
assert(softcompare(t.value, 2),                                   output("2",   t.value))
assert(t.parent.value                                   == ">1",  output(">1",  t.parent.value))
assert(o.children[1].value                              == ">>1", output(">>1", o.children[1].value))
assert(o.children[2]:previous_sibling().value           == ">>1", output(">>1", o.children[2]:previous_sibling().value))
assert(o.children[2].value                              == ">>2", output(">>2", o.children[2].value))
assert(o.children[2]:next_sibling().value               == ">>3", output(">>3", o.children[2]:next_sibling().value))
assert(o.children[3].value                              == ">>3", output(">>3", o.children[3].value))
assert(o.children[#o.children]:previous_sibling().value == ">>3", output(">>3", o.children[#o.children]:previous_sibling().value))
assert(softcompare(o.children[#o.children].value, 2),             output("",    o.children[#o.children].value))
print("Passed: Attach Child")

-- Detatch and Element Hierarchy from Another
local o = gui:get_element_by_id("five>1")
local t = gui:get_element_by_id("two")
t:detach(o)
assert(softcompare(t.value, 2),                                   output("2",     t.value))
assert(t.parent                                         == false, output("false", t.parent))
assert(o.children[1].value                              == ">>1", output(">>1",   o.children[1].value))
assert(o.children[2]:previous_sibling().value           == ">>1", output(">>1",   o.children[2]:previous_sibling().value))
assert(o.children[2].value                              == ">>2", output(">>2",   o.children[2].value))
assert(o.children[2]:next_sibling().value               == ">>3", output(">>3",   o.children[2]:next_sibling().value))
assert(o.children[3].value                              == ">>3", output(">>3",   o.children[3].value))
assert(o.children[#o.children]:previous_sibling().value == ">>2", output(">>2",   o.children[#o.children]:previous_sibling().value))
assert(o.children[#o.children].value                    == ">>3", output(">>3",   o.children[#o.children].value))
print("Passed: Detach Child")

-- Destroy an Element
local o = gui:get_element_by_id("five>1")
o:destroy()
assert(o.parent    == false, output("false", o.parent))
assert(#o.children == 0,     output("0",     #o.children))
print("Passed: Destroy Element")

-- Clone Element
e:set_property("width", 500)
local o = e:clone(true)
e:set_property("width", 100)
assert(o.value             == e.value,             output(e.value,             o.value))
assert(#o.children         == #e.children,         output(#e.children,         #o.children))
assert(o.children[1]       ~= e.children[1],       output(e.children[1],       o.children[1]))
assert(o.children[1].value == e.children[1].value, output(e.children[1].value, o.children[1].value))
assert(o.properties.width  == 500,                 output("500",               o.properties.width))
print("Passed: Clone Element")

-- Check Properties
assert(e:has_property("width")   == true,  output("true",  e:has_property("width")))
assert(e:has_property("height")  == true,  output("true",  e:has_property("height")))
assert(e:has_property("kek")     == false, output("false", e:has_property("kek")))
assert(e:has_property("visible") == true,  output("true",  e:has_property("visible")))
print("Passed: Check Properties")

-- Get Propery Values
assert(e:get_property("width")   == 100,  output("0",    e:get_property("width")))
assert(e:get_property("height")  == 100,  output("0",    e:get_property("height")))
assert(e:get_property("kek")     == nil,  output("nil",  e:get_property("kek")))
assert(e:get_property("visible") == true, output("true", e:get_property("visible")))
print("Passed: Get Property Values")

-- Set Property Values
e:set_property("width",   150)
e:set_property("height",  100)
e:set_property("kek",     "top")
e:set_property("visible", false)
assert(e:get_property("width")   == 150,   output("150",   e:get_property("width")))
assert(e:get_property("height")  == 100,   output("100",   e:get_property("height")))
assert(e:get_property("kek")     == "top", output("top",   e:get_property("kek")))
assert(e:get_property("visible") == false, output("false", e:get_property("visible")))
print("Passed: Set Property Values")

-- Remove Propery Values
e:remove_property("kek")
assert(e:get_property("kek") == nil, output("nil", e:get_property("kek")))
print("Passed: Remove Property Values")

print("END ELEMENT TEST")
