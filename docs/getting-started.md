<link type="text/css" rel="stylesheet" href="../style.css" />

# Getting Started

## Basic Initialization

Like most Lua libraries, DOMy requires very little setup get up and running. Simply require DOMy into your project and initialize a new GUI instance. If you do not pass in any arguments, the GUI instance will automatically be sized to the current size of the game window.

```lua
local dom = require "DOMy"
local gui = dom.new()
```

## Size Matters

`dom.new()` is the only function within the DOMy core. This initialization function takes three optional arguments: `width`, `height`, and `quirks_mode`. Passing in a `width` and `height` value allows you to customize the area of your GUI. This will affect how elements are sized and positioned.

```lua
local dom = require "DOMy"
local gui = dom.new(800, 600)
```

## Some Quirks

DOMy is officially developed with LÖVE 0.9.2+ in mind. While it will technically run on any LÖVE 0.9.x platform, it uses some features new to 0.9.2 that are necessary for some features to work properly. By default, DOMy will halt and warn you if you are using a version of LÖVE below 0.9.2. If you pass `true` as the third argument of `dom.new()` then it will not halt. Be warned, the results may be... quirky.

```lua
local dom = require "DOMy"
local gui = dom.new(800, 600, true)
```

## Register Callbacks

DOMy requires access to most of LÖVE's callbacks to function properly. There are several ways to go about registering them. The first way is manually:

```lua
function love.update(dt)
	-- do stuff
	gui:update(dt)
end
```

This works if you need to manually set code for every callback such as if you have non-GUI things drawing on screen, etc. If you are only using DOMy, you can loop through the necessary callbacks and register them as follows:

```lua
local callbacks = gui:get_callbacks()
for _, callback in ipairs(callbacks) do
	love[callback] = function(...)
		gui[callback](gui, ...)
	end
end
```

This, however, is not ideal i most situations since you usually want non-GUI activities happening in your game or application. Luckily, you can perform both actions to minimize boilerplate code.

```lua
local callbacks = gui:get_callbacks()
for _, callback in ipairs(callbacks) do
	love[callback] = function(...)
		gui[callback](gui, ...)
	end
end

function love.update(dt)
	-- do stuff
	gui:update(dt)
end
```

As you can see in the above example, first we register all the callbacks in your quick little loop, then we override any callbacks we need non-GUI actions in. This cuts down on boilerplate while allowing full functionality of your game.
