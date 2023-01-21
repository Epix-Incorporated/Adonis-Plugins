--!nonstrict
--[[
	Author: joritochip
	Name: Disable oldlogs
	Description: This plugin allows you to fully disable Adonis old logs
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-DisableOldlogs"
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.OldLogs = nil 
	
	-- The code below this will COMPLETELY remove the OldCommandLogs functionality and it will stop saving old logs entirely. 
	-- Delete from here to the line if you just want the command disabled.
	server.Logs.ListUpdaters.OldCommandLogs = function()
		return {};
	end
	server.Logs.SaveCommandLogs = function() end
	--------------------------------------------------------------------
end
