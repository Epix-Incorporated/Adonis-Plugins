--!strict
--[[
	Author: ccuser44
	Name: KillLogs module extended
	Description: This plugin will add a killlogs command which keeps track of people who have died and for which reasons
	This is an extended version of the original plugin and adds more details about the reason of death
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-KillLogsExtended"
	License: MIT
--]]
--[[
	MIT License

	Copyright (c) 2021 Github@ccuser44

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
	local server, service = Vargs.Server, Vargs.Service

	local oldTabToType = server.Logs.TabToType
	server.Logs.KillLogs, server.Logs.TabToType, server.Logs.ListUpdaters.KillLogs = {}, function(tab: any, ...: any): string
		if tab == server.Logs.KillLogs then
			return "KillLogs"
		else
			return oldTabToType(tab, ...)
		end
	end, function(_)
		return server.Logs.KillLogs
	end

	server.Commands.KillLogs = {
		Prefix = server.Settings.Prefix;
		Commands = {"killlogs", "deathlogs"};
		Args = {"autoupdate? (default: false)"};
		Description = "View the logs of players who have died";
		AdminLevel = "Moderators";
		ListUpdater = "KillLogs";
		Function = function(plr: Player, args: {string})
			server.Remote.MakeGui(plr, "List", {
				Title = "Kill Logs";
				Table =  server.Logs.ListUpdaters.KillLogs(plr);
				Update = "KillLogs";
				AutoUpdate = if args[1] and (string.lower(args[1]) == "true" or string.lower(args[1]) == "yes") then 1 else nil;
				Sanitize = true;
			})
		end
	}

	server.Admin.CacheCommands()

	service.HookEvent("CharacterAdded", function(player: Player)
		local character = player.Character :: Model
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid") :: Humanoid

		humanoid.Died:Connect(function()
			local killer = humanoid:FindFirstChild("creator") :: ObjectValue

			if killer and killer.Value ~= nil then
				local killerName = (killer.Value:IsA("Humanoid") and killer.Value.Parent) and killer.Value.Parent.Name or killer.Value.Name :: string
				local humanoidRoot, killerRoot = humanoid.RootPart, (killer.Value:IsA("Humanoid") and killer.Value.RootPart or (killer.Value:IsA("Player") and killer.Value.Character) and killer.Value.Character.PrimaryPart)

				local message = killerName .. " killed " .. player.Name..((killerRoot and humanoidRoot) and string.format(" %.2f studs away", (humanoidRoot.Position - killerRoot.Position).Magnitude) or "")..((killer.Value:IsA("Player") and killer.Value.Character and killer.Value.Character:FindFirstChildOfClass("Tool")) and " with a "..killer.Value.Character:FindFirstChildOfClass("Tool").Name or "")

				server.Logs.AddLog(server.Logs.KillLogs, {
					Text = message,
					Desc = message,
				})
			end
		end)
	end)
end
