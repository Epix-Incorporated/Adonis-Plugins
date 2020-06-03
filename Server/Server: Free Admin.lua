--[[
  Place in a ModuleScript in Adonis_Loader > Config > Plugins
  ModuleScript must be named: "Server: Free Admin"    (without the quotes)
  
  Name: Free Admin
  Author: Sceleratis (Davey_Bones)
  Description: Gives every non-admin that joins admin
--]]

local adminLevel = 1 -- level of admin you want to give everyone; NOTE: Creator (level 4+) is extremely risky and not advised as they can do everything including change settings

--[[
  Admin Levels:
  
  Banned   -1
  Player    0
  Moderator 1
  Admin     2
  Owner     3   (Owners are basically SuperAdmins)
  Creator   4+  (Anything 4 or higher is considering game creator level and can do absolutely anything including edit settings in-game)
--]]

return function()
  service.Players.PlayerAdded:Connect(function(p)
    if not server.Admin.CheckAdmin(p) then
      server.Admin.SetLevel(p, adminLevel)
      --Admin.AddAdmin(v,1,true)
			Remote.MakeGui(v,"Notification",{
				Title = "Notification";
				Message = "You are an administrator. Click to view commands.";
				Time = 10;
				OnClick = Core.Bytecode("client.Remote.Send('ProcessCommand','"..Settings.Prefix.."cmds')");
			})
    end
  end)
end
