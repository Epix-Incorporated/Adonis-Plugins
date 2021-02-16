--// Btw, the kick message for this plugin supports Engligh and Portugese.

server = nil
service = nil

KickMessage = "PTS Violation \n Violação PTS"
PenalizeAdmins = false

Action = "PM"
PTSMute = {}
PTSGrant = {}	
PTSRequests = {}
PTSViolations = {}
PTSVWindow = {}
PTSMWindow = {}
PTSRWindow = {}
CurrentPlayers = {}
PTSEnabled = false
ee = false
er = false
es = false
et = false

return function()
	server.Commands.PTS = {
		Prefix = server.Settings.Prefix;
		Commands = {"pts"};	
		Args = {"method","optional argument"};
		Description = "Permission to Speak System";
		Hidden = false;
		Fun = false;
		AdminLevel = "Players";
		Function = function(plr,args)

			--DO NOT TOUCH ANYTHING BELOW UNLESS YOU WHAT YOUR DOING



			local pref = server.Settings.Prefix
			local actions = {"notify","kick","ban","mute","kill","smite"}
			local phrases = {pref.."pts request",pref.."pts",pref.."pts request ",pref.."pts ", pref.."pts help",pref.."pts help "}


			local NonAdminOpen = {
				{Text=pref.."pts open",Desc="Opens this menu"};
				{Text=pref.."pts request",Desc="Sends a PTS Request"};
			}
			local AdminOpen = {		
				{Text=pref.."pts help",Desc="Opens this menu"};
				{Text=pref.."pts request",Desc="Sends a PTS Request"};
				{Text=pref.."pts enable",Desc="Enable's PTS"};
				{Text=pref.."pts disable",Desc="Disable's PTS"};
				{Text=pref.."pts setaction",Desc="Sets the Action Taken When PTS is Violated (notify, ban, kick, mute, smite, kill) (Default is notify)"};
				{Text=pref.."pts mute",Desc="Mutes a Player's PTS"};
				{Text=pref.."pts unmute",Desc="Unmutes a Player's PTS"};
				{Text=pref.."pts grant",Desc="Grant's a Player's PTS Request / Exempt's a Player from PTS"};
				{Text=pref.."pts revoke",Desc="Revoke's a Players PTS"};
				{Text=pref.."pts deny",Desc="Denies a Player's PTS Request"};
				{Text=pref.."pts violators",Desc="Shows a list of Violators"};
				{Text=pref.."pts muted",Desc="Shows a list of Players with Muted PTS"};
				{Text=pref.."pts requests",Desc="Shows a list of PTS Requests"};
			}



			local function Violation(plr)
				table.insert(PTSViolations, 1, plr.Name)
				server.Admin.RunCommand(server.Settings.Prefix.."notify admins "..plr.Name.." violated PTS")
				if Action == "notify" then
					wait(0.5)
					server.Admin.RunCommand(server.Settings.Prefix.."notify "..plr.Name.." PTS Violation Detected. Next Time, Run: "..server.Settings.Prefix.."pts request")
				elseif Action == "ban" then
					server.Admin.AddBan(plr, false)
				elseif Action == "kick" then
					service.Players:FindFirstChild(plr.Name):Kick(KickMessage)
				elseif Action == "mute" then
					server.Admin.RunCommand(server.Settings.Prefix.."notify "..plr.Name.." PTS Violation Detected. To Request PTS, Run: '"..server.Settings.Prefix.."pts request' in the command bar by pressing the "..server.Settings.ConsoleKeyCode.." key")
					wait(0.5)
					table.insert(server.Settings.Muted,plr.Name..':'..plr.userId) 
					server.Remote.LoadCode(plr,[[service.StarterGui:SetCoreGuiEnabled("Chat",false) client.Variables.ChatEnabled = false client.Variables.Muted = true]])
					server.Admin.RunCommand(server.Settings.Prefix.."notify admins "..plr.Name.." was muted for violated PTS")
				elseif Action == "smite" then
					server.Admin.RunCommand(server.Settings.Prefix.."smite "..plr.Name)
				elseif Action == "kill" then
					server.Admin.RunCommand(server.Settings.Prefix.."kill "..plr.Name)
				end

			end

			local function Request(plr)
				server.Admin.RunCommand(server.Settings.Prefix.."notify admins "..plr.Name.." requested PTS")
				table.insert(PTSRequests, 1, plr.Name)
			end

			local function AddPlr(plr)
				plr.Chatted:connect(function(msg)
					if PTSEnabled == true then
						if server.Admin.CheckAdmin(plr) == false or PenalizeAdmins == true then
							local eof = false
							for _, v in pairs(phrases) do if msg == v then if eof == false then eof = true end end end
							if eof == false then
								local Ena = false
								for _, vv in pairs(PTSGrant) do

									if plr.Name == vv then
										if Ena == false then Ena = true end
									end

								end
								if Ena ~= true then
									Violation(plr)
								end
							end
						end
					end
				end)
			end


			if args[1] == "help" then
				if server.Admin.CheckAdmin(plr) == true then
					server.Remote.MakeGui(plr,"List",{Title = "PTS";Table = AdminOpen;})
				else
					server.Remote.MakeGui(plr,"List",{Title = "PTS";Table = NonAdminOpen;})
				end

			elseif args[1] == "enable" then
				if server.Admin.CheckAdmin(plr) == true then
					if PTSEnabled == false then
						PTSEnabled = true
						for i,v in pairs(service.Players:GetChildren()) do
							server.Remote.RemoveGui(v,"Notify")
							server.Remote.MakeGui(v,"Notify",{
								Title = "PTS";
								Message = "PTS is now Enabled";
							})
							server.Admin.RunCommand(server.Settings.Prefix.."setmessage PTS Is Enabled. Run "..server.Settings.Prefix.."pts request to Request PTS")
						end
					else
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "PTS is already Enabled";
						})	
					end
				else
					error("Unauthorized")
				end

			elseif args[1] == "disable" then
				if server.Admin.CheckAdmin(plr) == true then
					if PTSEnabled == true then
						PTSEnabled = false
						for i,v in pairs(service.Players:GetChildren()) do
							server.Remote.RemoveGui(v,"Notify")
							server.Remote.MakeGui(v,"Notify",{
								Title = "PTS";
								Message = "PTS is now Disabled";
							})
							server.Admin.RunCommand(server.Settings.Prefix.."setmessage off")
						end
					else
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "PTS is not Enabled";
						})	
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "setaction" then
				if server.Admin.CheckAdmin(plr) == true then
					local Ena = false
					for i, v in pairs(actions) do 
						if string.lower(args[2]) == v then
							if Ena == false then Ena = true end
						end end
					if Ena == true then
						Action = string.lower(args[2])
						server.Functions.Hint("Successfully set action to "..Action,{plr}, 4)
					else
						server.Functions.Hint("Action does not exist",{plr}, 4)	
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "mute" then
				if server.Admin.CheckAdmin(plr) == true then
					for i,v in pairs(service.GetPlayers(plr,args[2])) do
						table.insert(PTSMute, 1, v.Name)
						server.Functions.Hint("Successfully Muted "..v.Name.."'s PTS",{plr}, 4)	
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "unmute" then
				if server.Admin.CheckAdmin(plr) == true then
					for i,v in pairs(service.GetPlayers(plr,args[2])) do
						for i, vvv in pairs(PTSMute) do
							if v.Name == vvv then
								table.remove(PTSMute, i)

							end

						end
						server.Functions.Hint("Successfully Unmuted "..v.Name.."'s PTS",{plr}, 4)	
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "grant" then
				if server.Admin.CheckAdmin(plr) == true then
					if PTSEnabled == true then
						for i,v in pairs(service.GetPlayers(plr,args[2])) do
							local grpts = false
							for _, vv in pairs(PTSGrant) do if v.Name == vv then if grpts == false then grpts = true end end end
							if grpts == true then
								server.Remote.RemoveGui(plr,"Notify")
								server.Remote.MakeGui(plr,"Notify",{
									Title = "PTS";
									Message = "PTS is Already Granted For That Player";
								})
							else
								server.Functions.Hint("Granted PTS to "..v.Name,{plr}, 4)	
								table.insert(PTSGrant, 1, v.Name)
								server.Remote.RemoveGui(v,"Notify")
								server.Remote.MakeGui(v,"Notify",{
									Title = "PTS";
									Message = "PTS Granted. Speak Freely";
								})
								for i, vvv in pairs(PTSRequests) do
									if v.Name == vvv then
										table.remove(PTSRequests, i)

									end

								end end
						end
					else
						error("PTS is Not Enabled")
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "deny" then
				if server.Admin.CheckAdmin(plr) == true then
					if PTSEnabled == true then
						for i,v in pairs(service.GetPlayers(plr,args[2])) do
							for _, vv in pairs(PTSRequests) do
								if v.Name == vv then

									server.Remote.RemoveGui(v,"Notify")
									server.Remote.MakeGui(v,"Notify",{
										Title = "PTS";
										Message = "PTS Denied. Please Wait Before Trying Again";
									})
									for i, vvv in pairs(PTSRequests) do
										if v.Name == vvv then
											table.remove(PTSRequests, i)

										end

									end

								else
									server.Functions.Hint("PTS was not requested by that player",{plr}, 4)	
								end
							end
						end
					else
						error("PTS is Not Enabled")
					end
				else
					error("Unauthorized")
				end
			elseif args[1] == "revoke" then
				if server.Admin.CheckAdmin(plr) == true then
					if PTSEnabled == true then
						for i,v in pairs(service.GetPlayers(plr,args[2])) do
							for _, vv in pairs(PTSGrant) do
								if v.Name == vv then

									server.Remote.RemoveGui(v,"Notify")
									server.Remote.MakeGui(v,"Notify",{
										Title = "PTS";
										Message = "PTS Revoked. Do Not Speak";
									})
									for i, vvv in pairs(PTSGrant) do
										if v.Name == vvv then
											table.remove(PTSGrant, i)

										end

									end

								end
							end
						end
					else
						error("PTS is Not Enabled")
					end
				else
					error("Unauthorized")
				end


			elseif args[1] == "violators" then
				if server.Admin.CheckAdmin(plr) == true then
					for i, v in pairs(PTSViolations) do
						table.insert(PTSVWindow, i, {Text=v})
					end
					server.Remote.MakeGui(plr,"List",{Title = "PTS Violations";Table = PTSVWindow;})
					wait(2)
					for i, v in pairs(PTSVWindow) do table.remove(PTSVWindow, i) end
				else
					error("Unauthorized")
				end


			elseif args[1] == "muted" then
				if server.Admin.CheckAdmin(plr) == true then
					for i, v in pairs(PTSMute) do
						table.insert(PTSMWindow, i, {Text=v})
					end
					server.Remote.MakeGui(plr,"List",{Title = "PTS Mutes";Table = PTSMWindow;})
					wait(2)
					for i, v in pairs(PTSMWindow) do table.remove(PTSMWindow, i) end
				else
					error("Unauthorized")
				end

			elseif args[1] == "requests" then
				if server.Admin.CheckAdmin(plr) == true then
					for i, v in pairs(PTSRequests) do
						table.insert(PTSRWindow, i, {Text=v})
					end
					server.Remote.MakeGui(plr,"List",{Title = "PTS Mutes";Table = PTSRWindow;})
					wait(2)
					for i, v in pairs(PTSRWindow) do table.remove(PTSRWindow, i) end
				else
					error("Unauthorized")
				end


			elseif args[1] == "request" then
				if PTSEnabled == false then
					error("PTS is Not Currently Enabled")
				else
					local rpts = false
					local mpts = false
					local gpts = false

					for _, v in pairs(PTSRequests) do if plr.Name == v then if rpts == false then rpts = true end end end

					for _, v in pairs(PTSMute) do if plr.Name == v then if mpts == false then mpts = true end end end

					for _, v in pairs(PTSGrant) do if plr.Name == v then if gpts == false then gpts = true end end end

					if gpts == true and mpts == false then
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "You already have been granted PTS";
						})	

					elseif rpts == true and mpts == false then
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "Request Already Pending";
						})	

					elseif mpts == true then
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "Your PTS Is Currently Muted";
						})
					elseif mpts == false then
						server.Remote.RemoveGui(plr,"Notify")
						server.Remote.MakeGui(plr,"Notify",{
							Title = "PTS";
							Message = "Request Has Been Sent";
						})
						Request(plr)

					end end
			else
				if server.Admin.CheckAdmin(plr) == true then
					error("Please supply a valid argument")
				else
					local ans,event = server.Remote.GetGui(plr,"YesNoPrompt",{
						Question = "Do you want to Request PTS?";})	 	
					if ans == "Yes" then
						if PTSEnabled == false then
							error("PTS is Not Currently Enabled")
						else
							local rpts = false
							local mpts = false
							local gpts = false

							for _, v in pairs(PTSRequests) do if plr.Name == v then if rpts == false then rpts = true end end end

							for _, v in pairs(PTSMute) do if plr.Name == v then if mpts == false then mpts = true end end end

							for _, v in pairs(PTSGrant) do if plr.Name == v then if gpts == false then gpts = true end end end

							if gpts == true and mpts == false then
								server.Remote.RemoveGui(plr,"Notify")
								server.Remote.MakeGui(plr,"Notify",{
									Title = "PTS";
									Message = "You already have been granted PTS";
								})	

							elseif rpts == true and mpts == false then
								server.Remote.RemoveGui(plr,"Notify")
								server.Remote.MakeGui(plr,"Notify",{
									Title = "PTS";
									Message = "Request Already Pending";
								})	

							elseif mpts == true then
								server.Remote.RemoveGui(plr,"Notify")
								server.Remote.MakeGui(plr,"Notify",{
									Title = "PTS";
									Message = "Your PTS Is Currently Muted";
								})
							elseif mpts == false then
								server.Remote.RemoveGui(plr,"Notify")
								server.Remote.MakeGui(plr,"Notify",{
									Title = "PTS";
									Message = "Request Has Been Sent";
								})
								Request(plr)

							end end
					else
						server.Functions.Hint("Command Cancelled",{plr}, 3)			
					end
				end end
			if es == false then
				es = true
				service.Players.PlayerAdded:connect(function(play)
					AddPlr(play)
				end)
			end
			if er == false then
				er = true
				for i,v in pairs(service.Players:GetChildren()) do
					AddPlr(v)
				end
			end



		end 

	}




end
