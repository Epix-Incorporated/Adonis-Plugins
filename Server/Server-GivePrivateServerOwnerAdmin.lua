--// In Adonis_Loader > Config > Plugins > Server: GiveServerOwnerAdmin
--// Author: TacoBellSaucePackets
--// Source: https://devforum.roblox.com/t/adonis-g-api-usage/477194/4

local AdminLevel = 3; --// 1 - Mod, 2 - Admin, 3 - Owner

return function()
  service.Players.PlayerAdded:Connect(function(p)
    if game.PrivateServerOwnerId == p.UserId then
        server.Admin.SetLevel(p, AdminLevel)
    end
  end)
end
