--[[
	Author: Sceleratis (Davey_Bones)
	Name: Server-NoPlayerCollide
	Description: Adds :collisions, :nocollide, :resetcollisions and :setdefaultcollision commands;
				 enables/disables character-to-character collisions per player

	Place in a ModuleScript under Adonis_Loader > Config > Plugins, named "Server-PlayerCollisions"
--]]

local default_collidable_state = true --// Whether players can collide by default (on join)

return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

	local PhysicsService: PhysicsService = service.PhysicsService

	local Settings = server.Settings
	local Commands = server.Commands
	local Functions = server.Functions
	local Remote = server.Remote

	if PhysicsService:GetMaxCollisionGroups() < #PhysicsService:GetCollisionGroups() + 2 then
		warn("NOPLAYERCOLLIDE PLUGIN ABORTED; TOO MANY EXISTING COLLISION GROUPS ARE IN THE GAME")
		return
	end

	local COLLISION_GROUP_1_NAME = "Adonis_CollidablePlayers"
	local COLLISION_GROUP_2_NAME = "Adonis_NonCollidablePlayers"

	local playerCollidableStates: {[Player]: boolean} = {}

	local function applyCharPartCGroup(plr: Player, obj: Instance)
		if obj:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(obj, if playerCollidableStates[plr]
				then COLLISION_GROUP_1_NAME
				else COLLISION_GROUP_2_NAME
			)
		end
	end

	local function setPlayerCollidable(plr: Player, collidable: boolean)
		if playerCollidableStates[plr] == collidable then
			return
		end
		playerCollidableStates[plr] = collidable
		if plr.Character then
			for _, obj in ipairs(plr.Character:GetDescendants()) do
				applyCharPartCGroup(obj, plr)
			end
		end
		if Settings.CommandFeedback then
			Remote.MakeGui(plr, "Notification", {
				Title = "Collisions "..(collidable and "Enabled" or "Disabled");
				Message = string.format(
					"Your character will %scollide with other players' characters.",
					collidable and "" or "no longer "
				);
				Time = 5;
			})
		end
	end

	PhysicsService:CreateCollisionGroup(COLLISION_GROUP_1_NAME)
	PhysicsService:CreateCollisionGroup(COLLISION_GROUP_2_NAME)
	PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_1_NAME, COLLISION_GROUP_1_NAME, true)
	PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_1_NAME, COLLISION_GROUP_2_NAME, false)
	PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_2_NAME, COLLISION_GROUP_2_NAME, false)

	service.Events.CharacterAdded:Connect(function(plr: Player, char: Model)
		if playerCollidableStates[plr] == nil then
			playerCollidableStates[plr] = default_collidable_state
		end

		char.DescendantAdded:Connect(function(obj)
			applyCharPartCGroup(obj, plr)
		end)
		for _, obj in ipairs(char:GetDescendants()) do
			applyCharPartCGroup(obj, plr)
		end
	end)

	service.Events.PlayerRemoving:Connect(function(plr: Player)
		playerCollidableStates[plr] = nil
	end)

	Commands.EnablePlayerCollision = {
		Prefix = Settings.Prefix;
		Commands = {"collisions", "collision", "cancollide", "collide"};
		Args = {"player (default: '"..Settings.SpecialPrefix.."all')"};
		Description = "Allows the target player's character to collide with other players' characters";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			for _, v in ipairs(if args[1] then service.GetPlayers(plr, args[1]) else service.GetPlayers()) do
				setPlayerCollidable(v, true)
			end
		end
	}

	Commands.DisablePlayerCollision = {
		Prefix = Settings.Prefix;
		Commands = {"nocollide", "nocollision", "nocollisions", "cantcollide"};
		Args = {"player (default: '"..Settings.SpecialPrefix.."all')"};
		Description = "Opposite of "..Settings.Prefix.."collisions; allows players' characters to pass through each other";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			for _, v in ipairs(if args[1] then service.GetPlayers(plr, args[1]) else service.GetPlayers()) do
				setPlayerCollidable(v, false)
			end
		end
	}

	Commands.ResetPlayerCollision = {
		Prefix = Settings.Prefix;
		Commands = {"resetcollisions", "resetcollision"};
		Args = {"player (default: '"..Settings.SpecialPrefix.."all')"};
		Description = "Reset the target player character's ability to collide";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			for _, v in ipairs(if args[1] then service.GetPlayers(plr, args[1]) else service.GetPlayers()) do
				setPlayerCollidable(v, default_collidable_state)
			end
		end
	}

	Commands.SetDefaultPlayerCollision = {
		Prefix = Settings.Prefix;
		Commands = {
			--// bruh
			"setdefaultplayercollision",
			"setdefaultplayercollisions",
			"defaultplayercollision",
			"defaultplayercollisions",
			"setdefaultcollision",
			"setdefaultcollisions",
			"defaultcollision",
			"defaultcollisions"
		};
		Args = {"true/false"};
		Description = "Sets whether players' characters are collidable by default (assigned on join)";
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			local state = if args[1] and args[1]:lower() == "true" then true
				elseif args[1] and args[1]:lower() == "false" then false
				else nil
			assert(state ~= nil, "Argument #1 invalid or missing (must be 'true'/'false')")

			if default_collidable_state == state then
				Functions.Hint(
					string.format("Player collisions are already %s by default", state and "enabled" or "disabled"),
					{plr}
				)
			else
				default_collidable_state = state
				Functions.Hint(
					string.format("Player collisions are now %s by default", state and "enabled" or "disabled"),
					{plr}
				)
			end
		end
	}
end
