local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local cpml     = require(path.."thirdparty.cpml")
local Element  = require(path.."elements.element")
local Button   = Class {}

Button:include(Element)

function Button:init(element, parent, gui)
	Element.init(self, element, parent, gui)
end

return Button
