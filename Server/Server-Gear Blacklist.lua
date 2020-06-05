--[[
  Place in Adonis_Loader > Config > Plugins
  ModuleScript NAME MUST START WITH Server: or Server-
  OLD LOADERS MUST USE "Server: " (with the space after : but without the quotes)
  
  Name: Gear Blacklist
  Author: Sceleratis (Davey_Bones)
  Description: Replaces the original :gear command with one that supports blacklisting certain IDs
--]]

local GearID_Blacklist = {}; -- Add the asset id of gears you want to blacklist to this table

local function check(id)
  for i,v in next,GearID_Blacklist do
    if tonumber(v) == tonumber(id) then
      return false
    end
  end
  
  return id
end

return function()
  server.Commands.Gear = {
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
				if gear and gear:IsA("Tool") or gear:IsA("HopperBin") then 
					service.New("StringValue",gear).Name = Variables.CodeName..gear.Name 
					for i, v in pairs(service.GetPlayers(plr,args[1])) do
						if v:findFirstChild("Backpack") then
							gear:Clone().Parent = v.Backpack 
						end
					end
				end
			end
		};
end
