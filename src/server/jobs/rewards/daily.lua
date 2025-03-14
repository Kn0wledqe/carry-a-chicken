--[[
    daily.lua
    Kn0wledqe
    Created on 03/02/2025 @ 15:09:15
    
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

local daily = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

local rewardsManager = requireInitialized(script.Parent.Parent.rewardManager)

--= Classes =--

--= Modules & Config =--
local trove = requireInitialized("$lib/trove")

local DAILYREWARDS_CONFIG = requireInitialized("$config/daily")

--= Roblox Services =--
local runService = game:GetService("RunService")

--= Object References =--

--= Constants =--
local HOURS_24 = runService:IsStudio() and 15 or 60 * 60 * 24

--= Variables =--
local troves = {}

--= Shorthands =--

--= Functions =--
function getDailyRewardsPath(player, new)
	local dailyRewards = dataWrapper.getDailyRewards(player)
	if not dailyRewards or new then
		local now = workspace:GetServerTimeNow()
		dailyRewards = {
			rewardPathID = DAILYREWARDS_CONFIG.currentRewardID,
			rewardIndex = 1,

			rewardsClaimedIndex = 0,
			rewardTick = now,
		}

		dataWrapper.setDailyRewards(player, dailyRewards)
	end

	dailyRewards.maxRewardIndex = #DAILYREWARDS_CONFIG.rewards[dailyRewards.rewardPathID]

	return dailyRewards
end

function getCurrentDayIndex(player, dontNotify)
	local dailyRewards = getDailyRewardsPath(player)

	local timeDifference = workspace:GetServerTimeNow() - dailyRewards.rewardTick
	local hoursIndex = HOURS_24 * dailyRewards.rewardIndex
	--print(timeDifference)
	if timeDifference >= hoursIndex and timeDifference < hoursIndex + HOURS_24 then
		--	print("new reward!", dailyRewards)
		if dontNotify then
			-- remote event!
		end
	elseif timeDifference >= hoursIndex + HOURS_24 then
		dailyRewards = getDailyRewardsPath(player, true)
	end

	if dailyRewards.rewardTick ~= player:GetAttribute("rewardtick_dailyReward") then
		player:SetAttribute("rewardtick_dailyReward", dailyRewards.rewardTick)
	end

	if dailyRewards.rewardIndex ~= player:GetAttribute("rewardIndex_dailyReward") then
		player:SetAttribute("rewardIndex_dailyReward", dailyRewards.rewardIndex)
	end

	return dailyRewards.rewardIndex
end

function claimReward(player)
	local dailyRewards = getDailyRewardsPath(player)

	local hoursIndex = HOURS_24 * dailyRewards.rewardIndex
	local timeDifference = workspace:GetServerTimeNow() - dailyRewards.rewardTick
	print(dailyRewards.rewardIndex, dailyRewards.rewardsClaimedIndex)
	if
		timeDifference >= hoursIndex
		and dailyRewards.rewardIndex ~= 0
		and dailyRewards.rewardsClaimedIndex < dailyRewards.rewardIndex
	then
		local rewardIndex = getCurrentDayIndex(player, true)

		--	print("applyign Rewards for", rewardIndex)
		--self:ApplyReward(player, rewardIndex)
		local _reward = DAILYREWARDS_CONFIG.rewards[dailyRewards.rewardPathID][rewardIndex]
		rewardsManager.handleReward(player, _reward)

		local nextReward = rewardIndex + 1
		print(nextReward, dailyRewards.maxRewardIndex)
		if nextReward > dailyRewards.maxRewardIndex then
			dailyRewards = getDailyRewardsPath(player, true)
			--dailyRewards.rewardIndex = 1
			nextReward = 1
		else
			dailyRewards.rewardsClaimedIndex =
				math.clamp(dailyRewards.rewardsClaimedIndex + 1, 0, dailyRewards.maxRewardIndex)
		end

		dailyRewards.rewardIndex = nextReward
		dataWrapper.setDailyRewards(player, dailyRewards)

		return true, nextReward
	end

	return false, nil
end

--= Job API =--

--= Job Initializers =--
function daily:InitAsync(): nil
	--	print("called")
	replicator:listen("daily_reward", function(player: Player, action: string)
		if action == "getData" then
			local data = getDailyRewardsPath(player)
			return data
		elseif action == "claim" then
			return claimReward(player)
		end
	end)
end

function daily:PlayerAdded(player: Player)
	local lastCheck = workspace:GetServerTimeNow()
	troves[player] = trove.new()
	troves[player]:Add(runService.Heartbeat:Connect(function()
		local now = workspace:GetServerTimeNow()
		if now - lastCheck >= 0.1 and player and player.Parent ~= nil then
			lastCheck = now
			getCurrentDayIndex(player)
		end
	end))
end

function daily:PlayerRemoved(player: Player)
	if not troves[player] then
		return
	end

	troves[player]:Destroy()
	troves[player] = nil
end

--= Return Job =--
return daily
