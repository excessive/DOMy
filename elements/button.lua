local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local cpml     = require(path..".thirdparty.cpml")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Button   = Class {}

Button:include(Element)

function Button:init(element, parent, gui)
	Element.init(self, element, parent, gui)

	self.default_properties.background_color = { 78, 189, 255, 255 }
	self.default_properties.border           = { 1, 1, 1, 1 }
	self.default_properties.text_color       = { 19, 86, 128, 255 }
	self.default_properties.text_align       = "center"
	self.default_properties.line_height      = 2.5
	self.default_properties.width            = 100

	self.on_mouse_enter    = self.default_on_mouse_enter
	self.on_mouse_pressed  = self.default_on_mouse_pressed
	self.on_mouse_down     = self.default_on_mouse_down
	self.on_mouse_released = self.default_on_mouse_released
	self.on_mouse_leave    = self.default_on_mouse_leave
end

function Button:default_on_mouse_enter(button)
	self:set_property("background_color", { 122, 206, 253, 255 })
end

function Button:default_on_mouse_pressed(button)
	self:set_property("background_color", { 33, 174, 254, 255 })
end

function Button:default_on_mouse_down(button)
	self:set_property("background_color", { 33, 174, 254, 255 })
end

function Button:default_on_mouse_released(button)
	self:set_property("background_color", { 122, 206, 253, 255 })
end

function Button:default_on_mouse_leave(button)
	self:set_property("background_color", { 78, 189, 255, 255 })
end

return Button
