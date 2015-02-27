local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Inline   = Class {}

Inline:include(Element)

function Inline:init(element, parent, gui)
	Element.init(self, element, parent, gui)
end

return Inline
