local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local dom = require "DOMinatrix"
local gui = dom.new()
gui:import_markup("DOMinatrix/_tests/markup.lua")

print("BEGIN LIBRARY TEST")

-- ID Selector
local e = gui:get_element_by_id("five")
assert(softcompare(e.value, 5),     string.format("5 expected, got %s",  e.value))
assert(e.first_child.value == ">1", string.format(">1 expected, got %s", e.first_child.value))
assert(e.last_child.value  == ">2", string.format(">2 expected, got %s", e.last_child.value))
print("Passed: ID Selector")

-- Insert Element
local o = gui:new_element("element", e, 2)
o.value = "Wassup?!"
assert(e.first_child.value == ">1", string.format(">1 expected, got %s", e.first_child.value))
assert(e.last_child.value  == ">2", string.format(">2 expected, got %s", e.last_child.value))
print("Passed: New Element")

-- Insert Element
local o = gui:new_element("element", e, -20)
o.value = "negz"
assert(e.first_child.value == "negz", string.format("negz expected, got %s", e.first_child.value))
assert(e.last_child.value  == ">2",   string.format(">2 expected, got %s",   e.last_child.value))
print("Passed: New Element (below 1)")

-- Insert Element
local o = gui:new_element("element", e, 20)
o.value = "poz"
assert(e.first_child.value == "negz", string.format("negz expected, got %s", e.first_child.value))
assert(e.last_child.value  == "poz",  string.format("poz expected, got %s",  e.last_child.value))
print("Passed: New Element (above #)")

-- Check Siblings
assert(e.children[2].previous_sibling.value == "negz", string.format("negz expected, got %s",     e.children[2].previous_sibling.value))
assert(e.children[2].value == ">1",                    string.format(">1 expected, got %s",       e.children[2].value))
assert(e.children[2].next_sibling.value == "Wassup?!", string.format("Wassup?! expected, got %s", e.children[2].next_sibling.value))
print("Passed: Check Siblings")

-- Create Root Element
local o = gui:new_element({ "element", "hide me!", value=11 })
assert(softcompare(o.value, 11), string.format("11 expected, got %s",    o.value))
assert(o.parent == false,        string.format("false expected, got %s", o.parent))
print("Passed: New Root Element")

print("END LIBRARY TEST")
print()
