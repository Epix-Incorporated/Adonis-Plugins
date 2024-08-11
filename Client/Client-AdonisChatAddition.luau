--[==[
	File: Client-AdonisChatAddition.lua
	Author: Coasterteam
	Description: This is a client dep. that makes it so removing custom chat works properly
	
	Last Updated: August 11th, 2024
	Version: 1.0
]==]

return function(Vargs)
	local client, service = Vargs.Client, Vargs.Service

	client.UI.Remove = function(name, ignore)
		if name == "Chat" and client.Handlers.RemoveCustomChat then
			client.Handlers.RemoveCustomChat()
		else
			local gui = client.UI.Get(name, ignore)
			if gui then
				for i,v in gui do
					v.Destroy()
				end
			end
		end
	end
end
