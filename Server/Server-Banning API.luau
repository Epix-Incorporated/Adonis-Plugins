--[[
	File: Server-Banning API.lua
	Author: Coasterteam
	Description: A temporary addition of the Banning API to allow Adonis to communicate with it. 
		This plugin should be used temporarily until Adonis fully implements the rewritten moderation systems (TBD)
	Last Updated: June 26th, 2024
	Version: 1.0
--]]

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	
	-- Check if Adonis has this already, if so don't load! The main Adonis officially supports this now.
	
	if server.Admin.BanAsync then 
		warn("Adonis Banning-API plugin is no longer needed as Adonis officially supports it in the main module. Please remove the additional plugin.")
		return 
	end 

	server.Variables.BanAPIConfig = {
		BanningAPIEnabled = true; -- Allow BanningAPI to be used
		UseBackupDatastore = true; -- Save to Datastore anyway
		
		LoadBansFromDatastore = true; 
		-- Make it so datastore doesn't actually load bans so it doesn't interfere with BanningAPI
		-- Be warned; it does not allow you to see who is banned as it's not something you can iterate through easily
		-- A more official system IS coming, this is just temporary. I recommend keeping this enabled 
		-- 							unless you're having trouble unbanning people.
		
		-- READ FULL COMMENT NEXT TO SETTING!
		FastBanMigration = false; -- This strips the custom reason of bans and uses a static ban message; allowing bans to chunk together (faster to migrate if you have a lot of bans)
		FastBanMigrationReason = "Adonis Ban Migration from DataStore";
		
		BanAltAccounts = true; -- Allow AltAccounts to be banned
		-- True => Do not exclude alt accounts
		-- False => Exclude alt accounts
		
		BansSupported = {
			Permanent = true; -- Listen in on :gameban and :ungameban & allow migration
			Temporary = true; -- Listen in on :timeban and :untimeban & allow migration
		};
	}
	
	if not server.Variables.BanAPIConfig.LoadBansFromDatastore then 
		server.Core.DS_BLACKLIST.Banned = true
		server.Core.DS_BLACKLIST["Core.Variables.TimeBans"] = true
	end
	
	server.Admin.BanAsync = function(userIds, reason, moderator, options)
		
		if not server.Variables.BanAPIConfig.BanningAPIEnabled then
			return false
		end
		
		-- Default stuff
		if not options then 
			options = {
				ExcludeAltAccounts = not server.Variables.BanAPIConfig.BanAltAccounts; -- BanAltAccounts = true == false exclude them
			} 
		end
		
		local success, errMessage
		service.Queue("BanningAPI", function()
			success, errMessage = pcall(function()
				service.Players:BanAsync({
					UserIds = userIds;
					DisplayReason = options.OverrideDisplayReason or reason;
					Duration = options.Duration or -1;
					PrivateReason = `Moderated by {tostring(moderator)} via Adonis for: {reason}`;
					ApplyToUniverse = if options.ApplyToUniverse ~= nil then options.ApplyToUniverse else true;
					ExcludeAltAccounts = if options.ExcludeAltAccounts ~= nil then options.ExcludeAltAccounts else not server.Variables.BanAPIConfig.BanAltAccounts;
				})
				task.wait()
			end)
			if not success and errMessage then
				-- Error filtering
				warn("Failed to issue BanAsync:", errMessage)
				if options.DontRetryBan then return end
				if string.match(string.lower(errMessage), "was deemed inappropriate.") then
					options.OverrideDisplayReason = 'Display reason was moderated, see game admins.'
				else
					task.wait(1)
				end
				-- rerun it now
				-- I hate this roblox please make this not so bad (also on me for making it bad in the first place)
				success, errMessage = pcall(function()
					service.Players:BanAsync({
						UserIds = userIds;
						DisplayReason = options.OverrideDisplayReason or reason;
						Duration = options.Duration or -1;
						PrivateReason = `Moderated by {tostring(moderator)} via Adonis for: {reason}`;
						ApplyToUniverse = if options.ApplyToUniverse ~= nil then options.ApplyToUniverse else true;
						ExcludeAltAccounts = if options.ExcludeAltAccounts ~= nil then options.ExcludeAltAccounts else not server.Variables.BanAPIConfig.BanAltAccounts;
					})
					task.wait()
				end)
			end
		end, nil, true) -- shouldn't take more than 30s to do but timeout just in case
		return success
	end
	
	server.Admin.UnbanAsync = function(userIds, options)
		-- We're not going to check for BanningAPIEnabled as this is fine to keep open
		if not options then options = {} end
		local success, errMessage
		service.Queue("UnBanningAPI", function()
			success, errMessage = pcall(function()
				service.Players:UnbanAsync({
					UserIds = userIds;
					ApplyToUniverse = if options.ApplyToUniverse ~= nil then options.ApplyToUniverse else true;
				})
				task.wait()
			end)
			if not success and errMessage then
				-- Error filtering
				if not options.DontRetryBan then
					task.wait(1) -- timeout maybe?
					success, errMessage = pcall(function()
						service.Players:UnbanAsync({
							UserIds = userIds;
							ApplyToUniverse = if options.ApplyToUniverse ~= nil then options.ApplyToUniverse else true;
						})
						task.wait()
					end)
				end
			end
		end, nil, true) -- shouldn't take more than 30s to do but timeout just in case
		return success
	end
	
	local OldAddBan = server.Admin.AddBan
	server.Admin.AddBan = function(p, reason, doSave, moderator, banType, ...)
		if server.Variables.BanAPIConfig.BanningAPIEnabled and doSave and server.Variables.BanAPIConfig.BansSupported.Permanent then 
			-- This is a permanent ban
			server.Admin.BanAsync({p.UserId}, reason, moderator, ...)
		end
		if not doSave or server.Variables.BanAPIConfig.UseBackupDatastore then -- Use old system
			return OldAddBan(p, reason, doSave, moderator, banType, ...)
		end 
	end
	
	local OldAddTimeBan = server.Admin.AddTimeBan
	server.Admin.AddTimeBan = function(p : Player | {[string]: any}, duration: number, reason: string, moderator: Player?, ...)
		if server.Variables.BanAPIConfig.BanningAPIEnabled and server.Variables.BanAPIConfig.BansSupported.Temporary then 
			-- This is a permanent ban
			local options = ...
			if not options then options = {} end
			options.Duration = tonumber(duration)
			if not options.Duration then error("Duration is not a number!") end
			server.Admin.BanAsync({p.UserId}, reason, moderator, options)
		end
		if server.Variables.BanAPIConfig.UseBackupDatastore then -- Use old system
			return OldAddTimeBan(p, duration, reason, moderator)
		end 
	end
	
	-- Remove ban
	local OldRemoveBan = server.Admin.RemoveBan
	server.Admin.RemoveBan = function(name, doSave, ...)
		if doSave then 
			-- This is a permanent ban
			local UserId = server.Functions.GetUserIdFromNameAsync(name)
			if UserId then
				server.Admin.UnbanAsync({UserId}, ...)
			end
		end
		if not doSave or server.Variables.BanAPIConfig.UseBackupDatastore then -- Use old system
			return OldRemoveBan(name, doSave)
		end 
		return doSave
	end
	
	local OldRemoveTimeBan = server.Admin.RemoveTimeBan
	server.Admin.RemoveTimeBan = function(name, ...)
		local UserId = server.Functions.GetUserIdFromNameAsync(name)
		if UserId then
			server.Admin.UnbanAsync({UserId}, ...)
		end
		if server.Variables.BanAPIConfig.UseBackupDatastore then -- Use old system
			return OldRemoveTimeBan(name)
		end 
	end
	
	-- Returns the UserId from a record (tries to account for a string record too)
	local function GetUserIdFromRecord(check)
		if type(check) == "table" then
			if check.UserId then
				return tonumber(check.UserId)
			end
		elseif type(check) == "string" then
			local cName, cId = string.match(check, "(.*):(.*)")
			if not cName and cId then cName = check end

			if cId and tonumber(cId) then
				return cId
			end
		elseif type(check) == "number" then
			return check -- userid ban? old ig
		end
		return false
	end
	
	-- chunks bans together
	local function chunks(lst, size)
		local i = 1
		local count = 0
		return function()
			if i > #lst then return end
			local chunk = table.move(lst, i, i + size -1, 1, {})
			i = i + size
			count = count + 1
			return count, chunk
		end
	end
	
	server.Commands.MigrateSavedBans = {
		Prefix = server.Settings.Prefix;
		Commands = {"migratebans"};
		Args = {};
		Description = "Migrates all permanent and temporary bans to Banning API; please ensure you have configured it to your liking in its settings!";
		AdminLevel = "Creators";
		Function = function(plr: Player, args: {string}, data: {any})
			
			server.Functions.Hint("Fetching banned data from DataStore...", {plr})
			local PermBanData = if server.Variables.BanAPIConfig.BansSupported.Permanent then server.Core.GetData("SAVEDTABLE_Banned") else {}
			local TempBanData = if server.Variables.BanAPIConfig.BansSupported.Temporary then server.Core.GetData("SAVEDTABLE_TimeBans") else {}
			server.Functions.Hint("Fetched all ban data from DataStore", {plr})
			
			local PermBans = {}
			local TempBans = {}
			
			local TotalPerm, TotalTemp = 0, 0
			for _,BanTable in {PermBanData, TempBanData} do
				for _,ban in BanTable do
					local success, err = pcall(function()
						local Action = ban.Action
						if Action == "Add" and ban.Value then 
							local Record = ban.Value
							local Reason = server.Variables.BanAPIConfig.FastBanMigrationReason
							local UserId = GetUserIdFromRecord(Record)
							if not UserId or UserId == 1 then return end -- No clue what this record is! Also don't ban the Roblox Id (weird lol)
							local IsPermanent = true
							if type(Record) == "table" then
								if Record.EndTime then 
									IsPermanent = Record.EndTime - os.time() -- Get the duration remaining
									if IsPermanent < 0 then
										-- It's supposed to be over now
										return
									end
								end
								if Record.Reason then
									Reason = server.Functions.Trim(Record.Reason)
								end
							end
							if server.Variables.BanAPIConfig.FastBanMigration then
								Reason = server.Variables.BanAPIConfig.FastBanMigrationReason
							end
							Reason = string.sub(Reason, 1, 400) -- Limit reason
							if IsPermanent == true then
								-- For mass-banning simplicity
								if not PermBans[Reason] then
									PermBans[Reason] = {UserId}
								else 
									table.insert(PermBans[Reason], UserId)
								end
								TotalPerm += 1
							else 
								local Data = {math.ceil(IsPermanent); Reason;}
								local EncodeSuccess, Data = pcall(function() return service.HttpService:JSONEncode(Data) end)
								if not EncodeSuccess then
									warn(Data)
								end
								if Data and not TempBans[Data] then
									TempBans[Data] = {UserId}
								elseif Data then
									table.insert(TempBans[Data], UserId)
								end
								TotalTemp += 1
							end
						elseif Action == "Remove" and ban.Value then
							local Record = ban.Value
							local UserId = GetUserIdFromRecord(Record)
							-- wip (adding later so I can at least get it out)
						end
					end)
					if not success then
						warn(err)
					end
				end
			end
			
			local answer = server.Remote.MakeGuiGet(plr, "YesNoPrompt", {
				Question = `Do you want to start migrating data? We found a total of {TotalPerm} permanent ban(s) and {TotalTemp} temporary ban(s).`
			})
			if answer == "Yes" then
				 -- about 1200 a minute-ish when doing 50, so let's assume 25 a chunk and go 600 is what my average was (unconfirmed)
				local totalChunks = 0 
				for _,BanTable in {PermBans, TempBans} do 
					for BanData,UserIds in BanTable do 
						local count = service.CountTable(UserIds)
						totalChunks += math.ceil(count / 50) 
					end
				end
				local estimatedTimeInSeconds = (totalChunks) * 0.8 -- About 1 second per chunk-call but I'll cut it under a little bit
				local confirm2 = server.Remote.MakeGuiGet(plr, "YesNoPrompt", {
					Question = `It will take an estimated* {estimatedTimeInSeconds/60} minutes to complete this migration. Please do not leave the game during this.`
				})
				if confirm2 == "Yes" then
					local Total = 0
					for BanReason,UserIds in PermBans do 
						for index,UserIdChunk in chunks(UserIds, 50) do 
							if #UserIdChunk == 0 then continue end 
							Total += #UserIdChunk
							server.Admin.BanAsync(UserIdChunk, BanReason, `Adonis System Migration`)
							server.Functions.Hint(`Permanently BanAsync'd {Total}/{TotalPerm} users`, {plr})
						end
					end
					Total = 0
					for Data,UserIds in TempBans do
						local DecodedData = service.HttpService:JSONDecode(Data)
						local Duration, BanReason = DecodedData[1], DecodedData[2] -- Keep its order to ensure JSON doesnt mess it up
						for index,UserIdChunk in chunks(UserIds, 50) do 
							if #UserIdChunk == 0 then continue end 
							Total += #UserIdChunk
							server.Admin.BanAsync(UserIdChunk, BanReason, `Adonis System Migration`, {
								Duration = Duration;
							})
							server.Functions.Hint(`Temporarily BanAsync'd {Total}/{TotalTemp} users`, {plr})
						end
					end
					server.Functions.Notification("Notice", "Ban API Migration is now complete", {plr}, nil)
				end
			end
		end,
	}
	
end
