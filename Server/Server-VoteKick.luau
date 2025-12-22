return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Remote, Logs = server.Remote, server.Logs

	server.Variables.VoteKickActive = false

	server.Commands.VoteKick = {
		Prefix = server.Settings.Prefix;
		Commands = {"votekick"};
		Args = {"player", "reason"};
		Description = "Votekick a player to be kicked";
		Hidden = false;
		Fun = false;
		AdminLevel = "Players";
		Function = function(plr,args)
			assert(args[1], "You need to specifiy a player to vote kick.")
			assert(not server.Variables.VoteKickActive, "There already is a vote kick active!")

			if #server.Functions.GetPlayers(plr, args[1], {DontError = true}) > 1 then
				assert(false, "You cannot vote kick more than one player at a time.")
			end

			local player = server.Functions.GetPlayers(plr, args[1])[1]
			if not player then return end

			local responses = {}

			for i, v in service.GetPlayers(plr, "all") do
				task.spawn(function()
					local response = Remote.GetGui(v, "Vote", {
						Question = `Vote kick {player}? Reason: {args[2] or "No reason provided."}`;
						Answers = {"Yes", "No"};
					})
					if response then
						table.insert(responses, response)
					end
				end)
			end

			task.spawn(function()
				server.Variables.VoteKickActive = true
				task.wait(30)

				local Yes = 0
				local No = 0

				for i, v in responses do
					if v == "Yes" then
						Yes += 1
					elseif v == "No" then
						No += 1
					end
				end

				server.Variables.VoteKickActive = false

				local playerAfterVote = server.Functions.GetPlayers(plr, args[1], {DontError = true})[1]
				if Yes > No then
					if playerAfterVote then
						playerAfterVote:Kick(`Vote kicked. Reason: {args[2] or "No reason provided."}`)
						Logs:AddLog("Script", `{service.FormatPlayer(playerAfterVote)} was votekicked. Reason: {args[2] or "No reason provided."}`)
						server.Functions.Notify("Vote kick", `{service.FormatPlayer(playerAfterVote)} was vote kicked.`, {plr})
					else
						server.Functions.Notify("Vote kick", `{service.FormatPlayer(player)} was unable to be vote kicked because they left the server.`, {plr})
					end
				else
					server.Functions.Notify("Vote kick", `{service.FormatPlayer(playerAfterVote)} was not vote kicked.`, {plr})
				end
			end)
		end
	}
end
