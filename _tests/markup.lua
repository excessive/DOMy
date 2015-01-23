local gui = {
	{ "element", "one", value="1" },
	{ "element", "2", id="two" },
	{ "element", "3", class={ "root", "sub" } },
	{ "element", "4", class="root" },
	{ "element", "5", class={ "root" } },
}

for i=6, 10 do
	table.insert(gui, { "element", i, class={ "sub" } })
end

for i=1, 2 do
	table.insert(gui[5], { "element", ">"..i })
end

for i=1, 3 do
	table.insert(gui[5][3], { "element", ">>"..i, class={ "sub" } })
end

gui[5].id    = "five"
gui[5][3].id = "five>1"
gui[7].value = "seven"

return gui
