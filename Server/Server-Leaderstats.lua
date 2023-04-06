--!nonstrict
--[[
	Author: BaconOfWalker (Jumbo891011)
	Name: Server-Leaderstats
	Description: Adds :createstat and :removestat; Lets you create/remove leaderstats
	Place in a ModuleScript under Adonis_Loader > Config > Plugins, named "Server-Leaderstats"
--]]

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Settings = server.Settings
	local Commands = server.Commands
	local Functions = server.Functions
	local Remote = server.Remote
	
	Commands.CreateLeaderstats = {
		Prefix = Settings.Prefix;
		Commands = {"createstat", "cstat", "cs"};
		Args = {"name"};
		Description = "Creates a new leaderstat";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})

			local statName = assert(args[1], "Missing stat name")

			for _, v in service.GetPlayers(plr, args[1]) do
				local leaderstats = Instance.new("Folder")
				leaderstats.Name = "leaderstats"
				leaderstats.Parent = plr

				if leaderstats then
					local statName = Instance.new("IntValue")
					statName.Name = args[1]
					statName.Value = 0
					statName.Parent = leaderstats
				end
			end
		end
	}
	
	Commands.	RemoveLeaderstats = {
		Prefix = Settings.Prefix;
		Commands = {"removestat", "rstat", "rs"};
		Args = {"name"};
		Description = "Removes a leaderstat";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})

			local statName = assert(args[1], "Missing the stat name!")

			for _, v in service.GetPlayers(plr, args[1]) do
				local leaderstats = plr:FindFirstChild("leaderstats")

				if leaderstats then
					local absoluteMatch = leaderstats:FindFirstChild(statName)
					if absoluteMatch and (absoluteMatch:IsA("IntValue") or absoluteMatch:IsA("NumberValue")) then
						leaderstats:Destroy()
					else
						for _, st in leaderstats:GetChildren() do
							if (st:IsA("IntValue") or st:IsA("NumberValue")) and string.match(st.Name:lower(), "^"..statName:lower()) then
								leaderstats:Destroy()
							end
						end
					end
				else
					Functions.Hint(service.FormatPlayer(v).." doesn't have a leaderstats folder", {plr})
				end
			end
		end
	}
end
