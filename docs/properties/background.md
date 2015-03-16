# background_attachment

**Currently not implemented.**

Value   | Description
--------/------------
initial | Resets value to default
inherit | Uses the immediate parent's value (or nil)

```lua
{ "inline", {
	background_attachment = "initial",
}}
```

# background_color

A table with four sequential keys representing red, green, blue, and alpha.

Value   | Description
--------/------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	background_color = { 255, 0, 0, 255 },
}}
```

# background_image_color

A table with four sequential keys representing red, green, blue, and alpha.

Value   | Description
--------/------------
initial | { 255, 255, 255, 255 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ ".red", {
	background_image_color = { 255, 0, 0, 255 },
}}
```

# background_path

A path string pointing to an image file.

Value   | Description
--------/------------
inherit | Uses the immediate parent's value (or nil)

```lua
{ "button", {
	background_path = "assets/images/button.png",
}}
```

# background_position

A vec2 representing the offset of the background image.

Value   | Description
--------/------------
initial | { 0, 0 }
inherit | Uses the immediate parent's value (or nil)

```lua
{ "button", {
	background_position = { 5, 7 },
}}
```

# background_repeat

**Currently not implemented.**

Value   | Description
--------/------------
inherit | Uses the immediate parent's value (or nil)

```lua
{ "button", {
	background_repeat = "inherit",
}}
```

# background_size

A vec2 representing the size of the background image.

Value   | Description
--------/------------
inherit | Uses the immediate parent's value (or nil)

```lua
{ "button", {
	background_size = { 300, 100 },
}}
```
