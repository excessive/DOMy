# Syntax

DOMinatrix supports a Model-View-Control (MVC) paradigm right out of the box by allowing users to separate their user interface into external files. These files support their own syntax and API while remaining as valid Lua.

# Markup

Markup is the framework of a user interface. IN MVC terms, markup is the model. The model is used structure the interface and nothing more. This is the skeleton that we will put the skin and muscles on.

DOMinatrix uses a custom syntax designed to be very easy to learn and use. Similar (sort of) to HTML tags, DOMinatrix Markup is a group of nested tables that describe the data objects we want to create, and where to create them. The end result must be a table containing your markup.

## Markup Rules

**Some table keys are reserved for specific data:**

### [1]

Type of element you want to declare:

```lua

return {
	{ "text" },
}
```

### [2]

Text value of element, or a nested child (if it is a table):

```lua
return {
	{ "text", "Hello, World!" },
}
```

```lua
return {
	{ "block",
		{ "text", "Hello, World!" },
	},
}
```

### [3] -> [n]

Nested children of element:

```lua
return {
	{ "block",
		{ "text", "Hello, World!" },
		{ "text", "Goodbye, World!" },
	},
}
```

### value

Text value of element; takes presedence over `[2]`:



```lua
return {
	{ "text", "Hello, World!", value="Goodbye, World!" },
}
```

### id

Assign a unique ID to element:

```lua
return {
	{ "text", "Hello, World!", id="some_textbox" },
}
```

### class

Assign any number of non-unique classes to element:

```lua
return {
	{ "text", "Hello, World!", class="red" },
}
```

```lua
return {
	{ "text", "Hello, World!", class={ "red", "small" } },
}
```

### Custom Data

Assign any other named key to store custom data in element:

```lua
return {
	{ "text", "Hello, World!", custom_data=function() print("Custom Data!") end },
}
```

Because we are using valid Lua, markup can be written in a more templated way if so desired:

```lua
local strings = require "data.strings"
local markup = {}

for i=1, 10 do
	table.insert(markup, { "text", strings[i] })
end

return markup

```

# Styles

Styles are the beauty of an interface, the skin on our bones. In MVC terms, styles are the view. DOMinatrix Styles allow you to define individual style blocks based on CSS-like selectors and SCSS-like syntax.

## Selectors

### [none]

Defines an element:

```lua
"text"
```

### &#35;

Defines an ID:

```lua
"#some_textbox"
```

### .

Defines a class:

```lua
".red"
```

### :

Defines a pseudo class:

```lua
":last_child"
```

### [space]

Defines a descendant:

```lua
"block .red"
```

## Style Rules

 To create a style definition, you must write a selector query and give it a list of properties:

```lua
return {
	{ ".red", {
		text_color = { 255, 0, 0, 255 },
	}},
}
```

A style block can have any number of selector queries assigned to it:

```lua
return {
	{ ".red", "#red_textbox", {
		text_color = { 255, 0, 0, 255 },
	}},
}
```

A style block can have nested styles which will be treated as descendants of the parent selector queries:

```lua
return {
	{ "block", {
		width = 300,
		height = 200,

		-- "block .red", "block #red_textbox"
		{ ".red", "#red_textbox", {
			text_color = { 255, 0, 0, 255 },
		}},

		-- "block .small"
		{ ".small", {
			font_size = 10,
		}},
	}},
}
```

# Scripting

Scripts are the working horse if an interface, the muscles under the skin that makes everything tick. In MVC terms, scripts are the controller.

## Scripting Rules

There is really only one rule for the scripting API which is that all GUI API calls must begin with `gui:`:

```lua
local element = gui:get_element_by_id("some_id")
```

The scripting API allows you nearly full use of the Lua and LÖVE APIs, giving you a rich environment to write scripts and customize your interface to your liking.
