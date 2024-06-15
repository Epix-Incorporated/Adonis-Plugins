--[[
	Author: ccuser44, Sceleratis, Epix Incorporated, and the Adonis Community.
	Name: Hide chat commands
	Description: This hides the chat commands for all players.
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-HideChatCommands"
	License: MIT
--]]
--[[
    MIT License

    Copyright (c) 2016-2024 Sceleratis (https://github.com/Sceleratis), Epix Incorporated, and the Adonis Community.
    Copyright (c) 2024 ccuser44/ALE111_boiPNG

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
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Admin, Remote, Core, Settings, Variables = server.Admin, server.Remote, server.Core, server.Settings, server.Variables
	Admin.DoHideChatCmd = function(p: Player, message: string, data: {[string]: any}?)
		local hideCommands = (data or Core.GetPlayer(p)).Client.HideChatCommands
		if hideCommands == nil or hideCommands == true then
			if Variables.BlankPrefix and
				(string.sub(message, 1, 1) ~= Settings.Prefix or string.sub(message, 1, 1) ~= Settings.PlayerPrefix) then
				local isCMD = Admin.GetCommand(message)
				if isCMD then
					return true
				else
					return false
				end
			elseif (string.sub(message, 1, 1) == Settings.Prefix or string.sub(message, 1, 1) == Settings.PlayerPrefix)
				and string.sub(message, 2, 2) ~= string.sub(message, 1, 1) then
				return true
			end
		end
	end
	
	service.HookEvent("CharacterAdded", function(player: Player)
		--// Doesn't save unless sent to server by player
		if player.Client.HideChatCommands == nil then
			Remote.Send(player, "SetVariables", { HideChatCommands = true })
		end
	end)
end
