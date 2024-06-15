--[[
	Author: ccuser44, Sceleratis, Epix Incorporated, and the Adonis Community.
	Name: Admin name tag
	Note: This only works with TextChatService at the moment. Also note that you must update this plugin regularly because it replaces the Adonis chat handlers.
	Description: This plugin adds an admin tag next to the username in chat.
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-AdminNameTag"
	License: MIT
--]]
--[[
    MIT License

    Copyright (c) 2022 Sceleratis (https://github.com/Sceleratis), Epix Incorporated, and the Adonis Community.
    Copyright (c) 2023 ccuser44/ALE111_boiPNG

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
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Admin, Settings, Logs, Variables, Remote = server.Admin, server.Settings, server.Logs, server.Variables, server.Remote
	local AddLog = Logs.AddLog

	--// Support for modern TextChatService
	if service.TextChatService and service.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService and Settings.OverrideChatCallbacks then
		local function onNewTextchannel(textchannel)
			AddLog("Script", "Connected with custom handler to textchannel: "..textchannel.Name)

			textchannel.ShouldDeliverCallback = function(chatMessage, textSource)
				if
					chatMessage.Status == Enum.TextChatMessageStatus.Success
					or chatMessage.Status == Enum.TextChatMessageStatus.Sending
				then
					local player = service.Players:GetPlayerByUserId(textSource.UserId)
					local slowCache = Admin.SlowCache

					if not player then
						return true
					elseif Admin.DoHideChatCmd(player, chatMessage.Text) then -- // Hide chat commands?
						return false
					elseif Admin.IsMuted(player) then -- // Mute handler
						Remote.MakeGui(player, "Notification", {
							Title = "You are muted!";
							Message = "You are muted and cannot talk in the chat right now.";
							Time = 10;
						})

						return false
					elseif Admin.SlowMode and not Admin.CheckAdmin(player) and slowCache[player] and os.time() - slowCache[player] < Admin.SlowMode then
						Remote.MakeGui(player, "Notification", {
							Title = "You are chatting too fast!";
							Message = string.format("[Adonis] :: Slow mode enabled! (%g second(s) remaining)", Admin.SlowMode - (os.time() - slowCache[player]));
							Time = 10;
						})

						return false
					end

					if Variables.DisguiseBindings[textSource.UserId] then -- // Disguise command handler
						chatMessage.PrefixText = Variables.DisguiseBindings[textSource.UserId].TargetUsername..":"
					else
						local level, rankName = Admin.GetLevel(player)
						local isDonor = (level <= 0 and Admin.CheckDonor(player) or false)

						if isDonor or level > 0 then
							chatMessage.PrefixText = `[{isDonor and "Donor" or rankName}] {chatMessage.PrefixText}`
						end
					end

					if Admin.SlowMode then
						slowCache[player] = os.time()
					end
				end

				return true
			end
		end

		local function onTextChannelsAdded(textChannels)
			for _, v in textChannels:GetChildren() do
				if v:IsA("TextChannel") then
					task.spawn(onNewTextchannel, v)
				end
			end

			textChannels.ChildAdded:Connect(function(child)
				if child:IsA("TextChannel") then
					task.spawn(onNewTextchannel, child)
				end
			end)
		end

		if service.TextChatService:FindFirstChild("TextChannels") then
			task.spawn(pcall, onTextChannelsAdded, service.TextChatService:FindFirstChild("TextChannels"))
		end

		service.TextChatService.ChildAdded:Connect(function(child)
			if child.Name == "TextChannels" then
				task.spawn(onTextChannelsAdded, child)
			end
		end)

		AddLog("Script", "Custom TextChatService handler loaded")
	else
		AddLog("Script", "Didn't load custom TextChatService handler due to game not using TextChatService")
	end
end
