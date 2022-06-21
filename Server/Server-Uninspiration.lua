return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.Uninspired = {
		Prefix = server.Settings.Prefix;	-- Prefix to use for command
		Commands = {"uninspire"};	-- Commands
		Args = {};	-- Command arguments
		Description = "Exactly what it says. Gives you ininspiration.";	-- Command Description
		Hidden = true; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Players";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr)    -- Function to run for command
			local Quotes = {
				"It's never too late to go back to bed.";
				"I'm not superstitious, but I'm a little stitious.";
				"If you hate yourself, find an opinion you disagree with. You'll hate that much more.";
				"If you keep following your dreams, they'll file a restraining order.";
				"Don't trust random quotes you see online just because they've got a name. - Lenin";
				"what even am i doing";
				"The first step on the road to faliure is trying.";
				"Today is pizza day, so head on down to the cafeteria to grab yourself a hot slice.";
				"Today's security code is: 5-33-41-18";
				"Insert other Sci-Fi genre quote here.";
				"Tiredness leads to lack of alertness, and lack of alertness leads to Adonis becoming bad.";
			}
			server.Functions.Message("Random Quote", Quotes[math.random(1, #Quotes)], {plr})
		end
	}
end
