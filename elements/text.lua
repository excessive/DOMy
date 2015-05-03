local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local Element  = require(path.."elements.element")
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
