--!strict
----------
--[[ Info:
		A plugin to automatically assign commands' cooldown depending on its rank.
]]
---------------------------------------------------------------------------------------------|

local CooldownsByRank = {
	--| Format: [AdminLevel] = {Player = <Seconds>, Server = <Seconds>, CrossServer = <Seconds>}
	
	[0] = {
		Player = 5,
		Server = 0,
		CrossServer = 10,
	};
	
	[100] = {
		Player = 5,
		Server = 0,
		CrossServer = 25,
	};
	
	[200] = {
		Player = 5,
		Server = 0,
		CrossServer = 25,
	};
	
	[300] = {
		Player = 0,
		Server = 0,
		CrossServer = 5,
	};
}

return function (Vargs)
	local Server = Vargs.Server
	
	for CMDName: string, CMD in pairs(Server.Commands) do
		local CMDAdminLevel = CMD.AdminLevel
		
		if CooldownsByRank[CMDAdminLevel] then
			if CooldownsByRank[CMDAdminLevel].Player then
				CMD.PlayerCooldown = CooldownsByRank[CMDAdminLevel].Player
			end
			
			if CooldownsByRank[CMDAdminLevel].Server then
				CMD.ServerCooldown = CooldownsByRank[CMDAdminLevel].Server
			end
			
			if CooldownsByRank[CMDAdminLevel].CrossServer then
				CMD.CrossCooldown = CooldownsByRank[CMDAdminLevel].CrossServer
			end
		end
	end
end
