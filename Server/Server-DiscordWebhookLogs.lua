--!nonstrict
--[[
	Original Author: crywink
	Rewrite Author: Expertcoderz
	Name: Server-DiscordWebhookLogs
	Description: Enables logging of commands to a Discord webhook

	Place in a ModuleScript under Adonis_Loader > Config > Plugins, named "Server-DiscordWebhookLogs"

	NOTICE: Discord has blocked Roblox from sending out requests; you are required to use a proxy for your webhook to work.
			Try this DevForum post: https://devforum.roblox.com/t/discord-webhook-proxy/1500688
			-GalacticInspired

	WARNING: DISCORD IS NOT INTENDED AS A LOGGING SERVICE; USE THIS AT YOUR OWN RISK!
--]]

local WEBHOOK_URL: string = "YOUR_WEBHOOK_LINK_HERE" --// Your webhook URL

local EMBED_INFO = {
	Color = Color3.fromRGB(85, 170, 255),
	Title = "Command Ran",

	IncludePlaceName = true,
	IncludePlayerThumbnail = true,
	IncludeTimestamp = true
}

local IGNORE_PLAYER_COMMANDS: boolean = true --// Whether player-level commands such as !info won't be logged to the webhook

local IGNORED_COMMANDS: {string} = { --// Commands that won't be logged to the webhook (array of command names/indices)

}

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	local Admin = server.Admin

	local HttpService: HttpService = service.HttpService

	local embedAuthorInfo = if EMBED_INFO.IncludePlaceName then {
		name = service.MarketplaceService:GetProductInfo(game.PlaceId).Name,
		url = "https://www.roblox.com/games/"..game.PlaceId
	} else nil

	local webhookBatch = {}

	service.Events.CommandRan:Connect(function(plr: Player, data)
		local cmd = data.Command

		if
			(IGNORE_PLAYER_COMMANDS and cmd.AdminLevel == 0) --// player command
			or (table.find(IGNORED_COMMANDS, data.Index)) --// "Fly"
			or (table.find(IGNORED_COMMANDS, data.Matched)) --// ":fly"
			or (table.find(IGNORED_COMMANDS, data.Matched:sub(#cmd.Prefix + 1))) --// "fly"
		then
			return
		end

		table.insert(webhookBatch, {
			author = embedAuthorInfo,
			title = EMBED_INFO.Title,
			color = if type(EMBED_INFO.Color) == "number" then EMBED_INFO.Color else tonumber(EMBED_INFO.Color:ToHex(), 16),
			fields = {
				{
					name = "User:",
					value = string.format(
						"[%s](https://www.roblox.com/users/%d/profile) [%s]",
						service.FormatPlayer(plr),
						plr.UserId,
						Admin.LevelToListName(data.PlayerData.Level)
					)
				},
				{
					name = "Command:",
					value = "``"..data.Message:gsub("[%*_`~]", "\\%1").."``"
				},
				if data.Error then {
					name = "Error:",
					value = "*"..data.Error:gsub("[%*_`~]", "\\%1").."*"
				} else nil
			},
			thumbnail = if EMBED_INFO.IncludePlayerThumbnail then string.format(
				"https://www.roblox.com/bust-thumbnail/image?userId=%d&width=420&height=420&format=png",
				plr.UserId
			) else nil,
			timestamp = if EMBED_INFO.IncludeTimestamp then DateTime.now():ToIsoDate() else nil
		})
	end)

	task.defer(function()
		while true do
			task.wait(math.random(1, 5))
			if #webhookBatch > 0 then
				local success, err = pcall(HttpService.PostAsync, HttpService, WEBHOOK_URL, HttpService:JSONEncode({
					embeds = webhookBatch
				}))
				if success == false then
					warn("Webhook command log failed to post;", err)
				else
					table.clear(webhookBatch)
				end
			end
		end
	end)
end
