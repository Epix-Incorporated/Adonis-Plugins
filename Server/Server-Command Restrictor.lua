server = nil
return function()
	--// This plugin will whitelist certain commands for use, and set the rest as creators only
	--// Command indexes to not restrict go into the whitelist table below
	--// If the value is false, it will use the command's original AdminLevel
	--// If the value is set to a string it will use that as the new AdminLevel
	--// Any commands not in the below table will be set as Creators only
	
	local whitelist = {
		To = false;
		Bring = false;
		Teleport = false;
		ResetView = false;
		Message = false;
		Notif = false;
		Hint = false;
		Notify = false;
		Notification = false;
		HintCountdown = false;
		PrivateMessage = false;
		Shutdown = "Owners";
		Invisible = "Admins";
		Respawn = "Admins";
		Visible = "Admins";
		Shirt = "Admins";
		Pants = "Admins";
		Kick = "Admins";
		Ban = "Owners";
		View = "Owners";
	}
	
	for index,com in next,server.Commands do
		if whitelist[index] ~= nil then
			if whitelist[index] then
				com.AdminLevel = whitelist[index]
			end
		else
			com.AdminLevel = "Creators"
		end
	end
end