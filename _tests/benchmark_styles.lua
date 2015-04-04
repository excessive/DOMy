local dom = require "DOMy"

print("BEGIN STYLES BENCHMARK")

local styles  = {}
local gui = dom.new()
for i=1, 50 do
	table.insert(styles, { ".class"..i, {
		width  = 50,
		height = 50,
	}})
end
local t = love.timer.getTime()
gui:import_styles(styles)
print(string.format("50 Selectors: %f", love.timer.getTime() - t))

local styles  = {}
local gui = dom.new()
for i=1, 500 do
	table.insert(styles, { ".class"..i, {
		width  = 500,
		height = 500,
	}})
end
local t = love.timer.getTime()
gui:import_styles(styles)
print(string.format("500 Selectors: %f", love.timer.getTime() - t))

local styles  = {}
local gui = dom.new()
for i=1, 5000 do
	table.insert(styles, { ".class"..i, {
		width  = 5000,
		height = 5000,
	}})
end
local t = love.timer.getTime()
gui:import_styles(styles)
print(string.format("5000 Selectors: %f", love.timer.getTime() - t))

print("END STYLES BENCHMARK")
print()
