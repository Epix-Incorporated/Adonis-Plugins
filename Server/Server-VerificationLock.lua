--!nonstrict
--[[
	Author: ccuser44
	Name: VerificationLock module
	Description: This plugin will adds a :VerificationLock command which allows you to enable/disable an anti-alt feature
	Place in a ModuleScript under Adonis_Loader > Config > Plugins and named "Server-VerificationLock"
	License: MIT
--]]
--[[
	MIT License
	Copyright (c) 2022 Github@ccuser44
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

-- Only one of these checks is required
-- EmailVerification, Premium subscription, VoiceChat, LargeAccountAge, IsAnAdmin
local VERIFIED_ASSETS = {102611803, 93078560, 1567446, 18824203}
local UNVERIFIED_KICK_MESSAGE = "Your acc"
local MIN_ACCOUNT_AGE = 7*4*12*5
local CACHE_CLEAR_TIME = 60
local BE_IN_GROUP_VERIFIED = false
local GROUP_ID = 0
local vcEnabledCache, emailVerifiedCache, isInGroupCache = {}, {}, {}
local lastCacheClear = os.clock()

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Variables, Functions = server.Variables, server.Functions
	local checkAdmin = server.Admin.CheckAdmin

	local function isVoicechatEnabled(player)
		local userId = player.UserId

		if vcEnabledCache[userId] ~= nil then
			return vcEnabledCache[userId]
		else
			local success, value = pcall(
				service.VoiceChatService.IsVoiceEnabledForUserIdAsync,
				service.VoiceChatService,
				userId
			)
	
			if success and type(value) == "boolean" then
				vcEnabledCache[userId] = value
				return value
			else
				return false
			end
		end
	end

	local function isEmailVerified(player)
		if emailVerifiedCache[player.UserId] ~= nil then
			return emailVerifiedCache[player.UserId]
		else
			local isVerified = false

			for _, assetId in ipairs(VERIFIED_ASSETS) do
				if service.CheckAssetOwnership(player, assetId) == true then
					isVerified = true
					break
				end
			end

			if isVerified == true then
				emailVerifiedCache[player.UserId] = isVerified
			end

			return isVerified
		end
	end

	local function isInGroup(group, player)
		if not isInGroupCache[group] then
			isInGroupCache[group] = {}
		end

		if isInGroupCache[group][player.UserId] ~= nil then
			return isInGroupCache[group][player.UserId]
		else
			local success, value = pcall(
				player.IsInGroup,
				player,
				group
			)
	
			if success and type(value) == "boolean" then
				if value == true then
					isInGroupCache[player.UserId] = value
				end

				return value
			else
				return false
			end
		end
	end

	local function isVerified(player)
		if player.MembershipType == Enum.MembershipType.Premium then
			return true
		elseif player.AccountAge >= MIN_ACCOUNT_AGE then
			return true
		elseif isVoicechatEnabled(player) then
			return true
		elseif isEmailVerified(player) then
			return true
		elseif
			BE_IN_GROUP_VERIFIED and
			(GROUP_ID ~= 0 or game.CreatorType == Enum.CreatorType.Group) and
			isInGroup((GROUP_ID ~= 0 and GROUP_ID or game.CreatorId), player)
		then
			return true
		end
	end

	local function clearDictionary(dictionary)
		for k, _ in pairs(dictionary) do
			dictionary[k] = nil
		end
	end

	server.CommandsVerificationLock = {
		Prefix = server.Settings.Prefix;
		Commands = {"slock", "verificationlock", "enableantialt"};
		Args = {"on/off"};
		Description = "Enables/disables server lock";
		AdminLevel = "Admins";
		Function = function(plr: Player, args: {string})
			local arg = args[1] and string.lower(args[1])

			if (not arg and Variables.AltVerificationLock ~= true) or arg == "on" or arg == "true" then
				Variables.AltVerificationLock = true
				Functions.Hint("Server anti-alt verification lock is enabled", {plr})
				clearDictionary(vcEnabledCache)
				--clearDictionary(emailVerifiedCache)
				--clearDictionary(isInGroupCache)
			elseif Variables.AltVerificationLock == true or arg == "off" or arg == "false" then
				Variables.AltVerificationLock = false
				Functions.Hint("Server anti-alt verification lock is disabled", {plr})
				clearDictionary(vcEnabledCache)
				--clearDictionary(emailVerifiedCache)
				--clearDictionary(isInGroupCache)
			end
		end
	};

	server.Admin.CacheCommands()

	service.HookEvent("PlayerAdded", function(player)
		if Variables.AltVerificationLock == true then
			if not isVerified(player) and not checkAdmin(player) then
				player:Kick(":: Adonis ::\n"..UNVERIFIED_KICK_MESSAGE)
			end
		end
	end)
end
