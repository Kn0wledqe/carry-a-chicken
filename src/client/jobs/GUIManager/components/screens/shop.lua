--[[
    shop.lua
    Kn0wledqe
    Created on 02/28/2025 @ 14:21:46
    
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
local shop = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local soundManager = requireInitialized("jobs/soundManager")
local dataManager = requireInitialized("jobs/dataManager")

--= Classes =--

--= Modules & Config =--
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)
local SKINS_CONFIG = requireInitialized(game.ReplicatedStorage.config.skins)

local zonePlus = require(game.ReplicatedStorage.lib.zone)

--= Roblox Services =--
local tweenService = game:GetService("TweenService")
local marketplacService = game:GetService("MarketplaceService")
local players = game:GetService("Players")

--= Object References =--
local localPlayer = players.LocalPlayer
--[[
local proximityPrompt = workspace
	:WaitForChild("Map")
	:WaitForChild("Spawn")
	:WaitForChild("Shop")
	:WaitForChild("Main")
	:WaitForChild("ProximityPrompt")
	]]
local trigger = workspace:WaitForChild("Map"):WaitForChild("Spawn"):WaitForChild("Shop"):WaitForChild("Trigger")

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

local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end

local function initializeQuickNavigationButtons()
	local buttons = shop.frame.Buttons
	initializeButton(buttons.Coins, function()
		shop.openAndScrollTo("COINS")
	end)
	initializeButton(buttons.Deals, function()
		shop.openAndScrollTo("DEALS")
	end)
	initializeButton(buttons.Passes, function()
		shop.openAndScrollTo("PASSES")
	end)
end

local function initializeCoins()
	local coinsHolders = shop.frame.Container.Coins

	for _, coinHolder in coinsHolders:GetChildren() do
		local amount = coinHolder.Name
		local gamepassID = SHOP_CONFIG.DEV_PRODUCTS.COINS[tonumber(amount)]

		initializeButton(coinHolder.Buy, function()
			marketplacService:PromptProductPurchase(localPlayer, gamepassID)
		end)
	end
end

local function initializeSkins()
	local skinHolders = shop.frame.Container.Gamepasses.Skins

	for _, skinHolder in skinHolders:GetChildren() do
		local ID = tonumber(skinHolder.Name)
		local skinInfo = getSkinInfoFromID(ID)

		if not skinInfo then
			continue
		end

		skinHolder.ImageLabel.Image = skinInfo.render_image

		initializeButton(skinHolder.Buy, function()
			marketplacService:PromptGamePassPurchase(localPlayer, skinInfo.gamepassID)
		end)
	end
end

local function initializeGamepasses(hud)
	local container = shop.frame.Container
	local starterpack = container.Starterpack
	local gamepasses = container.Gamepasses

	initializeButton(starterpack.Buy, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.STARTERPACK)
	end)

	initializeButton(gamepasses.VIP.Buy, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.VIP)
	end)
	initializeButton(hud.Container.Screen.Deals.VIP, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.VIP)
	end)

	initializeButton(gamepasses.InfiniteRevives.Buy, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.INFINITE_REVIVES)
	end)
	initializeButton(hud.Container.Screen.Deals.infiniteRevives, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.INFINITE_REVIVES)
	end)

	initializeButton(gamepasses.DoubleWingStrength.Buy, function()
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.DOUBLE_WING_STRENGTH)
	end)

	initializeButton(hud.Container.Screen.Deals.infiniteRevives, function() -- place mine
		marketplacService:PromptGamePassPurchase(localPlayer, SHOP_CONFIG.GAMEPASSES.INFINITE_REVIVES)
	end)
end

local function initializeWorldTrigger()
	local zone = zonePlus.new(trigger)
	zone.playerEntered:Connect(function(player)
		if player ~= localPlayer then
			return
		end
		GUIManager:openGui("Shop")
	end)

	zone.playerExited:Connect(function(player)
		if player ~= localPlayer then
			return
		end
		GUIManager:closeGui("Shop")
	end)
end

--= Job API =--
function shop.openAndScrollTo(target)
	local targetFrame = nil

	if target == "COINS" then
		targetFrame = shop.frame.Container.Coins["7500"]
	elseif target == "DEALS" then
		targetFrame = shop.frame.Container.Starterpack
	elseif target == "PASSES" then
		targetFrame = shop.frame.Container.Coins["7500"]
	end

	if not targetFrame then
		return
	end

	local scrollingFrame = shop.frame.Container
	soundManager:playSound("Back")
	local relativeAbsoluteOffset = targetFrame.AbsolutePosition.Y
		- scrollingFrame.AbsolutePosition.Y
		- targetFrame.AbsoluteSize.Y
	GUIManager:openGui("Shop")
	tweenService
		:Create(scrollingFrame, TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(
				scrollingFrame.AbsolutePosition.X,
				scrollingFrame.CanvasPosition.Y + relativeAbsoluteOffset
			),
		})
		:Play()
end

--= Job Initializers =--
function shop.initialize(HUD): nil
	local shopFrame = HUD.Container.Frames:WaitForChild("Shop")
	shop.frame = shopFrame

	initializeQuickNavigationButtons()
	initializeCoins()
	initializeSkins()
	initializeGamepasses(HUD)
	initializeWorldTrigger()
	--[[
	proximityPrompt.TriggerEnded:Connect(function()
		GUIManager:openGui("Shop")
	end)
	]]

	GUIManager:registerGui(shopFrame, shop)
end

function shop.onClosed(): nil end

--= Return Job =--
return shop
