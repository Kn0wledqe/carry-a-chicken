--[[
    collisionManager.lua
    Kn0wledqe
    Created on 05/08/2024 @ 19:28:04
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Root =--
local collisionManager = {}

--= Jobs =--

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local physicsService = game:GetService("PhysicsService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

--= Object References =--

--= Constants =--
collisionManager.GROUPS = {
	PLAYER = "Player",
	CHICKEN = "Chicken",
	CHICKEN_AREA = "ChickenOnlyArea",
}

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function collisionManager.setGroup(part, collisionGroup: string): nil
	local function set(part: BasePart?)
		if not part:IsA("BasePart") then
			return
		end

		part.CollisionGroup = collisionGroup
	end

	if part:IsA("Model") or part:IsA("Folder") then
		for _, part in part:GetDescendants() do
			set(part)
		end

		part.DescendantAdded:Connect(set)
		return
	end

	set(part)
end

--= Job Initializers =--
function collisionManager:InitAsync(): nil
	if not runService:IsServer() then
		return
	end

	physicsService:RegisterCollisionGroup(collisionManager.GROUPS.PLAYER)
	physicsService:RegisterCollisionGroup(collisionManager.GROUPS.CHICKEN)

	--ChickenOnlyArea

	physicsService:CollisionGroupSetCollidable(collisionManager.GROUPS.PLAYER, collisionManager.GROUPS.PLAYER, false)
	physicsService:CollisionGroupSetCollidable(collisionManager.GROUPS.CHICKEN, collisionManager.GROUPS.CHICKEN, false)

	physicsService:CollisionGroupSetCollidable(
		collisionManager.GROUPS.CHICKEN,
		collisionManager.GROUPS.CHICKEN_AREA,
		false
	)
	physicsService:CollisionGroupSetCollidable(
		collisionManager.GROUPS.PLAYER,
		collisionManager.GROUPS.CHICKEN_AREA,
		true
	)
	physicsService:CollisionGroupSetCollidable(collisionManager.GROUPS.CHICKEN, collisionManager.GROUPS.PLAYER, false)

	players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			if character:GetAttribute("Chicken") then
				collisionManager.setGroup(character, collisionManager.GROUPS.CHICKEN)
				return
			end
			collisionManager.setGroup(character, collisionManager.GROUPS.PLAYER)
		end)
	end)
end

--= Return Job =--
return collisionManager
