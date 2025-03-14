--[[
    trolls.lua
    Kn0wledqe
    Created on 02/26/2025 @ 16:08:42
    
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
local trolls = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)

--= Classes =--

--= Modules & Config =--
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)
--= Roblox Services =--
local players = game:GetService("Players")
local marketplacService = game:GetService("MarketplaceService")
--= Object References =--
local localPlayer = players.LocalPlayer
--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end
--= Job API =--
local function initializeTrolls()
	local trolls = trolls.frame.Container

	for index, devproductid in SHOP_CONFIG.DEV_PRODUCTS.TROLLS do
		local button = trolls:FindFirstChild(index)
		if not button then
			continue
		end

		initializeButton(button, function()
			marketplacService:PromptProductPurchase(localPlayer, devproductid)
		end)
	end
end

--= Job Initializers =--
function trolls.initialize(HUD): nil
	local trollsFrame = HUD.Container.Frames:WaitForChild("Trolls")
	trolls.frame = trollsFrame
	initializeTrolls()
	GUIManager:registerGui(trollsFrame, trolls)
end

function trolls.onClosed(): nil end

--= Return Job =--
return trolls
