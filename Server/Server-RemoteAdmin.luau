--!nonstrict
--[[
	Author: EasternBloxxer
	Description: This plugin enables the setting of certain players' admin ranks via a BindableEvent

	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-RemoteAdmin"

	Usage:
		AdminRemote:Fire(player: Player, key: string, adminLevel: string | number, isTemporary: boolean?)
	Example:
		game.ServerStorage.AdminRemote:Fire(game.Players.EasternBloxxer, "secretkey", "Moderators", true)
	(must be executed on the Server; the Developer Console can be used)

	The BindableEvent is located under ServerStorage.

	* REMEMBER TO CONFIGURE THE KEY BELOW TO HELP KEEP YOUR GAME SAFE. *
--]]

local KEY: any = "!CHANGE_THIS!"
local BINDABLEEVENT_NAME: string = "AdminRemote"

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Admin = server.Admin

	if KEY == "!CHANGE_THIS!" then
		warn("WARNING: The RemoteAdmin key is not set! The plugin will not run.")
		return
	end

	local bindableEvent: BindableEvent = service.ServerStorage:FindFirstChild(BINDABLEEVENT_NAME)
				or service.New("BindableEvent", {Parent = service.ServerStorage, Name = BINDABLEEVENT_NAME})

	bindableEvent.Event:Connect(function(player: Player, key: any, adminLevel: string | number, isTemporary: boolean?)
		if not (type(player) == "Instance" and player:IsA("Player")) then
			warn("AdminRemote Error: Argument #1 expects a Player object")
			return
		end

		if key == KEY then
			Admin.AddAdmin(player, adminLevel, isTemporary)
			warn("AdminRemote: Set admin level of " .. player.Name .. " to " .. tostring(adminLevel))
		else
			warn("The maze wasn't meant for you.")
		end
	end)
end
