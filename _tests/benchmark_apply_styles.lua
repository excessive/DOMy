local dom = require "DOMy"

print("BEGIN APPLY STYLES BENCHMARK")

local iterate = 100
local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 10 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 50 do
	table.insert(styles, { ".class"..i, {
		width  = 50,
		height = 50,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("50 Elements, 50 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 100 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 50 do
	table.insert(styles, { ".class"..i, {
		width  = 50,
		height = 50,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("500 Elements, 50 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 1000 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 50 do
	table.insert(styles, { ".class"..i, {
		width  = 50,
		height = 50,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("5000 Elements, 50 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 10 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 500 do
	table.insert(styles, { ".class"..i, {
		width  = 500,
		height = 500,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("50 Elements, 500 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 100 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 500 do
	table.insert(styles, { ".class"..i, {
		width  = 500,
		height = 500,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("500 Elements, 500 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 1000 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 500 do
	table.insert(styles, { ".class"..i, {
		width  = 500,
		height = 500,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("5000 Elements, 500 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 10 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 5000 do
	table.insert(styles, { ".class"..i, {
		width  = 5000,
		height = 5000,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("50 Elements, 5000 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 100 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 5000 do
	table.insert(styles, { ".class"..i, {
		width  = 5000,
		height = 5000,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("500 Elements, 5000 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

local markup  = {}
local styles  = {}
local gui = dom.new()
for i=1, 1000 do
	table.insert(markup, { "element", value=i, id="id"..i, class="class"..i,
		{ "element", value=i..">1" },
		{ "element", value=i..">2" },
		{ "element", value=i..">3" },
		{ "element", value=i..">4" },
	})
end
for i=1, 5000 do
	table.insert(styles, { ".class"..i, {
		width  = 5000,
		height = 5000,
	}})
end
gui:import_markup(markup)
gui:import_styles(styles)
local t = love.timer.getTime()
for i=1, iterate do
	gui:apply_styles()
end
print(string.format("5000 Elements, 5000 Selectors, "..iterate.." Passes: %fs/f", (love.timer.getTime() - t) / iterate))

print("END APPLY STYLES BENCHMARK")
print()
