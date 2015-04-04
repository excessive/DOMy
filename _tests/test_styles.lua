local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local function output(exp, got) return string.format("'%s' expected, got '%s'", exp, got) end
local dom = require "DOMy"
local gui = dom.new()
gui:import_markup("DOMy/_tests/styles_markup.lua")

print()

print("BEGIN STYLES TEST")

-- Parse styles
gui:import_styles("DOMy/_tests/styles.lua")

assert(gui.elements[2].properties.width  == 50, output(50, gui.elements[2].properties.width))
assert(gui.elements[2].properties.height == 50, output(50, gui.elements[2].properties.height))
print("Passed: Element Styles")

assert(gui.elements[18].properties.width  == 600, output(600, gui.elements[18].properties.width))
assert(gui.elements[18].properties.height == 600, output(600, gui.elements[18].properties.height))
print("Passed: ID Styles")

assert(gui.elements[2].properties.text_color[1] == 255, output(255, gui.elements[2].properties.text_color[1]))
print("Passed: Class Styles")

assert(gui.elements[15].properties.display == "inline", output("inline", gui.elements[15].properties.display))
print("Passed: Nested Styles")

assert(gui.elements[1].properties.width  == 200, output(200, gui.elements[1].properties.width))
assert(gui.elements[1].properties.height == 200, output(200, gui.elements[1].properties.height))
print("Passed: Conflicting Value Assignments")

--[[
print("Passed: Import Stylesheet")
print("Passed: Extend Style")
print("Passed: Mixin Style")
print("Passed: Prepend Styles")
print("Passed: Append Styles")

print("Passed: :active Pseudo-Class")
print("Passed: :checked Pseudo-Class")
print("Passed: :disabled Pseudo-Class")
print("Passed: :empty Pseudo-Class")
print("Passed: :enabled Pseudo-Class")
print("Passed: :first-child Pseudo-Class")
print("Passed: :first-of-type Pseudo-Class")
print("Passed: :focus Pseudo-Class")
print("Passed: :hover Pseudo-Class")
print("Passed: :in-range Pseudo-Class")
print("Passed: :invalid Pseudo-Class")
print("Passed: :lang(language) Pseudo-Class")
print("Passed: :last-child Pseudo-Class")
print("Passed: :last-of-type Pseudo-Class")
print("Passed: :link Pseudo-Class")
print("Passed: :not(selector) Pseudo-Class")
print("Passed: :nth-child(n) Pseudo-Class")
print("Passed: :nth-last-child(n) Pseudo-Class")
print("Passed: :nth-last-of-type(n) Pseudo-Class")
print("Passed: :nth-of-type(n) Pseudo-Class")
print("Passed: :only-of-type Pseudo-Class")
print("Passed: :only-child Pseudo-Class")
print("Passed: :optional Pseudo-Class")
print("Passed: :out-of-range Pseudo-Class")
print("Passed: :read-only Pseudo-Class")
print("Passed: :read-write Pseudo-Class")
print("Passed: :required Pseudo-Class")
print("Passed: :root Pseudo-Class")
print("Passed: :target Pseudo-Class")
print("Passed: :valid Pseudo-Class")
print("Passed: :visited Pseudo-Class")
--]]

print("END STYLES TEST")
