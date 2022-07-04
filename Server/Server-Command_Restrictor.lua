--!strict
--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will whitelist only certain commands for use, and set the rest as Creators-only

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-Command_Restrictor"
--]]

type Permission = string|number|{string|number}

--// Command indexes to not restrict go into the whitelist table below
--// If the value is false, it will use the command's original (default) AdminLevel
--// If the value is set to a Permission type (rank name or level), it will use that as the new AdminLevel
--// Any commands not in the below table will be set as Creators (Level 900+) only

local WHITELISTED_COMMAND_PERMS: {[string]: Permission} = {--[[
		[CMD_NAME_OR_INDEX] = ADMIN_RANK_NAME | ADMIN_LEVEL | {ADMIN_RANK_NAME | ADMIN_LEVEL}
	]]
	Shutdown = "HeadAdmins",
	Invisible = "HeadAdmins",
	Respawn = "Admins",
	Visible = "HeadAdmins",
	Shirt = "HeadAdmins",
	Pants = "HeadAdmins",
	Kick = "Moderators",
	Ban = "Admins",
	View = "Moderators",
	chat = "Admins",
	unchat = "Admins",
	N = "Admins",
	Clean = "Moderators",
	Jump = "Moderators",
	Tban = "Admins",
	Mpm = "Moderators",
	Admins = "Moderators",
	Untimeban = "Admins",
	Team = "Moderators",
	Joinlogs = "Moderators",
	Pnum = "Moderators",
	notepad = "Moderators",
	Note = "Moderators",
	Hcountdown = "Admins",
	Stopcountdown = "Admins",
	Bring = "Moderators",
	mutelist = "Moderators",
	Refresh = "Moderators",
	m = "Admins",
	Setmessage = "Admins",
	To = "Moderators",
	gear = "Admins",
	notes = "Moderators",
	removenotes = "Moderators",
	countdown = "Admins",
	view = "Moderators",
	players = "Moderators",
	flynoclip = "Admins",
	notify = "Admins",
	details = "Moderators",
	gameban = "Admins",
	clip = "Admins",
	bchat = "Admins",
	unname = "Admins",
	kill = "Admins",
	track = "Moderators",
	logs = "Moderators",
	mute = "Moderators",
	ungameban = "Admins",
	respawn = "Moderators",
	chatlogs = "Moderators",
	info = "Moderators",
	showlogs = "Moderators",
	clear = "Moderators",
	tp = "Moderators",
	quote = "Moderators",
	to = "Moderators",
	noclip = "Admins",
	fly = "Admins",
	unfly = "Admins",
	cmds = "Moderators",
	exploitlogs = "Moderators",
	cmdbox = "Moderators",
	kick = "Moderators",
	ban = "Admins",
	name = "Admins",
	Chatnotify = "Moderators",
	warnings = "Moderators",
	timebanlist = "Moderators",
	banlist = "Moderators",
}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	for ind, cmd in pairs(server.Commands) do
		local whitelistPerm = WHITELISTED_COMMAND_PERMS[ind:lower()]
		if whitelistPerm == nil then
			for _, v in ipairs(cmd.Commands) do
				whitelistPerm = WHITELISTED_COMMAND_PERMS[v:lower()]
				if whitelistPerm ~= nil then
					break
				end
			end
		end
		if whitelistPerm ~= nil then
			if whitelistPerm then
				cmd.AdminLevel = whitelistPerm
			end
		else
			cmd.AdminLevel = 900
		end
	end
end
