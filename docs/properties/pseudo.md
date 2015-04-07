<link type="text/css" rel="stylesheet" href="../style.css" />

A Pseudo Class is a special or dynamic state of an element. Pseudo Classes can be used to style elements when certain occurrences happen, such as if the element is being hovered over, or is the current element with focus.

# checked

Filters `check_list`, `radio_list`, and `multi_list` items that are selected.

```lua
{ "item:checked", {
	text_color = { 0, 255, 0, 255 },
}}
```

# disabled

Filters elements with the `enabled` attribute set to `false`.

```lua
{ "button:disabled", {
	background_color = { 200, 200, 200, 255 },
	text_color = { 220, 220, 220, 255 },
}}
```

# empty

Filters elements with no children.

```lua
{ "block:empty", {
	visible = false,
}}
```

# enabled

Filters elements with the `enabled` attribute set to `true`.

```lua
{ "button:enabled", {
	background_color = { 78, 189, 255, 255 },
	text_color = { 19, 86, 128, 255 },
}}
```

# first_child

Filters elements that are the first child of their parent.

```lua
{ "text:first_child", {
	font_size = 18
}}
```

# first_of_type(type)

Filters elements that are the first child of their parent that is of the selected type.

```lua
{ "block:first_of_type(text)", {
	font_size = 18
}}
```

# focus

Filters element that is the current active/focused element.

```lua
{ "button:focus", {
	background_color = { 189, 78, 255, 255 },
}}
```

# hover

Filters element that is currently being hovered over.

```lua
{ "button:hover", {
	background_color = { 122, 206, 253, 255 },
}}
```

# last_child

Filters elements that are the last child of their parent.

```lua
{ "text:last_child", {
	font_size = 8
}}
```

# last_of_type(type)

Filters elements that are the last child of their parent that is of the selected type.

```lua
{ "block:last_of_type(text)", {
	font_size = 8
}}
```

# not(selector)

Filters elements that are not within a given selector query.

```lua
{ "text:not(text:first_child)", {
	font_size = 14
}}
```

# nth_child(n)

Filters elements that are the nth child of their parent and `n` is an integer.

```lua
{ "text:nth_child(7)", {
	font_size = 14
}}
```

# nth_last_child(n)

Filters elements that are the nth last child of their parent and `n` is an integer.

```lua
{ "text:nth_last_child(5)", {
	font_size = 12
}}
```

# nth_last_of_type(type, n)

Filters elements that are the nth last child of their parent that is of the selected type and `n` is an integer.

```lua
{ "inline:nth_last_of_type(text, 3)", {
	font_size = 10
}}
```

# nth_of_type(type, n)

Filters elements that are the nth child of their parent that is of the selected type and `n` is an integer.

```lua
{ "inline:nth_of_type(text, 5)", {
	font_size = 14
}}
```

# only_child

Filters elements that are the only child of their parent.

```lua
{ "text:only_child", {
	font_size = 8
}}
```

# only_of_type(type)

Filters elements that are the only child of their parent that is of the selected type.

```lua
{ "block:only_of_type(text)", {
	font_size = 14
}}
```

# root

Filters all elements that have no parents.

```lua
{ "block:root", {
	visible = false
}}
```

# lclick

Filters elements that are currently being clicked by the `left` mouse button.

```lua
{ "button:lclick", {
	background_color = { 33, 174, 254, 255 }
}}
```

# mclick

Filters elements that are currently being clicked by the `middle` mouse button.

```lua
{ "button:mclick", {
	background_color = { 33, 174, 254, 255 }
}}
```

# rclick

Filters elements that are currently being clicked by the `right` mouse button.

```lua
{ "button:rclick", {
	background_color = { 33, 174, 254, 255 }
}}
```
