--!nonstrict
--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will log command executions to a list in the primary Trello board configured in Loader settings

	Place this ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-Trello_CommandLogs"
--]]

local LOG_LIST_NAMES: {string} = {"Logs", "Admin Logs", "Command Logs"}

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local Settings = server.Settings
	local HTTP = server.HTTP

	local trello = HTTP.Trello.API
	if not trello then
		warn("ABORING; NO TRELLO SETUP? MAKE SURE YOU HAVE CORRECT SETTINGS AND THEY ARE NOT ERRORING.")
		return
	end

	local logList = trello.getListObj(trello.getLists(Settings.Trello_Primary), LOG_LIST_NAMES)
	if not logList then
		warn("TRELLO COMMAND LOGS PLUGIN ABORTED; LOG LIST NOT FOUND ON TRELLO BOARD")
		return
	end

	service.Events.CommandRan:Connect(function(plr: Player, data)
		trello.makeCard(
			logList.id,
			tostring(plr)..": "..data.Message,
			string.format(
			[[--------------------------------------------
Player: %s
Message: %s

Command: %s
Args: %s

Time: %s
Successful: %s
Error: %s
--------------------------------------------]],
				service.FormatPlayer(plr),
				tostring(data.Message),
				tostring(data.Matched),
				if data.Args and #data.Args > 0 then table.concat(data.Args, ", ") else "-",
				tostring(service.GetTime()),
				tostring(data.Success),
				tostring(data.Error or "No error found.")
			))
	end)
end
