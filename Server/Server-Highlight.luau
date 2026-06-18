--[[
	File: Server-Highlight.luau
	Author: WayniD1973/harleydyson
	Description: Highlights the given player(s). An alternative to :track in a way
	Version: 1.0
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.Highlight = {
		Prefix = server.Settings.Prefix;
		Commands = {"highlight"};
		Args = {"player"};
		Description = "Highlights a player";
		Hidden = false;
		Fun = false;
		AdminLevel = "Moderators";

		Function = function(plr, args)
			local targets = service.GetPlayers(plr, args[1])

			for _, target in ipairs(targets) do
				local character = target.Character

				if character then
					local existing = character:FindFirstChild("FAS_Highlight")
					if existing then
						existing:Destroy()
						return
					end

					local highlight = Instance.new("Highlight")
					highlight.Name = "FAS_Highlight"
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = character
				end
			end
		end
	}
end
