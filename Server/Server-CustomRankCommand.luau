return function(Vargs)
    local server, service = Vargs.Server, Vargs.Service

    local Settings = server.Settings
    local Commands = server.Commands
    local Functions = server.Functions
    local Admin = server.Admin

    Commands.VIP = {
            Prefix = Settings.Prefix;
            Commands = {"vip"};
            Args = {"player/user"};
            Description = "Makes the target player(s) a VIP; saves";
            AdminLevel = "Admins";
            Function = function(plr: Player, args: {string}, data: {any})
                local senderLevel = data.PlayerData.Level

                for _, v in service.GetPlayers(plr, assert(args[1], "Missing target player (argument #1)"), {
                    UseFakePlayer = true;
                    })
                do
                if senderLevel > Admin.GetLevel(v) then
                    Admin.AddAdmin(v, "VIP")
                    Functions.Hint(`{service.FormatPlayer(v, true)} is now a VIP`, {plr})
                else
                    Functions.Hint(`{service.FormatPlayer(v, true)} is already the same admin level as you or higher`, {plr})
                end
            end
        end}
    Admin.CacheCommands()
end
