--[[
    daily.lua
    Kn0wledqe
    Created on 03/02/2025 @ 15:08:18
    
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
local daily = {}

--= Jobs =--
local topBarGui = requireInitialized("$lib/icon")
local soundManager = requireInitialized("jobs/soundManager")
local replicator = requireInitialized("jobs/net/replicator")
local dataManager = requireInitialized("jobs/dataManager")
local GUIManager = requireInitialized(script.Parent.Parent.Parent)

--= Classes =--

--= Modules & Config =--
local DAILYREWARDS_CONFIG = requireInitialized("$config/daily")
local SKINS_CONFIG = requireInitialized("$config/skins")
local helperFunctions = requireInitialized("utils/helperFunctions")

--= Roblox Services =--
local socialService = game:GetService("SocialService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

--= Object References =--
local localPlayer = players.LocalPlayer

--= Constants =--
local HOURS_24 = runService:IsStudio() and 15 or 60 * 60 * 24

local CLAIM_BUTTON_PROPERTIES = {
	CLAIMABLE = {
		Image = "rbxassetid://125799463084857",
	},
	NON_CLAIMABLE = {
		Image = "rbxassetid://114528142665401",
	},
}

--= Variables =--
local rewardHolders

--= Shorthands =--

--= Functions =--
local function getSkinInfoFromID(id)
	for _, info in SKINS_CONFIG do
		if info.ID ~= id then
			continue
		end

		return info
	end
end

local function setProperties(button, properties)
	for property, value in properties do
		button[property] = value
	end
end

local function formatToHMS(seconds)
	local minutes = (seconds - seconds % 60) / 60
	seconds = seconds - minutes * 60
	local hours = (minutes - minutes % 60) / 60
	minutes = minutes - hours * 60

	return string.format("%02i:%02i:%02i", hours, minutes, seconds)
end

local function formatToMS(Seconds)
	local SS = Seconds % 60
	local MM = (Seconds - SS) / 60
	return string.format("%02i:%02i", MM, SS)
	--return MM .. ":" .. (10 > SS and "0" .. SS or SS)
end

local function refreshRewards()
	local data = dataManager:get("dailyRewards")
	local rewards = DAILYREWARDS_CONFIG.rewards[data.rewardPathID]

	--local weekIndex = rewards

	for idx, reward in rewards do
		local holder = rewardHolders[idx]

		if reward.amount then
			holder.TextLabel.Text = reward.amount
		end

		holder.ImageLabel.Image = helperFunctions.getRewardIcon(reward.type)
		if reward.type == "SKINS" then
			local skinInfo = getSkinInfoFromID(reward.ID)

			holder.ImageLabel.Image = skinInfo.render_image or ""
			holder.TextLabel.Text = skinInfo.title
		end
		--styleGUI.rewardHolder(holder, reward)

		local timeDifference = workspace:GetServerTimeNow() - data.rewardTick
		local hoursIndex = (HOURS_24 * idx)
		setProperties(holder.Claim, CLAIM_BUTTON_PROPERTIES.CLAIMABLE)
		if idx <= data.rewardsClaimedIndex then
			holder.Claim.TextLabel.Text = "Claimed"
			holder.Claim.Interactable = false
			holder.Claim:SetAttribute("_claimable", false)
		elseif timeDifference >= hoursIndex then -- data.rewardIndex == idx and
			holder.Claim.TextLabel.Text = "Claim!"
			holder.Claim.Interactable = true
			holder.Claim:SetAttribute("_claimable", true)
		elseif timeDifference <= hoursIndex then
			local seconds = math.max(hoursIndex - timeDifference, 0)
			setProperties(holder.Claim, CLAIM_BUTTON_PROPERTIES.NON_CLAIMABLE)
			if seconds > HOURS_24 then
				holder.Claim.TextLabel.Text = "Day " .. idx
				continue
			end

			local format = if seconds >= (60 * 60)
				then formatToHMS(math.ceil(seconds))
				else formatToMS(math.ceil(seconds))

			holder.Claim.TextLabel.Text = format
			holder.Claim.Interactable = false
			holder.Claim:SetAttribute("_claimable", false)
		end
	end
end

--#region friend stuff
local function _canSendGameInvite(sendingPlayer)
	local success, canSend = pcall(function()
		return socialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

local function _promptFriends()
	local canInvite = _canSendGameInvite(localPlayer)
	if not canInvite then
		return
	end

	socialService:PromptGameInvite(localPlayer)
end
--#endregion

--= Job API =--

--= Job Initializers =--
function daily.initialize(HUD): nil
	local dailyFrame = HUD.Container.Frames:WaitForChild("Daily")
	daily.frame = dailyFrame

	GUIManager.initializeFrame("Daily")

	local dailyRewardsTab = topBarGui.new():setImage("rbxassetid://134175662556491") --:setLabel("Daily Gifts")
	dailyRewardsTab.selected:Connect(function()
		GUIManager:openGui("Daily")
	end)

	local friendsTab = topBarGui.new():setImage("rbxassetid://110845292682416")
	friendsTab.selected:Connect(_promptFriends)

	--[[
	local view
	dailyRewardsTab.stateChanged:Connect(function(state)
		if state == "Viewing" then
			view = true
		else
			dailyRewardsTab:setLabel("Daily Gifts")
			view = false
		end
		--	print(state)
	end)
	]]

	rewardHolders = {}
	local items = dailyFrame:WaitForChild("Rewards")
	for i = 1, 7, 1 do
		table.insert(rewardHolders, items:FindFirstChild(i))
	end

	for _, rewardHolder in rewardHolders do
		rewardHolder.Claim.Interactable = false
		local debounce = false
		GUIManager.addClick(rewardHolder.Claim, function()
			print("called")
			if not rewardHolder.Claim:GetAttribute("_claimable") then
				return
			end

			if debounce then
				return
			end
			print("rawr")
			debounce = true

			local successful, nextReward = replicator:fetchFromServer("daily_reward", "claim")
			--print(successful, nextReward)
			if successful then
				soundManager:playSound("Purchase")
				--refreshData()
			else
				soundManager:playSound("Error")
			end

			debounce = false
		end, true)
	end

	--refreshData()
	repeat
		task.wait()
	until dataManager.loaded

	local lastTick = os.clock()

	runService.RenderStepped:Connect(function()
		local now = os.clock()
		if now - lastTick < 0.1 then
			return
		end
		lastTick = now

		if view then
			local data = dataManager:get("dailyRewards")

			local timeDifference = workspace:GetServerTimeNow() - data.rewardTick
			local hoursIndex = (HOURS_24 * data.rewardIndex)

			-- print(timeDifference)

			local seconds = math.max(hoursIndex - timeDifference, 0)
			local format = if seconds >= (60 * 60)
				then formatToHMS(math.ceil(seconds))
				else formatToMS(math.ceil(seconds))
			print(format)
			dailyRewardsTab:setLabel(format)
		end

		if GUIManager.getCurrentOpened(GUIManager) ~= dailyFrame.Name then
			return
		end

		refreshRewards()
	end)

	GUIManager:registerGui(dailyFrame, daily)

	task.delay(5, function()
		GUIManager:openGui(dailyFrame.Name)
	end)
end

--= Return Job =--
return daily
