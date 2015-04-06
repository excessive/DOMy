# bottom

If `position` is set to `relative`, `bottom` moves the element towards the bottom by an integral value. If `position` is set to `absolute` or `fixed`, `bottom` offsets the element from the bottom by an integral value.

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	position = "relative",
	bottom = 5,
}}
```

# clear

**Currently not implemented.**

Value   | Description
--------|------------
initial | Resets value to default
both    | Clear all floating elements
left    | Clear any left-floating elements
right   | Clear any right-floating elements
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	clear = "initial",
}}
```

# display

**Currently not implemented.**

Value   | Description
--------|------------
initial | "inline"
block   | Element is positioned on a new line, takes up full horizontal width available and the next element is positioned on a new line
flex    | **Currently not implemented.**
inline  | Element is positioned on the right of the previous element and only takes up the space it needs
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	display = "block",
}}
```

# float

**Currently not implemented.**

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	float = "initial",
}}
```

# height

Determine the height of an element. Height includes the border and padding of the element. Height can be either an integer or a string representing a percentage.

Value   | Description
--------|------------
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	height = 400,
}}
```

```lua
{ "inline", {
	height = "25%",
}}
```

# left

If `position` is set to `relative`, `left` moves the element towards the left by an integral value. If `position` is set to `absolute` or `fixed`, `left` offsets the element from the left by an integral value.

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	position = "relative",
	left = 5,
}}
```

# opacity

Opacity determines the level of visibility an elements has on a scale of 0 to 1, 0 being 100% transparent and 1 being 100% opaque.

Value   | Description
--------|------------
initial | 1
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	opacity = 0.75,
}}
```

# overflow

Determines how to handle long strings of text, or long words. The value can be a string (both X and Y use the same value) or a table of two (X, Y).

Value   | Description
--------|------------
initial | "visible"
hidden  | Any content outside the bounds of the element is clipped
scroll  | The element can be scrolled to display out-of-bounds content
visible | All content is displayed regardless of bounds
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	overflow = "scroll",
}}
```

```lua
{ "inline", {
	overflow = { "hidden", "scroll" },
}}
```

# overflow_x

Determines how to handle long strings of text, or long words along the X axis.

Value   | Description
--------|------------
initial | "visible"
hidden  | Any content outside the bounds of the element is clipped
scroll  | The element can be scrolled to display out-of-bounds content
visible | All content is displayed regardless of bounds
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	overflow_x = "scroll",
}}
```

# overflow_y

Determines how to handle long strings of text, or long words along the X axis.

Value   | Description
--------|------------
initial | "visible"
hidden  | Any content outside the bounds of the element is clipped
scroll  | The element can be scrolled to display out-of-bounds content
visible | All content is displayed regardless of bounds
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	overflow_y = "scroll",
}}
```

# padding

How far inset the content of an element is. The value can be an integer (all sides are the same size), a table of two (top and bottom, right and left), or a table of four (top, right, bottom, left).

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	padding = 5,
}}
```

```lua
{ "inline", {
	padding = { 5, 10 },
}}
```

```lua
{ "inline", {
	padding = { 50, 10, 5, 10 },
}}
```

# padding_bottom

How far inset the content of an element is.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	padding_bottom = 5,
}}
```

# padding_left

How far inset the content of an element is.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	padding_left = 5,
}}
```

# padding_right

How far inset the content of an element is.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	padding_right = 5,
}}
```

# padding_top

How far inset the content of an element is.

Value   | Description
--------|------------
initial | 0
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	padding_top = 5,
}}
```

# position

Determines where an element is within the box model.

Value    | Description
---------|------------
initial  | "static"
absolute | Moves the element to an absolute location based on the `top`, `right`, `bottom`, and/or `left` properties
fixed    | **Currently not implemented.**
relative | Moves the element relative to its static location based on the `top`, `right`, `bottom`, and/or `left` properties
static   | Element stays in its calculated location within the box model
inherit  | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	position = "relative",
	left = 25,
}}
```

# right

If `position` is set to `relative`, `right` moves the element towards the right by an integral value. If `position` is set to `absolute` or `fixed`, `right` offsets the element from the right by an integral value.

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	position = "relative",
	right = 5,
}}
```

# top

If `position` is set to `relative`, `top` moves the element towards the top by an integral value. If `position` is set to `absolute` or `fixed`, `top` offsets the element from the top by an integral value.

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	position = "relative",
	top = 5,
}}
```

# visible

Determines whether or not an element is drawn or not. An element's visibility also determines its children's visibility and its/their position within the box model. If visible is set to false, the box model flows as if the element and and children do not exist.

Value   | Description
--------|------------
initial | true
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	visible = false,
}}
```

# width

Determine the width of an element. Width includes the border and padding of the element. Width can be either an integer or a string representing a percentage.

Value   | Description
--------|------------
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	width = 400,
}}
```

```lua
{ "inline", {
	width = "25%",
}}
```

# vertical_align

**Currently not implemented.**

Value   | Description
--------|------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	vertical_align = "initial",
}}
```
