--[[
------------------------------------------------------------------------------
DOMy is licensed under the MIT Open Source License.
(http://www.opensource.org/licenses/mit-license.html)
------------------------------------------------------------------------------

Copyright (c) 2015 Landon Manning - LManning17@gmail.com - LandonManning.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local DOM = {
	_LICENSE = "DOMy is distributed under the terms of the MIT license. See LICENSE.md.",
	_URL = "https://github.com/excessive/DOMy",
	_VERSION = "0.0.0",
	_DESCRIPTION = "DOMy is a DOM-like GUI library designed for the *awesome* LÖVE framework."
}

local path = (...):gsub('%.init$', '') .. "."

function DOM.new(width, height, quirks_mode)
	local gui = setmetatable({}, { __index = require(path .. "gui") })
	if not quirks_mode then
		local major, minor, rev = love.getVersion()
		local err = "DOMy requires LÖVE 0.9.2 or higher (if you are absolutely sure of what you are doing, use DOM.new(nil, nil, true) to skip this check)."
		if major == 0 and minor < 9 then
			error(err)
		elseif major == 0 and minor == 9 then
			assert(rev >= 2, err)
		end
	end
	gui:init(width, height)
	return gui
end

return DOM
