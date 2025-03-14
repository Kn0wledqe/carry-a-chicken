--[[
    revive.lua
    Kn0wledqe
    Created on 03/03/2025 @ 22:08:26
    
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
local revive = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local death = requireInitialized(script.Parent.death)
local dataManager = requireInitialized("jobs/dataManager")

--= Classes =--

--= Modules & Config =--
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)

--= Roblox Services =--
local marketplacService = game:GetService("MarketplaceService")
local players = game:GetService("Players")

--= Object References =--
local localPlayer = players.LocalPlayer

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function initializeMoneyMakers(frame)
	local revives_5 = frame["1"]["Buy"]
	GUIManager.addHover(revives_5, nil, nil, true)
	GUIManager.addClick(revives_5, function()
		marketplacService:PromptProductPurchase(localPlayer, SHOP_CONFIG.DEV_PRODUCTS.REVIVES[5])
	end)

	local revives_15 = frame["2"]["Buy"]
	GUIManager.addHover(revives_15, nil, nil, true)
	GUIManager.addClick(revives_15, function()
		marketplacService:PromptProductPurchase(localPlayer, SHOP_CONFIG.DEV_PRODUCTS.REVIVES[15])
	end)

	local revives_50 = frame["3"]["Buy"]
	GUIManager.addHover(revives_50, nil, nil, true)
	GUIManager.addClick(revives_50, function()
		marketplacService:PromptProductPurchase(localPlayer, SHOP_CONFIG.DEV_PRODUCTS.REVIVES[50])
	end)
end

local function initailizeInfo(reviveFrame)
	local amountText = reviveFrame.Amount
	local format = "%s Revives"

	dataManager:listenOnChange("revives", function(new, old)
		amountText.Text = format:format(new)
	end)

	local revives = dataManager:get("revives") or 0
	amountText.Text = format:format(revives)
end

--= Job API =--

--= Job Initializers =--
function revive.initialize(HUD): nil
	local revivesFrame = HUD.Container.Frames:WaitForChild("Revives")
	revive.frame = revivesFrame
	initializeMoneyMakers(revivesFrame)
	initailizeInfo(revivesFrame)

	marketplacService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
		print(userId, productId, isPurchased)
		if productId ~= SHOP_CONFIG.DEV_PRODUCTS.REVIVES[1] then
			return
		end

		if not isPurchased then
			return
		end

		death.revive()
	end)

	GUIManager:registerGui(revivesFrame, revive)
end

function revive.onClosed(): nil end

--= Return Job =--
return revive
