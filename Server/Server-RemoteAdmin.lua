--[==[
        RemoteAdmin.lua
        =====================================================
        Last updated on           December 27, 2022
        Created on                October 11, 2022
        Author(Astra Credits)     EasternBloxxer ~ Engineering the future.
        Type                      Module (Astra Plugin)
        Description               Handles setting admin ranks of players using BindableEvents.
        
        Documentation:
        pretty much just
        AdminRemote:Fire(player:player object, key: string, level: string, temporary:bool)
        
      
       !!! DO NOT FORGET TO CHANGE THE KEY IN CONFIG BELOW !!!
        The key is required to keep your game safe.
        
        Suggestions or issues? 
        https://github.com/Astra-Corporation/Astra-Support/issues/new/choose exists for a reason. Use it.
        or contact me in Discord EasternBloxxer#6252
]==]--
Config = {
	Key = "CHANGE_THIS"
}
server = nil
service = nil
cPcall = nil
Pcall = nil
Routine = nil
GetEnv = nil
logError = nil
sortedPairs = nil
return function(Vargs)
	local server = Vargs.Server;
	local service = Vargs.Service;

	local Settings = server.Settings
	local Functions, Commands, Admin, Anti, Core, HTTP, Logs, Remote, Process, Variables, Deps =
		server.Functions, server.Commands, server.Admin, server.Anti, server.Core, server.HTTP, server.Logs, server.Remote, server.Process, server.Variables, server.Deps

	local Verbose = false  --// ENABLE FOR DEBUGGING 
	local debug = function(...)
		if Verbose then
			warn("Debug ::", ...)
		end
	end
	local debugLine = function()
		if Verbose then
			debug("=======================================================")
		end

	end

	local BindableEvent = nil

	if not game:GetService('ReplicatedStorage'):FindFirstChild('AdminRemote') then
		debug("Did not find remote so we are creating one")
		BindableEvent = Instance.new('BindableEvent')
		BindableEvent.Name = "AdminRemote"
		BindableEvent.Parent = game:GetService('ReplicatedStorage')
		debug("Set AdminRemote")
	elseif game:GetService('ReplicatedStorage'):FindFirstChild('AdminRemote') then
		debug('AdminRemote already existed at '..game:GetService('ReplicatedStorage'):FindFirstChild('AdminRemote'):GetFullName()..'(?) its been set to that.')
		BindableEvent = game:GetService('ReplicatedStorage'):FindFirstChild('AdminRemote')
	end
	if Config.Key == "CHANGE_THIS" then
		warn('RemoteAdmin key is not set! For security reasons the plugin will not function.')
	end

	BindableEvent.Event:Connect(function(player:Player, key:string, level:string, temp:boolean)
		if Config.Key == "CHANGE_THIS" then 
			return warn('RemoteAdmin key is not set! For security reasons any events will be dropped.')
		else
			if key and key == Config.Key then
				debug('got the key!')
				--//TODO: add some more checks!
				Admin.AddAdmin(player,level,temp)
				warn(tostring(player.Name).."'s admin level has been set to " .. tostring(level) .." temporary? "..tostring(temp))
			else
				debug('Did not get a valid key.')
				warn("The maze wasn't meant for you.")
			end
		end

	end)
	Logs:AddLog("Script", tostring(script.Name).." Plugin Initialized")
end
