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

			if claimedCoins[player] and claimedCoins[player][newCoin] then
				return
			end

			if not claimedCoins[player] then
				claimedCoins[player] = {}
			end

			claimedCoins[player][newCoin] = true

			dataWrapper.addToCoins(player, 3 * (if dataWrapper.hasVip(player) then 2 else 1))

			replicator:sendToPlayer("enviorment_manager", player, "claimCoin", { coin = newCoin, visible = false })
		end)
	end
end

local function initializeProgressIndicators()
	for _, part in workspace.Spawns:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.TouchEnded:Connect(function(otherPart)
			local player = players:GetPlayerFromCharacter(otherPart.Parent)
			if not player then
				return
			end

			if part.Name == "Desert_Start" then
				game:GetService("AnalyticsService"):LogOnboardingFunnelStepEvent(player, 2, "Finished First World")
				badgeManager.awardBadge(player, "FIRST_WORLD")
			end

			if part.Name == "Desert_End" then
				game:GetService("AnalyticsService"):LogOnboardingFunnelStepEvent(player, 3, "Finished Second World")
				badgeManager.awardBadge(player, "SECOND_WORLD")

				local class = requireInitialized("classes/linked").getClassByPlayer(player)
				if not class then
					return
				end

				class:win()
				-- game finsihed
			end

			progress[player] = part
		end)
	end
end

--= Job API =--
function enviormentManager.resetCoins(player: Player): nil
	claimedCoins[player] = {}
	replicator:sendToPlayer("enviorment_manager", player, "resetCoins")
end

function enviormentManager.resetProgress(player: Player)
	progress[player] = nil
end

function enviormentManager.getProgress(player: Player)
	return progress[player]
end

--= Job Initializers =--
function enviormentManager:InitAsync(): nil
	spawnCoins()
	initializeProgressIndicators()
end

--= Return Job =--
return enviormentManager
