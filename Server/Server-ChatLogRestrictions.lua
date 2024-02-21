--!nonstrict
--[[
	Author: Agent BUB (agentbub.dev)
	Name: Chatlog Restrictions
	Description: This plugin allows for certain teams to be hidden from chatlogs. Also, if enabled, it adds the ":rchatlogs" command for the adminlevel of your choice to view chatlogs with restricted teams included.
	Version: 1.5.0
	Last Updated: 02/20/2024
	License: MIT
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-ChatLogRestrictions"
--]]
--[[
	MIT License

	Copyright (c) 2024 Github@AgentBUB

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local teamNames = { -- Make sure the names match exactly.
	"Interview",
	"Interrogation",
	"Experiment"
}
local rChatlogsEnabled = true -- Enables (true) or disables (false) the restricted chatlogs command
local rChatlogsAdminLvl = "ModPlusRChat" -- Normal Adonis adminLevel number value or name for rchatlogs command to work for by default OR the custom rank name when "customRankMode = true"
local customRankMode = true -- If you want to use a custom rank defined in this plugin or just a normal adonis rank or pre-setup custom rank defined in the settings, not here
local customRankLevel = 105 -- The admin level of the custom rank
local customRankUsers = { -- The users/groups/etc given the custom rank
	-- "Username"; "Username:UserId"; UserId; "Group:GroupId:GroupRank"; "Group:GroupId"; "Item:ItemID"; "GamePass:GamePassID";
	358410086;
	"Group:16793436";
	"Group:3489982:255";
}
local tNameLog = true -- When enabled (true) will show the restricted the team name in the rchatlogs before the message or if disabled (false) will just show "[R]"

return function(Vargs)
	local server, service, client = Vargs.Server, Vargs.Service, Vargs.Client

	if rChatlogsEnabled then
		local oldTabToType = server.Logs.TabToType
		server.Logs.RChats, server.Logs.TabToType, server.Logs.ListUpdaters.RChatLogs = {}, function(tab: any, ...: any): string
			if tab == server.Logs.RChats then
				return "RChatLogs"
			else
				return oldTabToType(tab, ...)
			end
		end, function(_)
			return server.Logs.RChats
		end
		
		server.Commands.RChatLogs = {
			Prefix = server.Settings.Prefix;
			Commands = {"rchatlogs", "rchats", "rchathistory"};
			Args = {"autoupdate? (default: false)"};
			Description = "Displays the current chat logs for the server, including restricted teams";
			AdminLevel = rChatlogsAdminLvl;
			ListUpdater = "RChats";
			Function = function(plr: Player, args: {string})
				server.Remote.MakeGui(plr, "List", {
					Title = "All Chat Logs (Including Restricted)";
					Tab = server.Logs.ListUpdaters.RChatLogs(plr);
					Dots = true;
					Update = "RChatLogs";
					AutoUpdate = if args[1] and (args[1]:lower() == "true" or args[1]:lower() == "yes") then 1 else nil;
					Sanitize = true;
					Stacking = true;
				})
			end
		};
		
		if customRankMode then
			server.Settings.Ranks[`{rChatlogsAdminLvl}`] = {
				Level = customRankLevel;
				Users = customRankUsers;
			};
		end
	end
	
	local function isRestrictedTeam(teamName)
		for _, rTeamName in pairs(teamNames) do
			if rTeamName == teamName then
				return true
			end
		end
		return false
	end
	
	server.Process.Chat = function(p, msg)
		local didPassRate, didThrottle, canThrottle, curRate, maxRate = server.Process.RateLimit(p, "Chat")
			if didPassRate then
				local isMuted = server.Admin.IsMuted(p);
				if utf8.len(utf8.nfcnormalize(msg)) > server.Process.MaxChatCharacterLimit and not server.Admin.CheckAdmin(p) then
					server.Anti.Detected(p, "Kick", "Chatted message over the maximum character limit")
				elseif not isMuted then
					if not server.Admin.CheckSlowMode(p) then
						local msg = string.sub(msg, 1, server.Process.MsgStringLimit)
						local filtered = service.LaxFilter(msg, p)

						if not isRestrictedTeam(p.Team.Name) then
							server.Logs.AddLog(server.Logs.Chats, {
								Text = `{p.Name}: {filtered}`;
								Desc = tostring(filtered);
								Player = p;
							})
						end
						if rChatlogsEnabled then
							if isRestrictedTeam(p.Team.Name) then
								server.Logs.AddLog(server.Logs.RChats, {
									Text = `[{tNameLog and p.Team.Name or "R"}] {p.Name}: {filtered}`;
									Desc = tostring(filtered);
									Player = p;
								})
							else
								server.Logs.AddLog(server.Logs.RChats, {
									Text = `{p.Name}: {filtered}`;
									Desc = tostring(filtered);
									Player = p;
								})
							end
						end

						if server.Settings.ChatCommands then
							if server.Admin.DoHideChatCmd(p, msg) then
								server.Remote.Send(p,"Function","ChatMessage",`> {msg}`,Color3.new(1, 1, 1))
								server.Process.Command(p, msg, {Chat = true;})
							elseif string.sub(msg, 1, 3) == "/e " then
								service.Events.PlayerChatted:Fire(p, msg)
								msg = string.sub(msg, 4)
								server.Process.Command(p, msg, {Chat = true;})
							elseif string.sub(msg, 1, 8) == "/system " then
								service.Events.PlayerChatted:Fire(p, msg)
								msg = string.sub(msg, 9)
								server.Process.Command(p, msg, {Chat = true;})
							else
								service.Events.PlayerChatted:Fire(p, msg)
								server.Process.Command(p, msg, {Chat = true;})
							end
						else
							service.Events.PlayerChatted:Fire(p, msg)
						end
					else
						local msg = string.sub(msg, 1, server.Process.MsgStringLimit)
						
						if server.Settings.ChatCommands then
							if server.Admin.DoHideChatCmd(p, msg) then
								server.Remote.Send(p,"Function","ChatMessage",`> {msg}`,Color3.new(1, 1, 1))
								server.Process.Command(p, msg, {Chat = true;})
							else
								server.Process.Command(p, msg, {Chat = true;})
							end
						end
					end
				elseif isMuted then
					local msg = string.sub(msg, 1, server.Process.MsgStringLimit);
					service.Events.MutedPlayerChat_UnFiltered:Fire(p, msg)
					local filtered = service.LaxFilter(msg, p)
					
					if not isRestrictedTeam(p.Team.Name) then
						server.Logs.AddLog(server.Logs.Chats, {
							Text = `[MUTED] {p.Name}: {filtered}`;
							Desc = tostring(filtered);
							Player = p;
						})
					end
					if rChatlogsEnabled then
						if isRestrictedTeam(p.Team.Name) then
								server.Logs.AddLog(server.Logs.RChats, {
									Text = `[{tNameLog and p.Team.Name or "R"}] [MUTED] {p.Name}: {filtered}`;
									Desc = tostring(filtered);
									Player = p;
								})
							else
								server.Logs.AddLog(server.Logs.RChats, {
									Text = `[MUTED] {p.Name}: {filtered}`;
									Desc = tostring(filtered);
									Player = p;
								})
							end
					end
					
					service.Events.MutedPlayerChat_Filtered:Fire(p, filtered)
				end
			elseif not didPassRate and server.Process.RateLimit(p, "RateLog") then
				server.Anti.Detected(p, "Log", string.format("Chatting too quickly (>Rate: %s/sec)", curRate))
				warn(string.format("%s is chatting too quickly (>Rate: %s/sec)", p.Name, curRate))
			end
	end;
	
end
