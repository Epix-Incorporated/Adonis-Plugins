--!strict
---------
--[[ Module Info:
	Original Author: Sceleratis/Davey_Bones
	Description: This plugin will whitelist only certain commands for use, and set the rest as Creators-only
	
	Place this ModuleScript in Adonis's Folder > Config > Plugins and the name should start either by "Server:" or "Server-".
--]]
--[[ More Info:
	If the value is set to a Permission type (rank name or level), it will use that as the new AdminLevel
	Any command that is not in the below tables, its permission will be set automatically as Creators (Level 900+) only.
]]
-------------------------------------------------------|
--| Extra. An array to show specific hidden commands:
local Commands_To_UnHide: {string} = {
	"theme",
	"notifyme",
	"countries",
	"addfriend",
	"unfriend",
	"incognitolist",
}

local CMDs_With_Permissions: {[string]: string | number | boolean} = {}
local Whitelisted_Commands: {[string | number]: {string}} = {

	--| Format:
	--| ["Default"] = {Command/s}  -- Equals that the command permission will be set to "false" meaning that it will be with its original (default) AdminLevel.
	--| [Permission] = {Command/s} -- Where "Permission" is the Admin Rank Name or the indexed Admin Level Number ([Level]) and "Command/s" is a string value.
	
	--| CMD/s with its default permissions:
	Default = {
		"cape",
		"capes",
		"uncape",
		"countdown",
	};

	--| Players+ Commands:
	Players = {
		"ap",
		"cmds",
		"join",
		"ping",
		"pnum",
		"rand",
		"theme",
		"paint",
		"quote",
		"client",
		"invite",
		"rejoin",
		"aliases",
		"notepad",
		"notifyme",
		"keybinds",
		"timedate",
		"unfriend",
		"addfriend",
		"countries",
		"devconsole",
		"joinfriend",
		"blockedusers",
		"uninspiration",
		"onlinefriends",
		"inspectavatar",
	};
	
	--| Moderators+ Commands:
	Moderators = {
		"h",
		"m",
		"cm",
		"pm",
		"tm",
		"th",
		"tp",
		"to",
		"rv",
		"npm",
		"mpm",
		"afk",
		"ban",
		"esp",
		"sit",
		"warn",
		"heal",
		"stun",
		"tell",
		"kick",
		"team",
		"note",
		"view",
		"logs",
		"mute",
		"info",
		"usage",
		"unban",
		"slock",
		"teams",
		"tools",
		"unesp",
		"track",
		"clear",
		"notes",
		"bring",
		"unblur",
		"unmute",
		"unview",
		"unstun",
		"myhats",
		"unteam",
		"donors",
		"cmdbox",
		"refresh",
		"players",
		"profile",
		"mutelist",
		"warnings",
		"newteam",
		"untrack",
		"viewcam",
		"kickwarn",
		"joinlogs",
		"chatlogs",
		"showlogs",
		"leavelogs",
		"locallogs",
		"rbxnotify",
		"incognito",
		"showtools",
		"hcountdown",
		"chatnotify",
		"serverlist",
		"removeteam",
		"removenote",
		"unnincognito",
		"removenotes",
		"countdownpm",
		"exploitlogs",
		"privatechat",
		"cleareffects",
		"notifications",
		"removewarning",
		"clearwarnings",
		"stopcountdown",
		"clearadonisguis",
		
		--| Fun Commands Allowed:
		"rope",
		"gear",
		"blur",
		"unrope",
		"glitch",
		"unglitch",
		"uneffect",
	};
	
	--| Admins+ Commadns:
	Admins = {
		"sn",
		"sm",
		"vote",
		"jump",
		"shirt",
		"pants",
		"bchat",
		"unchat",
		"jpower",
		"admins",
		"notify",
		"unname",
		"cmdinfo",
		"cameras",
		"guiview",
		"jheight",
		"oldlogs",
		"shutdown",
		"unguiview",
		"resetview",
		"setmessage",
		"shutdownlogs",
		"softshutdown",
		"getgroupinfo",
		"incognitolist",

		--| Music Permissions:
		"music",
		"pause",
		"resume",
		"musiclist",
		"stopmusic",

		--| Fun Commands Allowed:
		"cut",
		"dance",
		"smoke",
		"unsmoke",
	};

	--| HeadAdmins+ Commands:
	HeadAdmins = {
		"fly",
		"fix",
		"give",
		"sudo",
		"clip",
		"kill",
		"alert",
		"admin",
		"unfly",
		"freeze",
		"health",
		"noclip",
		"tempmod",
		"gameban",
		"banlist",
		"respawn",
		"visible",
		"permban",
		"tempban",
		"freecam",
		"unadmin",
		"permmod",
		"slowmode",
		"flyspeed",
		"trelloban",
		"backupmap",
		"broadcast",
		"perfstats",
		"unfreecam",
		"errorlogs",
		"invisible",
		"flynoclip",
		"ungameban",
		"untimeban",
		"directban",
		"removetool",
		"serverinfo",
		"restoremap",
		"serverspeed",
		"timebanlist",
		"removetools",
		"undirectban",
		"crossserver",
		"tempunadmin",
		"adonisalerts",
		"privateservers",
		"crossservervote",
		"fixplayerlighting",
	};


	--[[-----------------------------------------
	--| All Available Default Fun Commands (128):

	ice					-- [Freezes the target player/s character within an ice block] [Opposite: unice]
	dog					-- [R6 Characters only]
	wat					-- [Player Perfix] / [Hidden Command]
	mat					-- [Shows you materials; Same as ":materials"]
	cut					-- [Cuts and make the player bleed]
	nuke				-- [As it says, nukes player]
	spin				-- [Spins the character]
	neon				-- [Make the target neon]
	dogg				-- [Turns the target into the one and only D O Double G]
	talk				-- [Makes a dialog bubble appear over the target player(s) head with the desired message]
	grav				-- [Restores the original experience gravity]
	rope				-- [Connects players using a rope constraint]
	nyan				-- [Poptart kitty texture instead of the character]
	sh1a				-- [sh1a]
	gear				-- [Gives the target player(s) a gear from the catalog based on the ID you supply]
	trip				-- [Rotates the target player(s) by 180 degrees or a custom angle]
	maze				-- [Sends player to The Maze for a timeout | External Teleport]
	blur				-- [Blurs the target player's screen with the blur size you provide]
	fr0g				-- [Turns the target player's character into frog texture]
	puke				-- [Make the target player(s) puke (Not cool.)]
	hole				-- [Sends the target player(s) down a hole]
	fire				-- [Sets the target player(s) on fire, coloring the fire based on what you set]
	pets				-- [Makes your hat pets do the specified command (follow/float/swarm/attack)]
	smoke				-- [Makes smoke come from the target player(s) with the desired color; Same as ":givesmoke"]
	shrek				-- [Shrekify the target player(s)]
	ggrav				-- [Sets the Workspace.Gravity]
	disco				-- [Turns the place into a disco party!]
	dance				-- [Make the target player(s) dance]
	spook				-- [Turns the target player(s) screen spooky. Not recommended]
	dizzy				-- [Causes motion sickness and the target player(s) screen keeps rotating]
	bloom				-- [Give the player's screen the bloom lighting effect]
	k1tty				-- [Kitty 2D moving  texture instead of the targeted player(s) character]
	trail				-- [Adds trails to the target's character's parts]
	blind				-- [Turns the target player(s) screen into black]
	clown				-- [Targetted player(s) will be kidnapped by clowns. External Teleport.]
	poison				-- [Slowly kills the target player(s)]
	resize				-- [Resize the target player(s)'s character by <mult>]
	sp00ky				-- [Turns the targetted player(s) character into a moving 2D skeleton]
	rocket				-- [Sends the targetted player(s) to the Moon!]
	infect				-- [Turn the target player(s) into a suit zombie]
	sticky				-- [Makes the targetted player(s) sticky and stick to any part]
	glitch				-- [Glitch effect. Local Only.]
	unspin				-- [Opposite of command ":spin"]
	unrope				-- [Removes the rope constraint made by command ":rope"]
	brazil				-- [YOU ARE GOING TO BRAZIL!]
	freaky				-- [Does freaky stuff to lighting. Like a messed up ambient.]
	forest				-- [Sends player to The Forest for a timeout. External Place Teleport!]
	thanos				-- [Makes the targetted player(s) disappear and then kicks them]
	nograv				-- [NoGrav the target player(s)]
	setfps				-- [Sets the target players's FPS]
	lowres				-- [Pixelizes the player's view]
	gerald				-- [A massive Gerald AloeVera hat.]
	chik3n				-- [Call on the KFC dark prophet powers of chicken]
	shiney				-- [Make the target player(s)'s character shiney]
	unfire				-- [Opposite of command ":fire"]
	bodyswap			-- [Swaps player1's and player2's avatars, bodies and tools]
	bighead				-- [Gives the target player(s) a larger ego]
	particle			-- [Puts custom particle emitter on target]
	trolled				-- [Not Recommended.]
	skeleton			-- [Turn the target player(s) into a skeleton]
	loadsky				-- [Change the skybox with the provided image IDs]
	chargear			-- [Gives you a doll of a player]
	undizzy				-- [Opposite of command ":dizzy"]
	setgrav				-- [Set the target player(s)'s gravity]
	creeper				-- [Turn the target player(s) into a creeper]
	thermal				-- [Changes the targetted player(s) screen into thermal vision view]
	bunnyhop			-- [akes the player jump, and jump... and jump. Just like the rabbit noobs you find in sf games.]
	zawarudo			-- [Freezes everything but the player running the command]
	explode				-- [Explodes the target player(s)]
	sunrays				-- [Give the player's screen the sunrays lighting effect]
	slippery			-- [Makes the target player(s) slide when they walk]
	boombox				-- [Gives the target player(s) a boombox]
	ungerald			-- [De-Geraldification. Opposite of ":gerald"]
	iloveyou			-- [Not Recommended]
	ghostify			-- [Turn the target player(s) into a ghost]
	headlian			-- [Something weird.]
	flatten				-- [Makes the targetted player(s) like a 2D texture]
	vibrate				-- [Kinda like gd, but teleports the player to four points instead of two]
	goldify				-- [Turns the character into a golden one!]
	swagify				-- [Swag the target player(s) up]
	freefall			-- [Teleport the target player(s) up by <height> studs]
	sparkles			-- [Puts sparkles on the target player(s) with the desired color]
	noobify				-- [Make the target player(s) look like a noob]
	hatpets				-- [Gives the target player(s) hat pets.]
	seizure				-- [Make the target player(s)'s character spazz out on the floor]
	uneffect			-- [Removes any effect GUIs on the target player(s)]
	tornado				-- [Makes a tornado on the target player(s)]
	wildfire			-- [Starts a fire at the target player(s); Ignores locked parts and parts named 'BasePlate' or 'Baseplate']
	theycome			-- [Not Recommended]
	unsmoke				-- [Removes any smoke from the targetted player(s) character]
	oddliest			-- [Turns you into the one and only Oddliest]
	trigger				-- [Makes the target player really angry]
	unglitch			-- [Opposite of command ":glitch"]
	stickify			-- [Turns the target player(s) into a stick figure]
	loopfling			-- [Loop flings the target player(s)]
	deadlands			-- [The edge of Roblox math; WARNING CAPES CAN CAUSE LAG]
	unseizure			-- [Removes the effects of the seizure command]
	unthermal			-- [Removes thermal vision; Opposite for ":thermal"]
	['break']			-- [Break the target player(s)]
	animation			-- [Load the animation onto the target]
	lightning			-- [Zeus strikes down the target player(s)]
	smallhead			-- [Give the target player(s) a small head]
	unbunnyhop			-- [Stops the forced hippity hoppening]
	playergear			-- [Turns the target player into a doll which can be picked up]
	rainbowify			-- [Make the target player(s)'s character flash random colors]
	unparticle			-- [Removes particle emitters from target]
	unsparkles			-- [Removes sparkles from the target player(s)]
	breakdance			-- [Make the target player(s) break dance]
	unslippery			-- [Get sum friction all up in yo step; Opposite of command ":slippery"]
	oldflatten			-- [Old Flatten. Went lazy on this one.]
	restorefps			-- [Restores the target players's FPS]
	sceleratis			-- [Turns the targetted player(s) into this charactar avatar]
	undeadlands			-- [Clips the player and teleports them to you]
	startergear			-- [Inserts the desired gear into the target player(s)'s starter gear]
	oldbodyswap			-- [[Old] Swaps player1's and player2's bodies and tools]
	Davey_Bones			-- [Turns the targetted player(s) character into Davey_Bones' one]
	removelimbs			-- [Remove the target player(s)'s arms and legs]
	screenimage			-- [Places the desired image on the target's screen]
	screenvideo			-- [Places the desired video on the target's screen]
	unloopfling			-- [Ends command ":loopfling"]
	ghostglitch			-- [The same as gd but less trippy, teleports the target player(s) back and forth in the same direction, making two ghost like images of the game]
	stopwildfire		-- [Stops the command ":wildfire" and stops fire from spreading further]
	colorcorrect		-- [Give the player's screen the sunrays lighting effect]
	runanimation		-- [Change the target player(s)'s run animation, based on the default animation system. Supports 'R15' as animationID argument to use default rig animation.]
	jumpanimation		-- [Change the target player(s)'s jump animation, based on the default animation system. Supports 'R15' as animationID argument to use default rig animation.]
	fallanimation		-- [Change the target player(s)'s fall animation, based on the default animation system. Supports 'R15' as animationID argument to use default rig animation.]
	walkanimation		-- [Change the target player(s)'s walk animation, based on the default animation system. Supports 'R15' and 'R6' as animationID argument to use default rig animation.]
	createsoundpart		-- [Creates a sound part]
]]
}

for Permission, CMDTable in pairs(Whitelisted_Commands) do
	local Permission = (Permission ~= "Default" and Permission) or false
	for _, CMD in ipairs(CMDTable) do
		CMDs_With_Permissions[CMD:lower()] = Permission
	end
end

return function(Vargs)
	local Server = Vargs.Server
	for CMDName: string, CMD in pairs(Server.Commands) do
		local WhitelistPerm = CMDs_With_Permissions[CMDName:lower()]
		if WhitelistPerm == nil then
			for _, ChatCommand in ipairs(CMD.Commands) do
				WhitelistPerm = CMDs_With_Permissions[ChatCommand:lower()]
				if WhitelistPerm ~= nil then break end
			end
		end
		
		if WhitelistPerm ~= nil then
			if WhitelistPerm then
				CMD.AdminLevel = WhitelistPerm
			end
		else
			CMD.AdminLevel = 900
		end
		
		-- Unhides some commands:
		for _, ChatCommand in ipairs(CMD.Commands) do
			if table.find(Commands_To_UnHide, ChatCommand) then
				CMD.Hidden = false
			end
		end
	end
end
