service = nil -- words cant explain how much i hate doing this
--[[
	Adonis Webhook Command Logs
	Author: crywink / Samuel#0440
--]]

-- Services
local HttpService = game:GetService("HttpService")

-- Variables
local Settings = {
	Webhook = "YOUR_WEBHOOK_LINK_HERE"; -- Replace with your webhook link. (MAKE SURE YOU KEEP THE QUOTES)
	RunForGuests = false; -- Set to true if you want guests (players without admin) commands to be logged.
	Ignore = {}; -- Commands you want ignored. Example: {":fly", ":speed"}
}

local function GetLevel(plr)
	local level = _G.Adonis.GetLevel(plr)
	
	if level > 0 then
		if level == 1 then
			return "Moderator"
		elseif level == 2 then
			return "Admin"
		elseif level == 3 then
			return "Owner"
		elseif level == 4 then
			return "Creator"
		elseif level == 5 then
			return "Place Owner"
		end
	end
end

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
	service.Events.CommandRan:Connect(function(plr, msg, cmd, args)
		if FindInArray(Settings.Ignore, cmd:lower()) then
			return
		end
		
		local Level = GetLevel(plr)
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
