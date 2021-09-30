--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will remove commands in the RemoveList tables below.
	
	Place ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-Command Remover"
--]]

server = nil

return function()
	local prefix = server.Settings.Prefix; 			--// By default this is ":" and is used for most commands
	local sPrefix = server.Settings.PlayerPrefix; 	--// By default this is "!" and is used for Player commands

	--// Finds commands that match below (as they would be chatted in-game)
	local RemoveList_WithPrefix = {
		prefix .. "kill"; --// :kill
		sPrefix .. "hat"; --// !hat
	}

	--// Finds commands listed below, regardless of their prefix. Adding "hat" to this table would remove both !hat and :hat (even tho they aren't the same command)
	--// You can use this one if you don't know which prefix is used by the target command.
	local RemoveList_NoPrefix = {
		"fire"; --// !fire (Donors) and :fire <player> (Admins)
	}

	local function checkAlias_Prefix(cmd, match)
		for _, v in pairs(cmd.Commands) do
			if string.lower(cmd.Prefix .. v) == string.lower(match) then
				return true;
			end
		end

		return false;
	end

	local function checkAlias_NoPrefix(cmd, match)
		for _, v in pairs(cmd.Commands) do
			if string.lower(v) == string.lower(match) then
				return true;
			end
		end

		return false;
	end

	local function checkList(cmd)
		for _, v in ipairs(RemoveList_WithPrefix) do 
			if checkAlias_Prefix(cmd, v) then
				return true;
			end
		end

		for _, v in ipairs(RemoveList_NoPrefix) do 
			if checkAlias_NoPrefix(cmd, v) then
				return true;
			end
		end

		return false;
	end

	for key, com in pairs(server.Commands) do
		if checkList(com) then
			server.Commands[key] = nil;
			warn("Removed ".. tostring(key) .." from commands table");
		end
	end

	server.Admin.CacheCommands();
end
