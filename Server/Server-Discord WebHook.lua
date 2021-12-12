service = nil -- words cant explain how much i hate doing this
--[[
	Adonis Webhook Command Logs
	Author: crywink / Samuel#0440
	Notice: Discord has blocked Roblox from sending out requests. You are required to use a proxy for your webhook to work.
		Try this DevForum post: https://devforum.roblox.com/t/discord-webhook-proxy/1500688
		-GalacticInspired
--]]

-- Services
local HttpService = game:GetService("HttpService")

-- Variables
local Settings = {
	Webhook = "YOUR_WEBHOOK_LINK_HERE"; -- Replace with your webhook link. (MAKE SURE YOU KEEP THE QUOTES)
	RunForGuests = false; -- Set to true if you want guests (players without admin) commands to be logged.
	Ignore = {}; -- Commands you want ignored. Example: {":fly", ":speed"}
}

local function FindInArray(arr, obj)
	for i = 1, #arr do
		if arr[i] == obj then
			return i
		end
	end
	return nil
end

-- Module
return function()
	service.Events.CommandRan:Connect(function(plr, data)
		local msg = data.Message;
		local cmd = data.Matched;
		local args = data.Args;

		if FindInArray(Settings.Ignore, string.lower(cmd)) then
			return
		end

		local pLevel = data.PlayerData.Level
		local Level = server.Admin.LevelToListName(pLevel)
		if Level or (not Level and Settings.RunForGuests) then
			HttpService:PostAsync(Settings.Webhook, HttpService:JSONEncode({
				embeds = {{
					title = "Command Logs";
					description = "**Player:** " .. plr.Name .. "\n**Admin Level:** " .. (Level or "Guest") .. "\n**Command:** " .. msg;
					color = 8376188;
				}}
			}))
		end
	end)
end
