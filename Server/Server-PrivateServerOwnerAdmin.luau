--!strict
--[[
	Original Author: TacoBellSaucePackets
	Original Source: https://devforum.roblox.com/t/adonis-g-api-usage/477194/4
	Description: This plugin will give a certain temporary permission level to private server owners

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-PrivateServerOwnerAdmin"
--]]

--// HeadAdmins can do :permadmin, so it's unsafe to to make them head admins unless you change the perm levels for those commands or disable SaveAdmins in the settings
local PRIVATE_SERVER_OWNER_ADMIN_LEVEL: number = 200 --// (admin levels are defined in loader Settings)

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin

	--// If VIP Server is detected trigger code.
	if game.PrivateServerOwnerId ~= 0 then
		service.Events.PlayerAdded:Connect(function(plr: Player)
			if game.PrivateServerOwnerId == plr.UserId and PRIVATE_SERVER_OWNER_ADMIN_LEVEL > Admin.GetLevel(plr) then
				Admin.SetLevel(plr, PRIVATE_SERVER_OWNER_ADMIN_LEVEL)
			end
		end)
	end
end
