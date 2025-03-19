--[[
    activity.lua
    Kn0wledqe
    Created on 03/17/2025 @ 02:54:26
    
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
local activity = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")
local rewardsManager = requireInitialized("jobs/rewardManager")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--
local REWARD_CHICKEN_ID = 14
local GROUP_ID = 35631361

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function activity:InitAsync(): nil
	replicator:listen("activity_reward", function(player: Player)
		local hasSkin = dataWrapper.doesOwnSkin(player, REWARD_CHICKEN_ID)
        print(hasSkin)
		if hasSkin then
			return false, "You have already claimed this reward!"
		end

		if not player:IsInGroup(GROUP_ID) then
			return false, "You must join the group and like the game to claim this reward!"
		end

		rewardsManager.handleReward(player, {
			type = "SKINS",
			ID = REWARD_CHICKEN_ID,
		})
		return true, "🎉 You have successfully claimed the reward! 🎉"
	end)
end

--= Return Job =--
return activity
