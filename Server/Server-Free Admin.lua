--[[
  Place in a ModuleScript in Adonis_Loader > Config > Plugins
  ModuleScript must be named: "Server: Free Admin"    (without the quotes)
  
  Name: Free Admin
  Author: Sceleratis (Davey_Bones)
  Description: Gives every non-admin that joins admin
--]]

local adminLevel = 100 -- level of admin you want to give everyone; NOTE: Creator (level 900+) is extremely risky and not advised as they can do everything including change settings

--[[
  Admin Levels:
  
  Banned   -1
  Player    0
  Moderator 100
  Admin     200
  Owner     300   (Owners are basically SuperAdmins)
  Creator   900+  (Anything 4 or higher is considering game creator level and can do absolutely anything including edit settings in-game)
--]]

server = nil;
service = nil;

return function()
	local Settings = server.Settings;
	local Remote = server.Remote;
	local Admin = server.Admin;
	local Core = server.Core;

	service.Players.PlayerAdded:Connect(function(p)
		wait(1)
  		if not Admin.CheckAdmin(p) then
      		Admin.SetLevel(p, adminLevel)
			--Admin.AddAdmin(v,1,true)
			Remote.MakeGui(p, "Notification", {
				Title = "Notification";
				Message = "You are an administrator. Click to view commands.";
				Time = 10;
				OnClick = Core.Bytecode("client.Remote.Send('ProcessCommand','"..Settings.Prefix.."cmds')");
			})
		end
	end)
end
