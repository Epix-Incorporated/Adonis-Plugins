--[[
  Place in a ModuleScript under Adonis_Loader > Config > Plugins
  ModuleScript must be named: "Server: Free Admin"    (without the quotes)
  
  Name: Free Admin
  Author: Sceleratis (Davey_Bones)
  Description: Gives admin to every non-admin player that joins
--]]

local adminLevel = 100 -- level of admin you want to give everyone; NOTE: Creator (level 900+) is EXTREMELY risky and not advised as they can do everything including change settings

--[[
  Default Admin Levels:
  
  Banned   -1
  Player    0     (Non-admins - These players are not considered admins)
  Moderator 100
  Admin     200
  HeadAdmin 300   (HeadAdmins are basically SuperAdmins)
  Creator   900+  (Anything 900 or higher is considering game creator level and can do absolutely anything including edit settings in-game)
  
  Note: This will also work for custom ranks if you specify their level.
--]]

server, service = nil, nil

return function()
	local Settings = server.Settings
	local Remote = server.Remote
	local Admin = server.Admin
	local Core = server.Core

	service.Players.PlayerAdded:Connect(function(p)
		task.wait(1)
		if not Admin.CheckAdmin(p) then
			Admin.SetLevel(p, adminLevel)
			--Admin.AddAdmin(v, 1, true)
			Remote.MakeGui(p, "Notification", {
				Title = "Notification";
				Message = "You are a(n)"..Admin.LevelToListName(adminLevel)..". Click to view commands.";
				Time = 10;
				Icon = server.MatIcons.Verified;
				OnClick = Core.Bytecode("client.Remote.Send('ProcessCommand','"..Settings.Prefix.."cmds')");
			})
		end
	end)
end
