--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will remove commands in the RemoveList tables below.
	
	Place ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-Command Remover"
--]]

server = nil

return function()
	local prefix = server.Settings.Prefix;
	local sPrefix = server.Settings.PlayerPrefix;
	
	--// Finds commands that match below (as they would be chatted in-game)
	local RemoveList_WithPrefix = {
		prefix .. "kill"; --// :kill
		sPrefix .. "hat"; --// !hat
	}
	
	--// Finds commands listed below, regardless of their prefix. Added "hat" to this table would remove both !hat and :hat (even tho they aren't the same command)
	--// You can use this one if you don't know which prefix is used by the target command.
	local RemoveList_NoPrefix = {
		"fire"; --// !fire (Donors) and :fire <player> (Admins)
	}
	
	local function checkAlias_Prefix(cmd, match)
		for i,v in next,cmd.Commands do
			if (cmd.Prefix .. v):lower() == match:lower() then
				return true;
			end
		end
		
		return false;
	end
	
	local function checkAlias_NoPrefix(cmd, match)
		for i,v in next,cmd.Commands do
			if v:lower() == match:lower() then
				return true;
			end
		end

		return false;
	end
	
	local function checkList(cmd)
		for i,v in next, RemoveList_WithPrefix do 
			if checkAlias_Prefix(cmd, v) then
				return true;
			end
		end
		
		for i,v in next, RemoveList_NoPrefix do 
			if checkAlias_NoPrefix(cmd, v) then
				return true;
			end
		end
		
		return false;
	end
	
	for index,com in next,server.Commands do
		if checkList(com) then
			server.Commands[index] = nil;
			warn("Removed ".. tostring(index) .." from commands table");
		end
	end
end