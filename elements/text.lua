local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Text     = Class {}

Text:include(Element)

function Text:init(element, parent, gui)
	Element.init(self, element, parent, gui)

	-- Display
	self.default_properties.display = "block"

	-- Font
	self.default_properties.font_path   = "inherit"
	self.default_properties.font_size   = "inherit"
	self.default_properties.line_height = "inherit"
	self.default_properties.text_align  = "inherit"
	self.default_properties.text_shadow = "inherit"

	-- Color
	self.default_properties.text_color        = "inherit"
	self.default_properties.text_shadow_color = "inherit"
end

return Text
