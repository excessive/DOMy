local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local Element  = require(path.."elements.element")
local Block    = Class {}

Block:include(Element)

function Block:init(element, parent, gui)
	Element.init(self, element, parent, gui)
	self.default_properties.display = "block"
end

return Block
