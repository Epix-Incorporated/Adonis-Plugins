return function(Vargs)
	local Server = Vargs.Server;
	local Service = Vargs.Service;

	-- Modules used

	local Variables = Server.Variables;
	local Commands = Server.Commands;
	local Admin = Server.Admin;
	local Core = Server.Core;
	local HTTP = Server.HTTP;
	local Settings = Server.Settings;
	local Functions = Server.Functions;
	local Logs = Server.Logs;
	local Remote = Server.Remote;

	-- Some vars
	local Prefix = Settings.Prefix;
	local DoCheck = Admin.DoCheck;
	local TrackTask = Service.TrackTask
	local AddLog = Logs.AddLog;
	local Routine = Server.Routine;
	
	Variables.OptedOutOfHelp = {};

	Commands.ToggleReports = {
		Prefix = Settings.Prefix;
		Commands = {"togglehelp"};
		Args = {};
		Description = "Toggle whatever or not you receive help requests from players";
		AdminLevel = "Moderators";
		Function = function(Player: Player, args: {string}, data: {})
			local State = table.find(Variables.OptedOutOfHelp,Player.UserId)

			if State then
				table.remove(Variables.OptedOutOfHelp, State)
			else 
				table.insert(Variables.OptedOutOfHelp, Player.UserId)
			end

			Functions.Hint(`You have opted {(State) and "in to receive" or "out of receiving"} help requests`,{Player},2)
		end
	};

	Commands.RequestHelp = {
		Prefix = Settings.PlayerPrefix;
		Commands = {"help", "requesthelp", "gethelp", "lifealert", "sos"};
		Args = {"reason"};
		Description = "Calls admins for help";
		Filter = true;
		AdminLevel = "Players";
		Function = function(plr: Player, args: {string})
			if Settings.HelpSystem == true then
				local num = 0
				local answered = false
				local pending = Variables.HelpRequests[plr.Name];
				local reason = args[1] or "No reason provided";

				if pending and os.time() - pending.Time < 30 then
					error("You can only send a help request once every 30 seconds.");
				elseif pending and pending.Pending then
					error("You already have a pending request")
				else
					Service.TrackTask(`Thread: {plr} Help Request Handler`, function()
						Functions.Hint("Request sent", {plr})

						pending = {
							Time = os.time();
							Pending = true;
							Reason = reason;
						}

						Variables.HelpRequests[plr.Name] = pending;

						for ind, p in Service.Players:GetPlayers() do
							Routine(function()
								if Admin.CheckAdmin(p) and not table.find(Variables.OptedOutOfHelp, p.UserId) then
									local ret = Remote.MakeGuiGet(p, "Notification", {
										Title = "Help Request";
										Message = `{plr.Name} needs help! Reason: {pending.Reason}`;
										Icon = Server.MatIcons.Mail;
										Time = 30;
										OnClick = Core.Bytecode("return true");
										OnClose = Core.Bytecode("return false");
										OnIgnore = Core.Bytecode("return false");
									})

									num += 1
									if ret then
										if not answered then
											answered = true
											Commands.Teleport.Function(plr, {p.Name, `@{plr.Name}`})
										else
											Functions.Notification("Help Request", "Another admin has already responded to this request!", {plr}, 5, "MatIcon://Mail")
										end
									end
								end
							end)
						end

						local w = os.time()
						repeat task.wait(0.5) until os.time()-w>30 or answered

						pending.Pending = false;

						if not answered then
							Functions.Message('HelpSystem', "Help System", "Sorry but no one is available to help you right now", 'MatIcon://Warning', {plr})
						end
					end)
				end
			else
				Functions.Message('HelpSystem', "Help System", "The help system has been disabled by the place owner.", 'MatIcon://Error', {plr})
			end
		end
	};

end;
