--[[
    purchaseManager.lua
    Kn0wledqe
    Created on 03/03/2025 @ 04:37:21
    
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
local purchaseManager = {}

--= Jobs =--
local replicator = requireInitialized("replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")
local trollManager = requireInitialized("jobs/trollManager")

--= Classes =--

--= Modules & Config =--
local SKINS_CONFIG = requireInitialized(game.ReplicatedStorage.config.skins)
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)

--= Roblox Services =--
local marketplaceService = game:GetService("MarketplaceService")
local players = game:GetService("Players")

--= Object References =--

--= Constants =--

--= Variables =--
local productConfig = {
	[SHOP_CONFIG.DEV_PRODUCTS.TROLLS.FART] = function(player: Player)
		trollManager.fart()
	end,

	[SHOP_CONFIG.DEV_PRODUCTS.TROLLS.FOG] = function(player: Player)
		trollManager.fog()
	end,

	[SHOP_CONFIG.DEV_PRODUCTS.TROLLS.NUKE] = function(player: Player)
		trollManager.nuke()
	end,

	[SHOP_CONFIG.DEV_PRODUCTS.TROLLS.MEME] = function(player: Player)
		trollManager.randomMemeSound()
	end,

	[SHOP_CONFIG.DEV_PRODUCTS.POTIONS.low_gravity] = function(player: Player)
		dataWrapper.addToPotionEffect(player, "low_gravity")
	end,

	[SHOP_CONFIG.DEV_PRODUCTS.POTIONS.speed_boost] = function(player: Player)
		dataWrapper.addToPotionEffect(player, "speed_boost")
	end,
}
local gamepassConfig = {
	[SHOP_CONFIG.GAMEPASSES.STARTERPACK] = function(player: Player) -- starter pack
		if dataWrapper.doesOwnSkin(player, 6) then
			return
		end

		dataWrapper.addToRevives(player, 3)
		dataWrapper.addToCoins(player, 1000)
		dataWrapper.insertSkin(player, 6)
	end,

	[SHOP_CONFIG.GAMEPASSES.VIP] = function(player: Player) -- vip
		player:SetAttribute("hasVip", true)

		if dataWrapper.doesOwnSkin(player, 5) then
			print("owns")
			return
		end

		dataWrapper.setVip(player, true)
		dataWrapper.insertSkin(player, 5)
	end,

	[SHOP_CONFIG.GAMEPASSES.INFINITE_REVIVES] = function(player: Player) -- infinite revives
		dataWrapper.setInfiniteRevives(player, true)
	end,

	[SHOP_CONFIG.GAMEPASSES.DOUBLE_WING_STRENGTH] = function(player: Player) -- double wing strength
		player:SetAttribute("doubleWingStrength", true)
		dataWrapper.setDoubleWingStrength(player, true)
	end,
}

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function purchaseManager:InitAsync(): nil
	for _, skinData in SKINS_CONFIG do
		if not skinData.purchaseable or not skinData.gamepassID then
			continue
		end

		if gamepassConfig[skinData.gamepassID] then
			continue
		end

		--[[
		local template = {
			ID = skinData.ID,
			gamepassID = skinData.gamepassID,
			callback = function(player: Player)
				dataWrapper.addToCash(player, cashData.quantity)
			end,
		}
        ]]

		gamepassConfig[skinData.gamepassID] = function(player: Player)
			dataWrapper.insertSkin(player, skinData.ID)
		end
	end

	--= Spins =--
	for amount, id in SHOP_CONFIG.DEV_PRODUCTS.WHEEL_SPINS do
		productConfig[id] = function(player: Player)
			dataWrapper.addToSpins(player, amount)
		end
	end

	--= Revives =--
	for amount, id in SHOP_CONFIG.DEV_PRODUCTS.REVIVES do
		productConfig[id] = function(player: Player)
			dataWrapper.addToRevives(player, amount)
		end
	end

	--= Coins =--
	for amount, id in SHOP_CONFIG.DEV_PRODUCTS.COINS do
		productConfig[id] = function(player: Player)
			dataWrapper.addToCoins(player, amount)
		end
	end

	marketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if not wasPurchased then
			return
		end

		local gamepassInfo = gamepassConfig[gamePassId]
		if not gamepassInfo then
			return
		end

		gamepassInfo(player)
	end)

	marketplaceService.ProcessReceipt = function(receiptInfo)
		local player = players:GetPlayerByUserId(receiptInfo.PlayerId)
		local productID = receiptInfo.ProductId

		if not player then
			return
		end

		local callback = productConfig[receiptInfo.ProductId]
		if not callback then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local success, successfulPurchase, errorMessage = pcall(function()
			local user = player

			callback(user)

			dataWrapper.insertPurchaseHistory(player, {
				purchasedID = receiptInfo.ProductId,
				purchaseDate = os.time(),
				cost = receiptInfo.CurrencySpent,
			})

			return true
		end)

		if not success or not successfulPurchase then
			replicator:sendToPlayer("sound_manager", player, "Error")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		else
			replicator:sendToPlayer("sound_manager", player, "Purchase")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end

function purchaseManager:PlayerAdded(player: Player)
	for gamepassID, func in gamepassConfig do
		pcall(function()
			if not marketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassID) then
				return
			end

			func(player)
		end)
	end
end

--= Return Job =--
return purchaseManager
