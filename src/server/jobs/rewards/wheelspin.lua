--[[
    wheelspin.lua
    Kn0wledqe
    Created on 03/01/2025 @ 01:00:34
    
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
local wheelspin = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

local rewardManager = requireInitialized("jobs/rewardManager")

--= Classes =--

--= Modules & Config =--
local WHEELSPIN_REWARDS = requireInitialized("$config/wheelspin")
local TOTAL_WEIGHT = 0
for _, item in WHEELSPIN_REWARDS do
	TOTAL_WEIGHT += item.weight
end

local ITEM_RANGE = 360 / #WHEELSPIN_REWARDS

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function getRandomReward()
	local randomWeight = math.random(1, TOTAL_WEIGHT)
	local currentWeight = 0

	for idx, item in WHEELSPIN_REWARDS do
		currentWeight += item.weight
		if randomWeight <= currentWeight then
			return idx
		end
	end
end

--= Job API =--

--= Job Initializers =--
function wheelspin:InitAsync(): nil
	replicator:listen("wheelspin_manager", function(client: Player)
		local spins = dataWrapper.getSpins(client)
		if spins <= 0 then
			return false, "You do not have enough spins"
		end
		dataWrapper.addToSpins(client, -1)

		local randomReward = getRandomReward()
		if not randomReward then
			return false, "An unknown error has occured"
		end

		local rewardPosition = (randomReward - 1) * ITEM_RANGE
		local totalRotations = 360 * math.random(3, 8)

		local time = math.random(3, 5)
		local rotation = totalRotations + rewardPosition
		local reward = WHEELSPIN_REWARDS[randomReward]
		task.delay(time, function()
			rewardManager.handleReward(client, reward)
		end)

		return true,
			{
				currentTime = workspace:GetServerTimeNow(),
				time = time,
				rotation = rotation,
				reward = reward,
			}
	end)
end

--= Return Job =--
return wheelspin
