local path     = (...):gsub('%.[^%.]+$', '')
      path     = path:sub(1,path:match("^.*()%."))
local Class    = require(path.."thirdparty.hump.class")
local cpml     = require(path.."thirdparty.cpml")
local Element  = require(path.."elements.element")
local Image    = Class {}

Image:include(Element)

function Image:init(element, parent, gui)
	Element.init(self, element, parent, gui)

	if self.path then
		if not self.gui.cache[self.path] then
			self.gui.cache[self.path] = love.graphics.newImage(self.path, {srgb=gui.srgb})
		end

		self.default_properties.image  = self.gui.cache[self.path]
		self.default_properties.width  = self.gui.cache[self.path]:getWidth()
		self.default_properties.height = self.gui.cache[self.path]:getHeight()
	end
end

return Image
