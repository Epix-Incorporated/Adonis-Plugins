--!strict
--[[
	Author: pbstFusion
	Name: Server-Uninspiration
	Description: To provide people with text that is not vaguely inspiring, nor helpful.

	Place in a ModuleScript under Adonis_Loader > Config > Plugins, named "Server-Uninspiration"
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	local Settings = server.Settings
	local Commands = server.Commands
	local Functions = server.Functions
	local Admin = server.Admin

	local BAD_QUOTES: {string} = {
		"It's never too late to go back to bed.",
		"I'm not superstitious, but I'm a little stitious.",
		"If you hate yourself, find an opinion you disagree with. You'll hate that much more.",
		"If you keep following your dreams, they'll file a restraining order.",
		"Don't trust random quotes you see online just because they've got a name. - Lenin",
		"what even am i doing",
		"The first step on the road to failure is trying.",
		"Today is pizza day, so head on down to the cafeteria to grab yourself a hot slice.",
		"Today's security code is: 5-33-41-18",
		"Insert other Sci-Fi genre quote here.",
		"Tiredness leads to lack of alertness, and lack of alertness leads to Adonis becoming bad.",
		"woooooooooosh"
	}

	Commands.Uninspired = {
		Prefix = Settings.Prefix;
		Commands = {"uninspire", "uninspiration", "badquote"};
		Description = "Exactly what it says: gives you ininspiration";
		Hidden = true;
		AdminLevel = "Players";
		Function = function(plr: Player)
			Functions.Message("Random Quote", BAD_QUOTES[math.random(1, #BAD_QUOTES)], {plr})
		end
	}

	Admin.CacheCommands()
end
