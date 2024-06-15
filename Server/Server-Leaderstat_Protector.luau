--!nonstrict
--[[
	Author: Expertcoderz
	Description: Prevents certain leaderstat values from being changed by admins using :change, :add or :subtract

	Place this in a ModuleScript under Adonis_Loader > Config > Plugins and name it "Server-Leaderstat_Protector"
]]

type Permission = string|number|{string|number}

--// List of leaderstat names to protect:
local PROTECTED_LEADERSTAT_NAMES: {string} = {
	"Precious Money", "Time"
}

--// People with this admin level or rank can bypass leaderstat protection:
local OVERRIDE_PERMISSION: Permission? = 900

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin
	local Commands = server.Commands

	for _, ind in {"Change", "AddToStat", "SubtractFromStat"} do
		local cmd = Commands[ind]
		if cmd and cmd.Function then
			local oldFunc = cmd.Function
			cmd.Function = function(plr: Player, args: {string}, data)
				if not (OVERRIDE_PERMISSION and Admin.CheckComLevel(data.PlayerData.Level, OVERRIDE_PERMISSION)) then
					local statName = args[2]
					if statName then
						for _, protectedName in PROTECTED_LEADERSTAT_NAMES do
							assert(
								not string.match(protectedName:lower(), "^"..statName:lower()),
								"You do not have permission to change the leaderstat \""..protectedName..'"'
							)
						end
					end
				end
				return oldFunc(plr, args, data)
			end
		end
	end

	Admin.CacheCommands()
end
