--!nonstrict
--[[
	Author: Coasterteam
	Description: This plugin will modify the "Commands" value of a specific command.

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-Command_Alias_Changer" (as long as it starts with "Server-")
--]]

type Commands = {string}

--// Provide the overall commands you wish to change the list of commands of
--// [CMD_NAME_OR_INDEX] is the index of the command in the server.Commands list or each individual command itself, like :fly has the :flight and :flynoclip aliases alongside :fly. All three of these would work.

local COMMANDS_TO_CHANGE: {[string]: Commands} = {--[[
		[CMD_NAME_OR_INDEX] = {New Commands}
	]]
	fly = {"fly", "makemefly"};
	ban = {"ban", "begone"};
}

return function(Vargs)
  local server = Vargs.Server
	local service = Vargs.Service

	for ind, cmd in pairs(server.Commands) do
		local changeCommand = COMMANDS_TO_CHANGE[string.lower(ind)]
		if changeCommand == nil then
			for _, v in ipairs(cmd.Commands) do
				changeCommand = COMMANDS_TO_CHANGE[string.lower(v)]
				if changeCommand ~= nil then
					break
				end
			end
		end

		if changeCommand ~= nil then
			if changeCommand then
				cmd.Commands = changeCommand
			end
		end
	end

	server.Admin.CacheCommands()
end
