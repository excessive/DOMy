# DOMy

DOMy is a DOM-like GUI framework designed for the \*awesome\* LÖVE framework.

We are currently looking for people to start beta testing DOMy! If you would like to test our API for comfort and help find bugs, that would be awesome! We are not currently accepting pull requests until DOMy has an official release.

All bundled tests pass. To verify tests, simply require the test file in main.lua and run it. Test verification is printed to the console.


## Current Features

* UI instances
* Markup API
* Style API
* Script API
* Import Files
	* Markup
	* Styles
	* Scripts
* Elements
	* block
	* button
	* image
	* inline
	* text
* Element hierarchy
* Element selectors
* Asset Cache
	* Images
	* Fonts
* Units
	* %
* Draw GUI
* Event System
* Widget System


## TODO

* Finish adding styles
* Finish adding default elements
* Add default widgets
* Implement theme system
* Implement virtual input system
* Implement smart draw system
* Implement dp and sp units


## Quick Example

### Markup Syntax

The following syntax example shows a very basic three level hierarchy of elements.

The first sequential (1, 2, 3, ...n) key defines the element type, in this case every element is of type "element".

The second sequential key can either be the value of an element, or the first child (if it is a table). Value can also be set with the "value" key. There are also the "id" and "class" keys. You can set a unique identifier to each element, and a non-unique class or group of classes. Both of these can be used for scripting and styling.

All sequential keys after value is determined MUST be valid element tables and will be treated as children of the element they are embedded in. Children can be nested indefinitely.

```lua
return {
	{ "inline", value="1" },
	{ "inline", value="2",
		{ "inline", value="2>1", class={ "child" } },
		{ "inline", value="2>2", class={ "child" },
			{ "inline", value="2>2>1", class={ "grandchild" } },
			{ "inline", value="2>2>2", class={ "grandchild" } },
			{ "inline", value="2>2>3", class={ "grandchild" } },
		},
		{ "inline", value="2>3", class={ "child" } },
	},
	{ "inline", value="3" },
	{ "inline", value="4", id="four" },
	{ "inline", value="5" },
	{ "inline", value="6" },
}
```


### Style Syntax

The style syntax takes very heavily from CSS and SCSS. It uses symbols to organize a selector query into different pieces:

* (none): Type
* (#): ID
* (.): Class
* (:): Pseudo-Class
* ( ): Descendant\*

\* Styles can be nested wherein the nested style is treated as a descendant of all parent selectors.

A style block can have any number of selectors and will terminate when it finds a table. It will then recursively check that table for a nested style block.

The order in which the style blocks are written determines the order in which they are applied.

```lua
return {
	-- All elements with the "inline" type
	{ "inline", {
		display = "block",
	}},

	-- The first (only!) element with the "four" id
	{ "#four", {
		text_color = { 255, 0, 0, 255 },
	}},

	-- All elements with the "child" class
	{ ".child", {
		display = "inline",
	}},

	-- All elements with the "inline" type
	-- All elements with the "child" class
	{ "inline", ".child", {
		-- All elements with the "grandchild" class that are descended of an element with the "child" class
		-- All elements with the "grandchild" class that are descended of an element with the "element" type
		{ ".grandchild", {
			text_color = { 0, 0, 255, 255 },
		}},

		padding = { 5, 5, 5, 5 },
	}},

	-- The last child element with the "grandchild" class that is a descendant of an element with the "child" class
	{ ".child .grandchild:last_child", {
		text_color = { 0, 255, 0, 255 },
	}},

	-- All elements without a parent
	{ ":root", {
		display = "block",
	}},

	-- The first (only!) element with the "four" id and the "inline" type
	{ "inline#four", {
		display = "block",
	}},
}
```


### Script Syntax

The scripting API uses the "gui" namespace, much like how JavaScript uses "document".

```lua
local element = gui:get_element_by_id("some_id")
element:set_property("text_color", { 255, 0, 0, 255 })

function element:on_mouse_enter()
	element:set_property("text_color", { 255, 255, 0, 255 })
end

function element:on_mouse_leave()
	element:set_property("text_color", { 255, 0, 0, 255 })
end

local new = gui:new_element({ "button", "Click Me!" })
new:attach(element)

function new:on_mouse_clicked(button)
	if button == "l" then
		print("Left click!")
	end
end
```


## License

This code is licensed under the [**MIT Open Source License**][MIT]. Check out the LICENSE file for more information.

[MIT]: http://www.opensource.org/licenses/mit-license.html
