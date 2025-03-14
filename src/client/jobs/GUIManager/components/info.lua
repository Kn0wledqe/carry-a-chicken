--[[
    info.lua
    Kn0wledqe
    Created on 03/01/2025 @ 13:23:57
    
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
local info = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent)
local shopScreen = requireInitialized(script.Parent.screens.shop)
local dataManager = requireInitialized("jobs/dataManager")
local soundManager = requireInitialized("jobs/soundManager")

local itemGainAnimation = requireInitialized(script.Parent.Parent.utils.itemGainAnim)

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--
local coinIcon = replicatedStorage:WaitForChild("assets"):WaitForChild("gui"):WaitForChild("CoinIcon")
local heartIcon = replicatedStorage:WaitForChild("assets"):WaitForChild("gui"):WaitForChild("HeartIcon")
local spinIcon = replicatedStorage:WaitForChild("assets"):WaitForChild("gui"):WaitForChild("SpinIcon")

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function initializeCoinTopBar(HUD)
	local coinBar = HUD.Container.Screen.Top.Coins

	dataManager:listenOnChange("coins", function(value, oldValue)
		local difference = value - oldValue
		local amount = math.ceil(math.clamp(difference / 5, 10, 20))
		local currentAmount = oldValue
		print(difference)
		if difference > 0 then
			itemGainAnimation(coinBar.ImageLabel, coinIcon, function()
				currentAmount += amount
				coinBar.TextLabel.Text = math.min(currentAmount, value)

				soundManager:playSound("CoinCollect", { Volume = 25 })
			end, { amountOfSpawnedItems = amount, scaleTargetOnReached = true, yield = true })
		end

		coinBar.TextLabel.Text = value
	end)
	coinBar.TextLabel.Text = dataManager:get("coins")

	GUIManager.addHover(coinBar.Buy, nil, nil, true)
	GUIManager.addClick(coinBar.Buy, function()
		shopScreen.openAndScrollTo("COINS")
	end)
end

local function initializeItemGainAnimations(HUD)
	local heartTarget = HUD.Container.Screen.Top.Revives.ImageLabel
	local spinTarget = HUD.Container.Screen.Top.Spins.ImageLabel

	dataManager:listenOnChange("revives", function(value, oldValue)
		local difference = value - oldValue
		local amount = math.ceil(math.clamp(difference / 5, 5, 10))

		if difference > 0 then
			itemGainAnimation(heartTarget, heartIcon, function()
				soundManager:playSound("HeartCollect", { Volume = 25 })
			end, { amountOfSpawnedItems = amount, scaleTargetOnReached = true, yield = false })
		end
	end)

	dataManager:listenOnChange("spins", function(value, oldValue)
		local difference = value - oldValue
		local amount = math.ceil(math.clamp(difference / 5, 5, 10))

		if difference > 0 then
			itemGainAnimation(
				spinTarget,
				spinIcon,
				nil,
				{ amountOfSpawnedItems = amount, scaleTargetOnReached = true, yield = true }
			)
		end
	end)
end
--= Job Initializers =--
function info.initialize(HUD): nil
	initializeCoinTopBar(HUD)
	initializeItemGainAnimations(HUD)
end

--= Return Job =--
return info
