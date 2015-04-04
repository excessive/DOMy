local function softcompare(a,b) return tonumber(a) == tonumber(b) end
local function output(exp, got) return string.format("'%s' expected, got '%s'", exp, got) end
local dom = require "DOMy"
local gui = dom.new()

print()

print("BEGIN MARKUP TEST")

-- Parse Markup
gui:import_markup("DOMy/_tests/markup.lua")
assert(gui.elements[1].id     == nil,           output("nil",    gui.elements[1].id))
assert(softcompare(gui.elements[1].value, 1),   output("1",      gui.elements[1].value))
assert(gui.elements[2].id     == "two",         output("two",    gui.elements[2].id))
assert(softcompare(gui.elements[2].value, 2),   output("2",      gui.elements[2].value))
assert(gui.elements[3].id     == nil,           output("nil",    gui.elements[3].id))
assert(softcompare(gui.elements[3].value, 3),   output("3",      gui.elements[3].value))
assert(gui.elements[4].id     == nil,           output("nil",    gui.elements[4].id))
assert(softcompare(gui.elements[4].value, 4),   output("4",      gui.elements[4].value))
assert(gui.elements[5].id     == "five",        output("five",   gui.elements[5].id))
assert(softcompare(gui.elements[5].value, 5),   output("5",      gui.elements[5].value))
assert(gui.elements[6].id     == "five>1",      output("five>1", gui.elements[6].id))
assert(gui.elements[6].value  == ">1",          output(">1",     gui.elements[6].value))
assert(gui.elements[7].id     == nil,           output("nil",    gui.elements[7].id))
assert(gui.elements[7].value  == ">>1",         output(">>1",    gui.elements[7].value))
assert(gui.elements[8].id     == nil,           output("nil",    gui.elements[8].id))
assert(gui.elements[8].value  == ">>2",         output(">>2",    gui.elements[8].value))
assert(gui.elements[9].id     == nil,           output("nil",    gui.elements[9].id))
assert(gui.elements[9].value  == ">>3",         output(">>3",    gui.elements[9].value))
assert(gui.elements[10].id    == nil,           output("nil",    gui.elements[10].id))
assert(gui.elements[10].value == ">2",          output(">2",     gui.elements[10].value))
assert(gui.elements[11].id    == nil,           output("nil",    gui.elements[11].id))
assert(softcompare(gui.elements[11].value, 6),  output("6",      gui.elements[11].value))
assert(gui.elements[12].id    == nil,           output("nil",    gui.elements[12].id))
assert(gui.elements[12].value == "seven",       output("seven",  gui.elements[12].value))
assert(gui.elements[13].id    == nil,           output("nil",    gui.elements[13].id))
assert(softcompare(gui.elements[13].value, 8),  output("8",      gui.elements[13].value))
assert(gui.elements[14].id    == nil,           output("nil",    gui.elements[14].id))
assert(softcompare(gui.elements[14].value, 9),  output("9",      gui.elements[14].value))
assert(gui.elements[15].id    == nil,           output("nil",    gui.elements[15].id))
assert(softcompare(gui.elements[15].value, 10), output("10",     gui.elements[15].value))
print("Passed: Parsed Markup")

print("END MARKUP TEST")
