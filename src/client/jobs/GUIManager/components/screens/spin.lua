--[[
    spin.lua
    Kn0wledqe
    Created on 03/01/2025 @ 01:40:18
    
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
local spin = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local dataManager = requireInitialized("jobs/dataManager")
local notificationManager = requireInitialized(script.Parent.Parent.notificationManager)
local replicator = requireInitialized("jobs/net/replicator")
local helperFunctions = requireInitialized("utils/helperFunctions")

--= Classes =--

--= Modules & Config =--
local WHEELSPIN_REWARDS = requireInitialized(game.ReplicatedStorage.config.wheelspin)
local SKINS_CONFIG = requireInitialized("$config/skins")
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)

local zonePlus = require(game.ReplicatedStorage.lib.zone)

--= Roblox Services =--
local marketplacService = game:GetService("MarketplaceService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

--= Object References =--
local localPlayer = players.LocalPlayer
local wheelPart = workspace:WaitForChild("Map"):WaitForChild("Spawn"):WaitForChild("WheelSpin")
local worldTrigger = wheelPart:WaitForChild("Trigger")
--= Constants =--

--= Variables =--

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

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function initializeMoneyMakers(buttons)
	GUIManager.addHover(buttons["10"], nil, nil, true)
	GUIManager.addClick(buttons["10"], function()
		marketplacService:PromptProductPurchase(localPlayer, SHOP_CONFIG.DEV_PRODUCTS.WHEEL_SPINS[10])
	end)

	GUIManager.addHover(buttons["5"], nil, nil, true)
	GUIManager.addClick(buttons["5"], function()
		marketplacService:PromptProductPurchase(localPlayer, SHOP_CONFIG.DEV_PRODUCTS.WHEEL_SPINS[5])
	end)
end

local function initailizeInfo(HUD, spinFrame)
	local openButton = HUD.Container.Screen.Top.Spins
	local amountText = openButton.Tag.TextLabel
	local spinButton = spinFrame.Spin.TextLabel
	--local proximityPrompt: ProximityPrompt = wheelPart:WaitForChild("Main"):WaitForChild("ProximityPrompt")

	--[[
	proximityPrompt.TriggerEnded:Connect(function(playerWhoTriggered)
		GUIManager:openGui("Spins")
	end)
	]]

	tweenService
		:Create(
			openButton.Effect,
			TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
			{ Rotation = 360 }
		)
		:Play()

	tweenService
		:Create(
			openButton.Parent.Revives.Effect,
			TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
			{ Rotation = 360 }
		)
		:Play()

	dataManager:listenOnChange("spins", function(new, old)
		amountText.Text = "x" .. new
		spinButton.Text = `Spin (x{new})`

		--proximityPrompt.ActionText = `Spin (x{new})`
	end)

	local spin = dataManager:get("spins") or 1
	amountText.Text = "x" .. spin
	spinButton.Text = `Spin (x{spin})`

	--proximityPrompt.ActionText = `Spin (x{spin})`
end

local function updateItems(wheel)
	local totalWeight = 0
	for _, reward in WHEELSPIN_REWARDS do
		totalWeight += reward.weight
	end

	for idx, reward in WHEELSPIN_REWARDS do
		local rewardItem = wheel[idx]

		if reward.amount then
			rewardItem.Amt.Text = reward.amount
		end

		rewardItem["%"].Text = math.floor((reward.weight / totalWeight) * 100) .. "%"

		rewardItem.Image = helperFunctions.getRewardIcon(reward.type)
		if reward.type == "SKINS" then
			local skinInfo = getSkinInfoFromID(reward.ID)

			rewardItem.Image = skinInfo.render_image
			rewardItem.Amt.Text = skinInfo.title
		end
	end

	--wheel 3d
	pcall(function()
		local wheelPart = wheelPart:WaitForChild("Wheel"):WaitForChild("Wheel"):WaitForChild("Frame")
		local newWheel = wheel:Clone()
		newWheel.Position = UDim2.fromScale(0.5, 0.5)
		newWheel.Parent = wheelPart
	end)
end

local function initaliizeSpin(spinFrame)
	local spinButton = spinFrame.Spin
	local wheel = spinFrame.Wheel
	local debounce = false
	local spin = function(info: { currentTime: number, time: number, rotation: number, reward: table })
		local tween = tweenService:Create(
			wheel,
			TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Rotation = info.rotation }
		)
		wheel.Rotation = 0
		tween:Play()
	end

	GUIManager.addHover(spinButton, nil, nil, true)
	GUIManager.addClick(spinButton, function()
		if debounce then
			return
		end
		debounce = true

		local successful, info = replicator:fetchFromServer("wheelspin_manager")
		if successful then
			spin(info)
			task.delay(info.time, function()
				debounce = false
			end)
		else
			notificationManager.notify(`⚠️ {info or "An error has occurred"} ⚠️`, nil, {
				["Content"] = {
					TextColor3 = Color3.fromRGB(221, 30, 75),
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
		end
	end)
end

local function initializeWorldTrigger()
	local zone = zonePlus.new(worldTrigger)
	zone.playerEntered:Connect(function(player)
		if player ~= localPlayer then
			return
		end
		GUIManager:openGui("Spins")
	end)

	zone.playerExited:Connect(function(player)
		if player ~= localPlayer then
			return
		end
		GUIManager:closeGui("Spins")
	end)
end

--= Job API =--

--= Job Initializers =--
function spin.initialize(HUD): nil
	local spinFrame = HUD.Container.Frames:WaitForChild("Spins")
	spin.frame = spinFrame

	initializeMoneyMakers(spinFrame)
	initailizeInfo(HUD, spinFrame)
	updateItems(spinFrame.Wheel)
	initaliizeSpin(spinFrame)
	initializeWorldTrigger()
	task.spawn(function()
		while task.wait(1) do
			local lastTime = dataManager:get("lastAwardedSpin")
			local timeSince = os.time() - lastTime
			local time = 24 * 60 * 60 - timeSince

			spinFrame.Time.Text = `Free spin in {formatTime(time)}`
		end
	end)

	GUIManager:registerGui(spinFrame, spin)
end

function spin.onClosed(): nil end

--= Return Job =--
return spin
