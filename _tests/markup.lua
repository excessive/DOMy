local gui = {
	{ "inline", "one", value="1" },
	{ "inline", "2", id="two" },
	{ "inline", "3", class={ "root", "sub" } },
	{ "inline", "4", class="root" },
	{ "inline", "5", class={ "root" } },
}

for i=6, 10 do
	table.insert(gui, { "inline", i, class={ "sub" } })
end

for i=1, 2 do
	table.insert(gui[5], { "inline", ">"..i })
end

for i=1, 3 do
	table.insert(gui[5][3], { "inline", ">>"..i, class={ "sub" } })
end

gui[5].id    = "five"
gui[5][3].id = "five>1"
gui[7].value = "seven"

return gui
