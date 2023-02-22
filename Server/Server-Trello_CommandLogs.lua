--!strict
---------
--[[ Information
	Original Author: Sceleratis/Davey_Bones
	Description: This plugin will log command executions to a list in the primary Trello board configured in Loader settings
	Variables:
		Server_Type: The type of the server Adonis is running on (Standard, Reserved, or Private)
		Ranks_To_Ignore_Commands: If a command is run with a certain AdminLevel, and that level is included in this array, the command will be ignored.
		Logging_List_Names: An array of string values that represents possible Trello list names where the plugin can create cards to log commands.
							If any of the list names in the array are found in the Trello board, the module will create Trello cards in the corresponding list to log commands.
		Commands_To_Ignore: An array of strings (commands) to ignore. Any command should be in lower-case and with its prefix.
------------------------------------------------------------------------------------------------------------------------------]]

local Server_Type = nil
local Ranks_To_Ignore_Commands: {string | number} = {"Players"}
local Logging_List_Names: {string} = {"Logs", "Admin Logs", "Command Logs", "Game Logs"}
local Commands_To_Ignore: {string} = {
	"!test"
}

local function GetServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerId ~= 0 then
			return "Private Server"
		else
			return "Reserved Server"
		end
	else
		return "Public Server"
	end
end

local function IsCommandFiltered(Data: any)
	if table.find(Ranks_To_Ignore_Commands, Data.Command.AdminLevel)
	or table.find(Commands_To_Ignore, string.lower(Data.Matched)) then
		return true
	end
	return false
end

return function(Vargs)
	
	Server_Type = GetServerType()
	local Server = Vargs.Server
	local Service = Vargs.Service

	local Settings = Server.Settings
	local HTTP = Server.HTTP

	while HTTP.Init ~= nil do
		task.wait()
	end

	local Trello = HTTP.Trello.API
	if not Trello then
		warn("Trello command logs plugin aborted; Ensure the Trello setup.")
		return
	end

	local LogList = Trello.getListObj(Trello.getLists(Settings.Trello_Primary), Logging_List_Names)
	if not LogList then
		warn("Trello command logs plugin aborted; Could not find a logging list on the Trello board")
		return
	end

	Service.Events.CommandRan:Connect(function(Player: Player, Data)
		if IsCommandFiltered(Data) then return end
		
		if Data.Error then
			Data.Error = "> **Error:** " .. Data.Error
		else
			Data.Error = ""
		end
		
		local CardTitle = tostring(Player)
		local CardDescription = string.format(
				[[
**Player:** %s
---

- **UserId:** %u
- **Command Log:**
> **Message:** %s
  **Command:** `%s`
  **Arguments:** %s
  **Successful:** %s
  %s

---

- **Server Information:**
> **Date:** %s
  **Time:** %s
  **Player Count:** %u
  **Server Type:** %s
]],
			Service.FormatPlayer(Player),
			Player.UserId,
			Data.Message,
			string.lower(Data.Matched),
			if Data.Args and #Data.Args > 0 then table.concat(Data.Args, ", ") else "None",
			(Data.Success and "True") or ("False"),
			Data.Error,
			os.date("%A, %b " .. (os.date("*t")::any).day .. ", %y")::string,
			os.date("%I:%M:%S %p [%Z]")::string,
			#Service.Players:GetPlayers(),
			Server_Type)
		Trello.makeCard(LogList.id, CardTitle, CardDescription)
	end)
end
