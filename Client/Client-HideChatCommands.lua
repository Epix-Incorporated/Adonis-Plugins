--!nonstrict
--[[
	Author: ccuser44
	Name: Hide chat commands module
	Description: This plugin will make it so that HideChatCommands is disabled for all players
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Client-HideChatCommands"
	License: MIT
--]]
--[[
	MIT License
	Copyright (c) 2023 Github@ccuser44
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

return function(Vargs)
	local client, service = Vargs.Client, Vargs.Service

	local oldRemoteGet = client.Remote.Get
	client.Remote.Get = function(...)
		local args = table.pack(...)
		if args[1] == "UpdateClient" and args[2] == "HideChatCommands" then
			return
		else
			return oldRemoteGet(...)
		end
	end

	rawset(client.Variables, "HideChatCommands", nil)

	if type(getmetatable(client.Variables)) == "table" then
		local mt = getmetatable(client.Variables)
		local oldNewIndex, oldIndex = mt.__newindex, mt.__index

		mt.__index = function(self, key)
			if key == "HideChatCommands" then
				return true
			elseif oldNewIndex then
				oldIndex(self, key)
			else
				rawget(self, key)
			end
		end

		mt.__newindex = function(self, key, value)
			if key == "HideChatCommands" then
				return
			elseif oldNewIndex then
				oldNewIndex(self, key, value)
			else
				rawset(self, key, value)
			end
		end
	else
		setmetatable(client.Variables, {
			__index = function(self, key)
				if key == "HideChatCommands" then
					return true
				else
					rawget(self, key)
				end
			end,
			__newindex = function(self, key, value)
				if key == "HideChatCommands" then
					return
				else
					rawset(self, key, value)
				end
			end
		})
	end
end
