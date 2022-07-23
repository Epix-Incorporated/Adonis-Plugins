--!nonstrict
--[[  
	Name: Gear Blacklist
	Author: Sceleratis (Davey_Bones)
	Description: This plugins allows for the blacklisting of certain IDs from the :gear command

	Place in a ModuleScript under Adonis_Loader > Config > Plugins and name it "Server-Gear_Blacklist"
--]]

local BLACKLISTED_GEAR_IDS: {number} = { --// List of gear IDs to blacklist
	144950355,
	4842190633,
	4842207161
}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Settings = server.Settings
	local Variables = server.Variables
	local Commands = server.Commands
	local Remote = server.Remote

	local oldFunc = Commands.Gear and Commands.Gear.Function
	if not oldFunc then
		warn("The command definition and/or function for "..Settings.Prefix.."gear is missing")
		return
	end

	Commands.Gear.Function = function(plr: Player, args: {string}, ...)
		local gearId = assert(tonumber(args[1]), "Gear ID (argument #1) invalid or missing")
		if table.find(BLACKLISTED_GEAR_IDS, gearId) then
			local success, gearInfo = pcall(service.MarketplaceService.GetProductInfo, service.MarketplaceService, gearId)
			error(string.format("The gear %s is blacklisted", if success then '"'..gearInfo.Name..'"' else "of ID "..gearId))
		end
		return oldFunc(plr, args, ...)
	end
end
