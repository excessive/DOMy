# border

The size of the border. The value can be an integer (all corners of the same size), a table of two (top and bottom, right and left), or a table of four (top, right, bottom, left).

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border = 5,
}}
```

```lua
{ "inline", {
	border = { 5, 10 },
}}
```

```lua
{ "inline", {
	border = { 50, 3, 3, 3 },
}}
```

# border_bottom

The size of the border.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_bottom = 5,
}}
```

# border_bottom_color

A table of integers representing the RGBA values of the border.

Value   | Description
--------|------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	border_bottom_color = { 255, 0, 0, 255 },
}}
```

# border_bottom_left_radius

The radius of the rounded edge.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_bottom_left_radius = 5,
}}
```

# border_bottom_right_radius

The radius of the rounded edge.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_bottom_right_radius = 5,
}}
```

# border_color

A table or a table of a table of integers representing the RGBA values of the border. If a single table is present, that color will be set for all borders. If two are present, they will be set top and bottom, right and left. If four are present, they will be set top, right, bottom, left.

Value   | Description
--------|------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	border_color = { 255, 0, 0, 255 },
}}
```

```lua
{ ".red_green", {
	border_color = {
		{ 255, 0, 0, 255 },
		{ 0, 255, 0, 255 },
	},
}}
```

```lua
{ ".red_green_blue_black", {
	border_color = {
		{ 255, 0, 0, 255 },
		{ 0, 255, 0, 255 },
		{ 0, 0, 255, 255 },
		{ 0, 0, 0, 255 },
	},
}}
```

# border_left

The size of the border.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_left = 5,
}}
```

# border_left_color

A table of integers representing the RGBA values of the border.

Value   | Description
--------|------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	border_left_color = { 255, 0, 0, 255 },
}}
```

# border_radius

The radii of the rounded edges. The value can be an integer (all corners of the same radius), a table of two (top, bottom), or a table of four (top-left, top-right, bottom-right, bottom-left).

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_radius = 5,
}}
```

```lua
{ "inline", {
	border_radius = { 0, 10 },
}}
```

```lua
{ "inline", {
	border_radius = { 0, 0, 10, 0 },
}}
```

# border_right

The size of the border.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_right = 5,
}}
```

# border_right_color

A table of integers representing the RGBA values of the border.

Value   | Description
--------|------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	border_right_color = { 255, 0, 0, 255 },
}}
```

# border_top

The size of the border.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_top = 5,
}}
```

# border_top_color

A table of integers representing the RGBA values of the border.

Value   | Description
--------|------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	border_top_color = { 255, 0, 0, 255 },
}}
```

# border_top_left_radius

The radius of the rounded edge.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_top_left_radius = 5,
}}
```

# border_top_right_radius

The radius of the rounded edge.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	border_top_right_radius = 5,
}}
```

# box_shadow

**Currently not implemented.**

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	box_shadow = "initial",
}}
```
