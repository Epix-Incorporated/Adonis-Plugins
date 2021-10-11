server = nil
return function()
	--// This plugin will whitelist certain commands for use, and set the rest as creators only
	--// Command indexes to not restrict go into the whitelist table below
	--// If the value is false, it will use the command's original AdminLevel
	--// If the value is set to a string it will use that as the new AdminLevel
	--// Any commands not in the below table will be set as Creators (Level 900) only
	--// You should be able to use either the command index or one of the command's "Commands" strings

	local commands = { --// Command string or index
		Shutdown = "HeadAdmins";
		Invisible = "HeadAdmins";
		Respawn = "Admins";
		Visible = "HeadAdmins";
		Shirt = "HeadAdmins";
		Pants = "HeadAdmins";
		Kick = "Moderators";
		Ban = "Admins";
		View = "Moderators";
		chat = "Admins";
		unchat = "Admins";
		N = "Admins";
		Clean = "Moderators";
		Jump = "Moderators";
		Tban = "Admins";
		Mpm = "Moderators";
		Admins = "Moderators"; 
		Untimeban = "Admins";
		Team = "Moderators";
		Joinlogs = "Moderators";
		Pnum = "Moderators";
		notepad = "Moderators";
		Note = "Moderators";
		Hcountdown = "Admins";
		Stopcountdown = "Admins";
		Bring = "Moderators";
		mutelist = "Moderators";
		Refresh = "Moderators";
		m = "Admins";
		Setmessage = "Admins";
		To = "Moderators";
		gear = "Admins";
		notes = "Moderators";
		removenotes = "Moderators";
		countdown = "Admins";
		view = "Moderators";
		players = "Moderators";
		flynoclip = "Admins";
		notify = "Admins";
		details = "Moderators";
		gameban = "Admins";
		clip = "Admins";
		bchat = "Admins";
		unname = "Admins";
		kill = "Admins";
		track = "Moderators";
		logs = "Moderators";
		mute = "Moderators";
		ungameban = "Admins";
		respawn = "Moderators";
		chatlogs = "Moderators";
		info = "Moderators";
		showlogs = "Moderators";
		clear = "Moderators";
		tp = "Moderators";
		quote = "Moderators";
		to = "Moderators";
		noclip = "Admins";
		fly = "Admins"; 
		unfly = "Admins";
		cmds = "Moderators";
		exploitlogs = "Moderators";
		cmdbox = "Moderators";
		kick = "Moderators";
		ban = "Admins";
		name = "Admins";
		Chatnotify = "Moderators";
		warnings = "Moderators";
		timebanlist = "Moderators";
		banlist = "Moderators";
	}


	local whitelist = {} --// Add ONLY the command indecies to this (if you need to target a specific index)

	local function getIndex(str)
		for key, cmd in pairs(server.Commands) do
			for _, c in pairs(cmd.Commands) do
				if string.lower(c) == string.lower(str) then
					return key
				end
			end
		end
	end

	for k, v in pairs(commands) do
		local found = (server.Commands[k] and k) or getIndex(k)
		
		if found then
			whitelist[found] = v
		end
	end

	for key, com in pairs(server.Commands) do
		local newLevel = whitelist[key];
		if whitelist[key] ~= nil then
			com.AdminLevel = ((type(newLevel) == "string" or type(newLevel) == "number" or type(newLevel) == "table") and newLevel) or com.AdminLevel
		else
			com.AdminLevel = 900
		end
	end
end
