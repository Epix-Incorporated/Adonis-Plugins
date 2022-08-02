--!strict
--[[
	Author: Sceleratis (Davey_Bones)
	Description: This plugin will remove certain commands

	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-Command_Remover"
--]]

local COMMANDS_TO_REMOVE: {string} = { --// List of command indices or names to remove
	"kill",
	"DonorHat",
	"fire"
}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin
	local Commands = server.Commands

	local count = 0

	for ind, cmd in pairs(Commands) do
		for _, v in ipairs(COMMANDS_TO_REMOVE) do
			if string.lower(v) == string.lower(ind) or table.find(cmd.Commands, string.lower(v)) then
				Commands[ind] = nil
				count += 1
				break
			end
		end
	end

	warn(string.format("Removed %d command%s from the Commands table", count, count == 1 and "" or "s"))

	Admin.CacheCommands()
end
