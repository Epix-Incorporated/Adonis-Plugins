--!nonstrict
--[[
	Author: BaconOfWalker (Jumbo891011)
	Name: Server-Leaderstats
	Description: Adds :createstat and :removestat; Lets you create/remove leaderstats.
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
		Commands = {"createstat", "cstat"};
		Args = {"name"};
		Description = "Creates a new leaderstat";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})

			local statName = assert(args[1], "Missing stat name")

			for _, v in service.GetPlayers(plr, args[1]) do
				local leaderstats = plr:FindFirstChild("leaderstats")

				if leaderstats and (leaderstats:IsA("Folder") or leaderstats:IsA("StringValue")) then
					local statName = Instance.new("IntValue")
					statName.Name = args[1]
					statName.Value = 0
					statName.Parent = leaderstats
				else
					local newStats = Instance.new("Folder")
					newStats.Name = "leaderstats"
					newStats.Parent = plr

					local statName = Instance.new("IntValue")
					statName.Name = args[1]
					statName.Value = 0
					statName.Parent = newStats
				end
			end
		end
	}

	Commands.RemoveLeaderstats = {
		Prefix = Settings.Prefix;
		Commands = {"removestat", "rstat"};
		Args = {"name"};
		Description = "Removes a leaderstat";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			local statName = assert(args[1], "Missing the stat name!")

			for _, v in service.GetPlayers(plr, args[1]) do
				local children = plr:GetChildren()
				local leaderstats = plr.leaderstats -- This checks if there is a leaderstats folder/string value [Don't change it unless you know what you are doing]

				if table.find(children, leaderstats) and (leaderstats:IsA("Folder") or leaderstats:IsA("StringValue")) then
					local absoluteMatch = leaderstats:FindFirstChild(statName)
					if absoluteMatch and (absoluteMatch:IsA("IntValue") or absoluteMatch:IsA("NumberValue")) then
						absoluteMatch:Destroy()
					else
						for _, st in leaderstats:GetChildren() do
							if (st:IsA("IntValue") or st:IsA("NumberValue")) then
								st:Destroy()
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
