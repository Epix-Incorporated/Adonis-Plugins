--[[
	Author: Sceleratis/Davey_Bones
	Description: This plugin will restrict any PlayerFinders (all, others, me, etc) to a specific admin level only

	Place ModuleScript in Adonis_Loader > Config > Plugins and name it "Server-PlayerFinder Restrictor"
--]]


local RestrictToLevel = 100; --// Players must be level X or higher in the admin ranks
local ProtectedLevels = {900, 1000}; --// Levels that are always excluded from playerfinders listed below
local PlayerFinders = {  --// Player finders to restrict
  "all",
  "others",
  "nonadmins",
  "@everyone",
  "admins",
  "$group",
  "%team",
  "team-",
  "group-",
  "#number",
  "radius-"
}


return function()
  local Admin = server.Admin;
  local Functions = server.Functions;
  local Finders = Functions.PlayerFinders;

  for _, ind in next, PlayerFinders do
    local finder = Finders[ind];
    if finder then
      local oldFunc = finder.Function;
      finder.Function = function(msg, plr, par, players, ...)
        if Admin.GetLevel(plr) >= RestrictToLevel then
          oldFunc(msg, plr, par, players, ...);

          for i,p in ipairs(players) do
            for k,rank in ipairs(ProtectedLevels) do
              if Admin.GetLevel(p) == rank then
                table.remove(players, i)
              end
            end
          end
        end
      end
    end
  end
end
