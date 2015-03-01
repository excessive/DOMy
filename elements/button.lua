local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local cpml     = require(path..".thirdparty.cpml")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Button   = Class {}

Button:include(Element)

function Button:init(element, parent, gui)
	Element.init(self, element, parent, gui)
end

return Button
