return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Remote, Logs = server.Remote, server.Logs

	server.Commands.VoteKick = {
		Prefix = server.Settings.Prefix;
		Commands = {"votekick"};
		Args = {"Player", "Reason"};
		Description = "Votekick a player to be kicked";
		Hidden = false;
		Fun = false;
		AdminLevel = "Players";
		Function = function(plr,args)
			assert(args[1], "You need to specifiy a player to vote kick")
			
			if #server.Functions.GetPlayers(plr, args[1], {NoFakePlayer = true})  > 1 then
				assert(false, "You cannot vote more than one player at a time")
			end
			
			local responses = {}
			
			for i, v in service.GetPlayers(plr, "all") do
				task.spawn(function()
					local response = Remote.GetGui(v, "Vote", {
						Question = `Vote kick {server.Functions.GetPlayers(plr, args[1], {NoFakePlayer = true})[1]}? Reason: {args[2] or "No reason provided."}`;
						Answers = {"Yes", "No"};
					})
					if response then
						table.insert(responses, response)
					end
				end)
			end
			
			task.spawn(function()
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
				
				local Player = server.Functions.GetPlayers(plr, args[1])[1]
				
				if Yes > No then
					if Player then
						Player:Kick(`Vote kicked. Reason: {args[2] or "No reason provided."}`)
						Logs:AddLog("Script", `{Player.Name} was votekicked. Reason: {args[2] or "No reason provided."}`)
					end
					server.Functions.Notify("Vote kick", `{Player.Name} was vote kicked.`, {plr})
				else
					server.Functions.Notify("Vote kick", `{Player.Name} was not vote kicked.`, {plr})
				end
			end)
		end
	}
end
