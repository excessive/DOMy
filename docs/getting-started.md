# Getting Started

## Basic Initialization

Like most Lua libraries, DOMinatrix requires very little setup get up and running. Simply require DOMinatrix into your project and initialize a new GUI instance. If you do not pass in any arguments, the GUI instance will automatically be sized to the current size of the game window.

```lua
local dom = require "DOMinatrix"
local gui = dom.new()
```

## Size Matters

`dom.new()` is the only function within the DOMinatrix core. This initialization function takes three optional arguments: width, height, and quirks_mode. Passing in a width and height value allows you to customize the area of your GUI. This will affect how elements are sized and positioned.

```lua
local dom = require "DOMinatrix"
local gui = dom.new(800, 600)
```

## Some Quirks

DOMinatrix is officially developed with LÖVE 0.9.2+ in mind. While it will technically run on any LÖVE 0.9.x platform, it uses some features new to 0.9.2 that are necessary for some features to work properly. By default, DOMinatrix will halt and warn you if you are using a version of LÖVE below 0.9.2. If you pass `true` as the third argument of `dom.new()` then it will not halt. Be warned, the results may be... quirky.

```lua
local dom = require "DOMinatrix"
local gui = dom.new(800, 600, true)
```
