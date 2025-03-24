--[[
    enviormentManager.lua
    Kn0wledqe
    Created on 03/07/2025 @ 23:03:44
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local requireInitialized = require
if true then
	requireInitialized = require(game.ReplicatedStorage.requireInitialized)
end

--= Root =--
local enviormentManager = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

local badgeManager = requireInitialized(script.Parent.badgeManager)

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--
local coinModel = replicatedStorage.assets.Coin
local coinsSpawnMap = workspace.Map.Coins

--= Constants =--

--= Variables =--
local claimedCoins = {}
local progress = {}

--= Shorthands =--

--= Functions =--
local function spawnCoins()
	for _, spawnPoint in coinsSpawnMap:GetChildren() do
		local newCoin = coinModel:Clone()
		newCoin.Parent = workspace.Coins
		newCoin:PivotTo(spawnPoint.CFrame)

		spawnPoint.Transparency = 1

		newCoin.Outer.Touched:Connect(function(Part)
			local player = players:GetPlayerFromCharacter(Part.Parent)
			if not player then
				return
			end

			local class = requireInitialized("classes/linked").getClassByPlayer(player)
			if not class then
				return
			end

			if claimedCoins[player] and claimedCoins[player][newCoin] then
				return
			end

			for _, player in class._players do
				if not claimedCoins[player] then
					claimedCoins[player] = {}
				end
				claimedCoins[player][newCoin] = true

				dataWrapper.addToCoins(player, 3 * (if dataWrapper.hasVip(player) then 2 else 1))
				replicator:sendToPlayer("enviorment_manager", player, "claimCoin", { coin = newCoin, visible = false })
			end
		end)
	end
end

local function initializeProgressIndicators()
	local totalGrass = #workspace.Spawns.Grass:GetChildren()

	for _, part: Part in workspace.Spawns:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.TouchEnded:Connect(function(otherPart)
			local player = players:GetPlayerFromCharacter(otherPart.Parent)
			if not player then
				return
			end

			local class = requireInitialized("classes/linked").getClassByPlayer(player)
			if not class then
				return
			end

			if class.progressPart == part then
				return
			end

			local worldIndex = part:GetAttribute("_endOfWorld")
			if worldIndex then
				class:worldFinished(worldIndex)
			end

			--[[
			if part.Name == "Desert_Start" then
				game:GetService("AnalyticsService"):LogOnboardingFunnelStepEvent(player, 3, "Finished First World")
				badgeManager.awardBadge(player, "FIRST_WORLD")
			end

			if part.Name == "Desert_End" then
				badgeManager.awardBadge(player, "SECOND_WORLD")

				local class = requireInitialized("classes/linked").getClassByPlayer(player)
				if not class then
					return
				end

				class:win()
				-- game finsihed
			end
			]]

			class.progressPart = part
			--progress[player] = part
			local identifierPoint = tonumber(part.Name) + 2 -- 2 for the first two steps(player join and paired up)
			if part.Parent.Name == "Desert" then
				identifierPoint += totalGrass
			end

			for _, player in class._players do
				print("Surpassed", part.Parent.Name, part.Name)
				game:GetService("AnalyticsService")
					:LogOnboardingFunnelStepEvent(player, identifierPoint, `Surpassed {part.Parent.Name}_{part.Name}`)

				replicator:sendToPlayer(
					"progress_manager",
					player,
					"reachedCheckpoint",
					{ index = identifierPoint - 2, raised = true }
				)
			end
		end)
	end
end

--= Job API =--
function enviormentManager.resetCoins(player: Player): nil
	claimedCoins[player] = {}
	replicator:sendToPlayer("enviorment_manager", player, "reset")
end

function enviormentManager.resetProgress(player: Player)
	progress[player] = nil
end

--[[
function enviormentManager.getProgress(player: Player)
	return progress[player]
end
]]

--= Job Initializers =--
function enviormentManager:InitAsync(): nil
	spawnCoins()
	initializeProgressIndicators()
end

--= Return Job =--
return enviormentManager
