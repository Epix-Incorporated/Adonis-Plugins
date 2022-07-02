--!nonstrict
--[[
	Author: Sceleratis (Davey_Bones)
	Description: This plugin gives admin to every non-admin player who joins

	Place in a ModuleScript under Adonis_Loader > Config > Plugins, named "Server-Free_Admin"
--]]

local FREE_ADMIN_LEVEL: number = 100 --// Level of admin to give everyone; rank levels are defined in loader Settings
--// NOTE: Creator (level 900+) is EXTREMELY risky and not advised as they can do everything including change settings.

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Settings = server.Settings
	local Remote = server.Remote
	local Admin = server.Admin
	local Core = server.Core

	service.Events.PlayerAdded:Connect(function(p)
		task.wait(1)
		if not Admin.CheckAdmin(p) then
			Admin.SetLevel(p, FREE_ADMIN_LEVEL)
			Remote.MakeGui(p, "Notification", {
				Title = "Notification";
				Message = string.format("You are a(n) %s. Click to view commands.", Admin.LevelToListName(FREE_ADMIN_LEVEL));
				Time = 10;
				Icon = server.MatIcons.Verified;
				OnClick = Core.Bytecode("client.Remote.Send('ProcessCommand','"..Settings.Prefix.."cmds')");
			})
		end
	end)
end
