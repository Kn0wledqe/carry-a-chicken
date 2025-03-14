--[[
    session.lua
    Kn0wledqe
    Created on 03/01/2025 @ 16:57:52
    
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
local session = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")

local rewardsManager = requireInitialized("jobs/rewardManager")

--= Classes =--

--= Modules & Config =--
local CONFIG = requireInitialized("$config/session")

local deepCopy = requireInitialized("$utils/deepCopy")

--= Roblox Services =--
local runService = game:GetService("RunService")

--= Object References =--

--= Constants =--
local MINS = runService:IsStudio() and 1 or 60

--= Variables =--
local players = {}

--= Shorthands =--

--= Functions =--
local function handleReward(player, reward)
	reward.claimed = true
	rewardsManager.handleReward(player, reward.reward)
end

local function createTemplate()
	local joinTime = workspace:GetServerTimeNow()
	local rewards = deepCopy(CONFIG.rewards[CONFIG.currentRewardID])
	for _, reward in rewards do
        reward.timemark = reward.timemark * MINS 
		reward.rewardedIn = reward.timemark + joinTime

		reward.claimed = false
	end

	return {
		rewards = rewards,
		timeJoined = joinTime,
	}
end

local function getData(player: Player)
	if not players[player] then
		players[player] = createTemplate()
	end

	return players[player]
end

--= Job API =--

--= Job Initializers =--
function session:InitAsync(): nil
	replicator:listen("session_reward", function(player: Player, action: string, index: number)
		local data = getData(player)

		if action == "getData" then
			return data.rewards
		elseif action == "claim" then

			if not index then
				return false
			end

			local reward = data.rewards[index]
			if reward.claimed then
				return false
			end

			local time = workspace:GetServerTimeNow()
			if reward.rewardedIn > time then
				return false
			end

			handleReward(player, reward)
			return true
		end
	end)
end

function session:PlayerRemoved(player: Player)
	players[player] = nil
end

--= Return Job =--
return session
