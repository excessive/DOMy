local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Block    = Class {}

Block:include(Element)

function Block:init(element, parent, gui)
	Element.init(self, element, parent, gui)
	self.default_properties.display = "block"
end

return Block
