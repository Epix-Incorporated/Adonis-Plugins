--// In Adonis_Loader > Config > Plugins > Server: GiveServerOwnerAdmin
--// Author: TacoBellSaucePackets
--// Source: https://devforum.roblox.com/t/adonis-g-api-usage/477194/4

--// Owners can do :permadmin, so it's unsafe to to make them owners unless you change the perm levels for those commands or disable SaveAdmins in the settings
local AdminLevel = 200; --// 100 - Mod, 200 - Admin, 300 - HeadAdmin

return function()
	service.Players.PlayerAdded:Connect(function(p)
		if game.PrivateServerOwnerId == p.UserId then
			server.Admin.SetLevel(p, AdminLevel)
		end
	end)
end
