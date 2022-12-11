--!strict
--[[
	Author: ccuser44
	Description: This plugin will add a killlogs command which keeps track of epople who have died and for which reasons
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-KillLogs"
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	local oldTabToType = server.Logs.TabToType
	server.Logs.KillLogs, server.Logs.TabToType = {}, function(tab: any, ...: any): string
		if tab == server.Logs.KillLogs then
			return "KillLogs"
		else
			return oldTabToType(tab, ...)
		end
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
				Dots = true;
				Update = "KillLogs";
				AutoUpdate = if args[1] and (string.lower(args[1]) == "true" or string.lower(args[1]) == "yes") then 1 else nil;
				Sanitize = true;
				Stacking = true;
			})
		end
	}

	server.Admin.CacheCommands()

	service.HookEvent("CharacterAdded", function(player: Player)
		local humanoid = player:FindFirstChildOfClass("Humanoid") or player.Character:WaitForChild("Humanoid") :: Humanoid

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
