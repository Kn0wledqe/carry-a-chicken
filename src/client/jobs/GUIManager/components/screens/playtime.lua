--[[
    playtime.lua
    Kn0wledqe
    Created on 03/01/2025 @ 16:55:02
    
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
local playtime = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local replicator = requireInitialized("jobs/net/replicator")
local notificationManager = requireInitialized(script.Parent.Parent.notificationManager)
local soundManager = requireInitialized("jobs/soundManager")
local helperFunctions = requireInitialized("utils/helperFunctions")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local runService = game:GetService("RunService")

--= Object References =--

--= Constants =--
local CLAIM_BUTTON_PROPERTIES = {
	CLAIMABLE = {
		Image = "rbxassetid://125799463084857",
	},
	NON_CLAIMABLE = {
		Image = "rbxassetid://114528142665401",
	},
}

--= Variables =--

--= Shorthands =--

--= Functions =--
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

local function setProperties(button, properties)
	for property, value in properties do
		button[property] = value
	end
end

local function refreshRewards()
	for index, rewardInfo in playtime.rewards do
		local timeLeft = math.max(rewardInfo.rewardedIn - workspace:GetServerTimeNow(), 0)
		local holder = rewardInfo.instance
		holder.Claim.Visible = true

		setProperties(holder.Claim, CLAIM_BUTTON_PROPERTIES.CLAIMABLE)
		if rewardInfo.claimed then
			holder.Claim.TextLabel.Text = "Claimed"
			holder.Claim.Interactable = false
			holder.Claim:SetAttribute("_claimable", false)
		elseif timeLeft == 0 then
			holder.Claim.TextLabel.Text = "Claim!"
			holder.Claim.Interactable = true
			holder.Claim:SetAttribute("_claimable", true)
		else
			setProperties(holder.Claim, CLAIM_BUTTON_PROPERTIES.NON_CLAIMABLE)
			local format = if timeLeft >= (60 * 60)
				then formatToHMS(math.ceil(timeLeft))
				else formatToMS(math.ceil(timeLeft))

			holder.Claim.TextLabel.Text = format
			--[[
            

			local scale = 1
			if timeLeft ~= 0 then
				scale = 1 - timeLeft / rewardInfo.timemark
			end
]]
			-- holder.TimerOverlay.TimerBar.Bar.Size = UDim2.fromScale(scale, 1)
			holder.Claim.Interactable = false
			holder.Claim:SetAttribute("_claimable", false)
		end
	end
end

--= Job API =--

--= Job Initializers =--
function playtime.initialize(HUD): nil
	local playtimeFrame = HUD.Container.Frames:WaitForChild("Playtime")
	playtime.frame = playtimeFrame

	local button = HUD.Container.Screen.Buttons["2"].Playtime

	repeat
		task.wait(1)
		playtime.rewards = replicator:fetchFromServer("session_reward", "getData")
	until playtime.rewards

	for i, rewardInfo in playtime.rewards do
		local gift = playtimeFrame.Rewards[i]
		gift.LayoutOrder = i
		gift.ImageLabel.Image = helperFunctions.getRewardIcon(rewardInfo.reward.type)
		gift.TextLabel.Text = rewardInfo.reward.amount
		gift.Claim.Interactable = false
		local debounce = false
		GUIManager.addClick(gift.Claim, function()
			if not gift.Claim:GetAttribute("_claimable") then
				return
			end

			if rewardInfo.claimed then
				return
			end

			if debounce then
				return
			end

			debounce = true

			local successful = replicator:fetchFromServer("session_reward", "claim", i)

			if successful then
				rewardInfo.claimed = true
				soundManager:playSound("Purchase")
			else
				soundManager:playSound("Error")
			end

			debounce = false
		end, true)

		rewardInfo.instance = gift
	end

	--[[
	local parent = sessionRewardsFrame.Clip.Items
	helperFunctions.cleanChildren(parent, { "BottomSpacer" })
	for index, rewardInfo in playtime.rewards do
		local gift = giftGUI:Clone()
		gift.LayoutOrder = index
		styleGUI.rewardHolder(gift, rewardInfo.reward)

		gift.ClaimButton.Interactable = false
		local debounce = false
		GUIManager.addClick(gift.ClaimButton, function()
			if not gift.ClaimButton:GetAttribute("_claimable") then
				return
			end

			if rewardInfo.claimed then
				return
			end

			if debounce then
				return
			end

			debounce = true

			local successful = replicator:fetchFromServer("session_reward", "claim", index)
			print(successful)
			if successful then
				rewardInfo.claimed = true
				soundManager:playSound("Purchase")
			else
				soundManager:playSound("Error")
			end

			debounce = false
		end, true)

		rewardInfo.instance = gift
		gift.Parent = parent
	end
    ]]

	local function giftIconStyle()
		local closestReward, closestIdx, claimableRewards = math.huge, nil, false
		for idx, reward in playtime.rewards do
			if reward.claimed then
				continue
			end

			local timeLeft = math.max(reward.rewardedIn - workspace:GetServerTimeNow(), 0)
			if timeLeft == 0 then
				claimableRewards = true
				continue
			end

			if timeLeft < closestReward then
				closestReward = timeLeft
				closestIdx = idx
			end
		end

		--sessionRewardsButton.Notif.Visible = claimableRewards
		if claimableRewards then
			button.Timer.Text = "READY!"
		else
			local format = if closestReward >= (60 * 60)
				then formatToHMS(math.ceil(closestReward))
				else formatToMS(math.ceil(closestReward))

			button.Timer.Text = format
		end

		--	sessionRewardsButton.Timer.Text = format

		return claimableRewards, closestIdx
	end

	local lastTick = os.clock()
	local lastNotificationIndex
	runService.RenderStepped:Connect(function()
		local now = os.clock()
		if now - lastTick < 0.1 then
			return
		end
		lastTick = now

		local claimable, closestIdx = giftIconStyle()

		if GUIManager.getCurrentOpened(GUIManager) ~= playtimeFrame.Name then
			if claimable and lastNotificationIndex ~= closestIdx then
				notificationManager.notify("🎁 New playtime gift ready! 🎁", nil, {
					["Content"] = {
						TextColor3 = Color3.fromRGB(75, 255, 96),
						RichText = false,
					},
					["Content/UIStroke"] = {
						Thickness = 2,
						Color = Color3.fromRGB(0, 0, 0), --Color3.fromRGB(41, 141, 53),
					},
					["Content/UIGradient"] = {
						Enabled = false,
					},
				})
				lastNotificationIndex = closestIdx
			end

			return
		end

		refreshRewards()
	end)

	GUIManager:registerGui(playtimeFrame, playtime)
end

function playtime.onClosed(): nil end

--= Return Job =--
return playtime
