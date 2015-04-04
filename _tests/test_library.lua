local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local function output(exp, got) return string.format("'%s' expected, got '%s'", exp, got) end
local dom = require "DOMy"
local gui = dom.new()
gui:import_markup("DOMy/_tests/markup.lua")

print()

print("BEGIN LIBRARY TEST")

-- ID Selector
local e = gui:get_element_by_id("five")
assert(softcompare(e.value, 5),       output(5,  e.value))
assert(e:first_child().value == ">1", output(">1", e:first_child().value))
assert(e:last_child().value  == ">2", output(">2", e:last_child().value))
print("Passed: ID Selector")

-- Type Selector
local filter = gui:get_elements_by_type("inline")
assert(#filter == #gui.elements, output(#gui.elements, #filter))
print("Passed: Type Selector")

-- Class Selector
local root = gui:get_elements_by_class("root")
local sub  = gui:get_elements_by_class("sub", root)
assert(#root == 3, output(3, #root))
assert(#sub  == 1, output(1, #sub))
print("Passed: Class Selector")

-- Query Selector
local filter = gui:get_elements_by_query(".root .sub")
assert(#filter                          == 3,      output(3,      #filter))
assert(filter[1].class[1]               == "sub",  output("sub",  filter[1].class[1]))
assert(filter[1].parent.class[1]        == nil,    output("nil",  filter[1].parent.class[1]))
assert(filter[1].parent.parent.class[1] == "root", output("root", filter[1].parent.parent.class[1]))
print("Passed: Query Selector")

-- Insert Element
local o = gui:new_element("inline", e, 2)
o.value = "Wassup?!"
assert(e:first_child().value == ">1", output(">1", e:first_child().value))
assert(e:last_child().value  == ">2", output(">2", e:last_child().value))
print("Passed: New Element")

-- Insert Element
local o = gui:new_element("inline", e, -20)
o.value = "negz"
assert(e:first_child().value == "negz", output("negz", e:first_child().value))
assert(e:last_child().value  == ">2",   output(">2",   e:last_child().value))
print("Passed: New Element (below 1)")

-- Insert Element
local o = gui:new_element("inline", e, 20)
o.value = "poz"
assert(e:first_child().value == "negz", output("negz", e:first_child().value))
assert(e:last_child().value  == "poz",  output("poz",  e:last_child().value))
print("Passed: New Element (above #)")

-- Check Siblings
assert(e.children[2]:previous_sibling().value == "negz",     output("negz",     e.children[2]:previous_sibling().value))
assert(e.children[2].value                    == ">1",       output(">1",       e.children[2].value))
assert(e.children[2]:next_sibling().value     == "Wassup?!", output("Wassup?!", e.children[2]:next_sibling().value))
print("Passed: Check Siblings")

-- Create Root Element
local o = gui:new_element({ "inline", "hide me!", value=11 })
assert(softcompare(o.value, 11), output("11",    o.value))
assert(o.parent == false,        output("false", o.parent))
print("Passed: New Root Element")

print("END LIBRARY TEST")
