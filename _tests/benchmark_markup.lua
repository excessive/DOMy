local dom = require "DOMy"

print("BEGIN MARKUP BENCHMARK")

local markup  = {}
local gui = dom.new()
for i=1, 10 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
local t = love.timer.getTime()
gui:import_markup(markup)
print(string.format("50 Elements: %f", love.timer.getTime() - t))

local markup  = {}
local gui = dom.new()
for i=1, 100 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
local t = love.timer.getTime()
gui:import_markup(markup)
print(string.format("500 Elements: %f", love.timer.getTime() - t))

local markup  = {}
local gui = dom.new()
for i=1, 1000 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
local t = love.timer.getTime()
gui:import_markup(markup)
print(string.format("5000 Elements: %f", love.timer.getTime() - t))

print("END MARKUP BENCHMARK")
print()
