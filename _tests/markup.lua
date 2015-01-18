local gui = {
	{ "element", "one", value="1" },
	{ "element", "2", id="two" },
	{ "element", "3" },
	{ "element", "4" },
	{ "element", "5" },
}

for i=6, 10 do
	table.insert(gui, { "element", i })
end

for i=1, 2 do
	table.insert(gui[5], { "element", ">"..i })
end

for i=1, 3 do
	table.insert(gui[5][3], { "element", ">>"..i })
end

gui[5].id    = "five"
gui[5][3].id = "five>1"
gui[7].value = "seven"

return gui
