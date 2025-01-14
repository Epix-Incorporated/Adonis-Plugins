--!strict
--[[
	Author: Sceleratis/Davey_Bones and Expertcoderz
	Description: This plugin will restrict any player selectors
				 (all, others, me, etc.) to a specific admin level only.
				 This plugin can also protect admins with certain
				 levels from being selected using player selectors.

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-PlayerFinder Restrictor"
--]]

--// Permissions can be specified by rank number, rank name,
--// or even a list of rank number and/or rank names.
type Permission = string|number|{string|number}

--[[
	RESTRICTION vs. PROTECTION:
		Restriction:	prevent player selectors from being used by
						everyone without RESTRICTION_OVERRIDE_PERM
		Protection:		prevent player selectors from selecting those
						in PROTECTION_ELIGIBLE_PERM unless used by
						admins with PROTECTION_OVERRIDE_PERM

	If someone attempts to use a restricted player selector without
	RESTRICTION_OVERRIDE_PERM, they will get denied immediately from
	running the command. If they use an unrestricted player selector
	that happens to select a protected player, the command may still
	have effect on the other selected players that are non-protected.
]]

--// Players need this permission to use the player selectors:
--// (if nil, equivalent to nobody, i.e. restrict everyone)
--// (if 0, equivalent to everyone, i.e. disable restriction)
local RESTRICTION_OVERRIDE_PERM: Permission? = 300

--// Players with this permission can't be selected using player selectors:
--// (if nil, equivalent to nobody, i.e. disable protection)
--// (if 0, equivalent to everyone, i.e. make player selectors useless)
local PROTECTION_ELIGIBLE_PERM: Permission? = 900

--// Players with this permission may use player selectors on protected levels nonetheless:
--// (if nil, nobody will be allowed to override)
local PROTECTION_OVERRIDE_PERM: Permission? = 900

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
	"radius-",
}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin
	local Remote = server.Remote
	local Functions = server.Functions

	for _, ind in SELECTORS_TO_RESTRICT do
		local finder = Functions.PlayerFinders[ind]
		if not finder then
			warn("Nonexistent player selector:", ind)
			continue
		end

		local oldFunc = finder.Function
		function finder.Function(msg, plr, par, players, ...)
			local plrLevel = Admin.GetLevel(plr)

			assert(
				RESTRICTION_OVERRIDE_PERM
					and Admin.CheckComLevel(plrLevel, RESTRICTION_OVERRIDE_PERM),
				`You are not allowed to use the player selector '{ind}'`
			)

			oldFunc(msg, plr, par, players, ...)

			if not PROTECTION_ELIGIBLE_PERM
				or (PROTECTION_OVERRIDE_PERM and
					Admin.CheckComLevel(plrLevel, PROTECTION_OVERRIDE_PERM))
			then
				return
			end

			local removedPlayerNames = {}
			for i, selectedPlayer in players do
				if Admin.CheckComLevel(
					Admin.GetLevel(selectedPlayer), PROTECTION_ELIGIBLE_PERM
					)
				then
					table.remove(players, i)
					table.insert(removedPlayerNames, service.FormatPlayer(selectedPlayer))
				end
			end

			local count = #removedPlayerNames
			if count > 0 then
				Functions.Hint(
					`{count} player(s) were deselected due to protection: {table.concat(
						removedPlayerNames, ", "
					)}`,
					{plr}
				)
			end
		end
	end
end
