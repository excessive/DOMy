local path     = (...):gsub('%.[^%.]+$', '')
local new_path = path:gsub("%.", "/")
local Class    = require(path..".thirdparty.hump.class")
local cpml     = require(path..".thirdparty.cpml")
local Element  = assert(love.filesystem.load(new_path.."elements/element.lua"))(path)
local Image    = Class {}

Image:include(Element)

function Image:init(element, parent, gui)
	Element.init(self, element, parent, gui)

	if self.path then
		if not self.gui.cache[self.path] then
			self.gui.cache[self.path] = love.graphics.newImage(self.path, gui.srgb and "srgb" or nil)
		end

		self.default_properties.image  = self.gui.cache[self.path]
		self.default_properties.width  = self.gui.cache[self.path]:getWidth()
		self.default_properties.height = self.gui.cache[self.path]:getHeight()
	end
end

return Image
