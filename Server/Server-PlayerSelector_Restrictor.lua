--!strict
--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will restrict any player selectors (all, others, me, etc.) to a specific admin level only;
				 This plugin can also protect admins with certain levels from being selected using player selectors

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-PlayerFinder Restrictor"
--]]

type Permission = string|number|{string|number}

--// Players need this permission to use the player selectors:
local RESTRICT_TO_SPECIFIC_PERM: Permission? = 100 --// if nil, restrictions will apply to every player regardless of perms

--// Players with this permission can't be selected using player selectors:
local PROTECTION_PERM: Permission? = nil --// if nil, nobody will be protected

--// Players with this permission may use player selectors on protected levels nonetheless:
local PROTECTED_LEVELS_OVERRIDE_PERM: Permission? = 900 --// if nil, nobody will be allowed to override

--// Should unauthorized players will be shown an error when attempting to use a restricted selector or select a protected user?
local NOTIFY_OF_DENIALS: boolean = true

--// The player selectors to restrict:
local SELECTORS_TO_RESTRICT: {string} = {
	"all",
	"others",
	"nonadmins",
	"admins",
	"$group",
	"%team",
	"team-",
	"group-",
	"#number",
	"radius-"
}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin
	local Remote = server.Remote
	local Functions = server.Functions

	for _, ind in ipairs(SELECTORS_TO_RESTRICT) do
		local finder = Functions.PlayerFinders[ind]
		if not finder then
			continue
		end
		local oldFunc = finder.Function
		function finder.Function(msg, plr, par, players, ...)
			local plrLevel = Admin.GetLevel(plr)
			if not (RESTRICT_TO_SPECIFIC_PERM and Admin.CheckComLevel(plrLevel, RESTRICT_TO_SPECIFIC_PERM)) then
				if NOTIFY_OF_DENIALS then
					error(string.format("You are not allowed to use the player selector '%s'", ind))
				end
				return
			end
			oldFunc(msg, plr, par, players, ...)
			if not (PROTECTED_LEVELS_OVERRIDE_PERM and Admin.CheckComLevel(plrLevel, PROTECTED_LEVELS_OVERRIDE_PERM)) then
				local removedPlayerNames = {}
				for i, p in ipairs(players) do
					if PROTECTION_PERM and Admin.CheckComLevel(Admin.GetLevel(p), PROTECTION_PERM) then
						table.remove(players, i)
						table.insert(removedPlayerNames, service.FormatPlayer(p))
					end
				end
				local count = #removedPlayerNames
				if NOTIFY_OF_DENIALS and count > 0 then
					Functions.Hint(
						string.format(
							"%d player%s %s deselected due to protection: %s",
							count,
							count == 1 and "" or "s",
							count == 1 and "was" or "were",
							table.concat(removedPlayerNames, ", ")
						),
						{plr}
					)
				end
			end
		end
	end
end
