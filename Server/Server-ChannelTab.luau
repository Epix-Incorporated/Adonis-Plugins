--[[
	Author: WalkerOfBacon
	Name: Channel Tabs
	Description: This plugin will add an "Admins" channel tab and automatically remove unused team channel tabs.
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-ChannelTab"
--]]
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	local Remote = server.Remote
	local Admin = server.Admin
	
	local TextChatService: TextChatService = service.TextChatService
	
	if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
		warn("Game uses Legacy TextChatService! Specific chat features wont work!")
		return
	end
	
	if not TextChatService.ChannelTabsConfiguration.Enabled then
		warn("Game has channel tabs disabled! Specific chat features wont work!")
		return
	end
	
	local TextChannels = TextChatService and TextChatService:FindFirstChild("TextChannels")
	
	-- Workaround for tabs not disappearing once removed from it
	local function refreshChatWindow(plr: Player)
		Remote.LoadCode(plr, [[
		local TextChannels = game.TextChatService.TextChannels
		
		TextChannels.Parent = nil
		task.wait()
		TextChannels.Parent = game.TextChatService
		]])
	end
	
	local adminChannel = service.New("TextChannel", {
		Name = "Admins";
		Parent = TextChannels
	})
	
	-- Deletes the team channel tab once nobody is in the channel anymore
	TextChannels.ChildAdded:Connect(function(channel)
		if string.find(channel.Name, "RBXTeam")	~= 1 then return end
		
		repeat
			task.wait()
		until #channel:GetChildren() == 0
		
		channel:Destroy()
	end)
	
	service.HookEvent("PlayerAdded", function(plr: Player)
		if Admin.CheckAdmin(plr) then
			adminChannel:AddUserAsync(plr.UserId)
		end
		
		-- Handles whenever the player has their team changed
		local teamName
		plr:GetPropertyChangedSignal("Team"):Connect(function()
			if (not teamName and plr.Team) or 
				((teamName and plr.Team)
				and 
				teamName ~= plr.Team.Name)
			then
				teamName = plr.Team.Name
			end
			
			
			if not plr.Team then
				refreshChatWindow(plr)
				teamName = nil
			end
		end)
	end)
	
	local oldFunc = Admin.AddAdmin
	Admin.AddAdmin = function(p, level, temp)
		oldFunc(p, level, temp)
		adminChannel:AddUserAsync(p.UserId)
	end
	
	local oldFunc2 = Admin.RemoveAdmin
	Admin.RemoveAdmin = function(p, temp, override)
		oldFunc2(p, temp, override)
		local channel = TextChannels:WaitForChild("Admins")
		local plr = channel:FindFirstChild(p.Name)
		if channel and plr then
			plr:Destroy()
			refreshChatWindow(p)
		end
	end
end
