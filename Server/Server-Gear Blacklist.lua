--[[
  Place in Adonis_Loader > Config > Plugins
  ModuleScript NAME MUST BE Server: Gear Blacklist
  
  Name: Gear Blacklist
  Author: Sceleratis (Davey_Bones)
  Description: Replaces the original :gear command with one that supports blacklisting certain IDs
--]]

local GearID_Blacklist = {144950355, 4842190633, 4842207161}; -- Add the asset id of gears you want to blacklist to this table
--[[
"4842212980", "4842215723", "4842197274", "4842218829", "4842201032", "4842207161", "4842190633", "144950355"
--]]
local function check(id)
  for i,v in next,GearID_Blacklist do
    if tonumber(v) == tonumber(id) then
      return nil
    end
  end
  
  return id
end

local server = nil;
local service = nil;

return function()
	local Settings = server.Settings;
	local Variables = server.Variables;
	local Remote = server.Remote;
	local Commands = server.Commands;
	
 	Commands.Gear = {
		Prefix = Settings.Prefix;
		Commands = {"gear";"givegear";};
		Args = {"player";"id";};
		Hidden = false;
		Description = "Gives the target player(s) a gear from the catalog based on the ID you supply";
		Fun = true;
		AdminLevel = "Moderators";
		Function = function(plr,args)
	        local id = check(tonumber(args[2]))
			local gear = id and service.Insert(id)
			if id and gear and (gear:IsA("Tool") or gear:IsA("HopperBin")) then 
				service.New("StringValue",gear).Name = Variables.CodeName..gear.Name 
				for i, v in next,service.GetPlayers(plr,args[1]) do
					if v:FindFirstChild("Backpack") then
						gear:Clone().Parent = v.Backpack 
					end
				end
			else
				Remote.MakeGui(plr,"Notification",{
					Title = "Notification";
					Message = "Gear Blocked or Invalid";
					Time = 10;
				})
			end
		end
	};
end