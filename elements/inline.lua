local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local Element  = require(path.."elements.element")
local Inline   = Class {}

Inline:include(Element)

function Inline:init(element, parent, gui)
	Element.init(self, element, parent, gui)
end

return Inline
