--[[
    dataWrapper [Job]
    Kn0wledqe
    Created on 02/29/2024 @ 22:52:50
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Root =--
local dataWrapper = {}

--= Jobs =--
local dataManager = require("jobs/data/dataManager")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

function dataWrapper.getDataStoreVersion()
	return dataManager:GetVersion()
end

function dataWrapper.getDailyRewards(Player: Player): table
	return dataManager:Get(Player, "dailyRewards")
end

function dataWrapper.setDailyRewards(Player: Player, newValue: table): nil
	dataManager:Set(Player, "dailyRewards", newValue, true)
end

--= VIP =--
function dataWrapper.hasVip(Player: Player): table
	return dataManager:Get(Player, "hasVip")
end

function dataWrapper.setVip(Player: Player, newValue: boolean): nil
	dataManager:Set(Player, "hasVip", newValue, true)
end

--= Cash =--
function dataWrapper.getCoins(Player: Player): number
	return dataManager:Get(Player, "coins")
end

function dataWrapper.addToCoins(Player: Player, newValue: number): nil
	dataManager:Set(Player, "coins", dataWrapper.getCoins(Player) + newValue, true)
end

function dataWrapper.setCoins(Player: Player, newValue: number): nil
	dataManager:Set(Player, "coins", newValue, true)
end

--= Spins =--
function dataWrapper.getSpins(Player: Player): number
	return dataManager:Get(Player, "spins")
end

function dataWrapper.addToSpins(Player: Player, newValue: number): nil
	dataManager:Set(Player, "spins", dataWrapper.getSpins(Player) + newValue, true)
end

function dataWrapper.setSpins(Player: Player, newValue: number): nil
	dataManager:Set(Player, "spins", newValue, true)
end

--= Revives =--
function dataWrapper.getRevives(Player: Player): number
	return dataManager:Get(Player, "revives")
end

function dataWrapper.addToRevives(Player: Player, newValue: number): nil
	dataManager:Set(Player, "revives", dataWrapper.getRevives(Player) + newValue, true)
end

function dataWrapper.setRevives(Player: Player, newValue: number): nil
	dataManager:Set(Player, "revives", newValue, true)
end

--= Nuke =--
function dataWrapper.getNukes(Player: Player): number
	return dataManager:Get(Player, "nukes")
end

function dataWrapper.addToNukes(Player: Player, newValue: number): nil
	dataManager:Set(Player, "nukes", dataWrapper.getNukes(Player) + newValue, true)
end

function dataWrapper.setNukes(Player: Player, newValue: number): nil
	dataManager:Set(Player, "nukes", newValue, true)
end

--= Wins =--
function dataWrapper.getWins(Player: Player): number
	return dataManager:Get(Player, "wins")
end

function dataWrapper.addToWins(Player: Player, newValue: number): nil
	dataManager:Set(Player, "wins", dataWrapper.getWins(Player) + newValue, true)
end

--= Infinite Revives =--
function dataWrapper.hasInfiniteRevives(Player: Player): boolean
	return dataManager:Get(Player, "infiniteRevives")
end

function dataWrapper.setInfiniteRevives(Player: Player, newValue: boolean): nil
	dataManager:Set(Player, "infiniteRevives", newValue, true)
end

--= Dobule Wing strength =--
function dataWrapper.setDoubleWingStrength(Player: Player, newValue: boolean): nil
	dataManager:Set(Player, "doubleWingStrength", newValue, true)
end

function dataWrapper.hasDoubleWingStrength(Player: Player): boolean
	return dataManager:Get(Player, "doubleWingStrength")
end

--= Potions =--
function dataWrapper.getPotions(Player: Player): number
	return dataManager:Get(Player, "potions")
end

function dataWrapper.getPotion(Player: Player, potionID): number
	return dataManager:Get(Player, "potions")[potionID]
end

function dataWrapper.addToPotion(Player: Player, potionID: number, newValue: number): nil
	local potions = dataWrapper.getPotions(Player)
	if not potions[potionID] then
		potions[potionID] = 0
	end
	potions[potionID] += newValue or 1

	dataManager:Set(Player, "potions", potions, true)
end

function dataWrapper.getPotionsEffects(Player: Player): table
	return dataManager:Get(Player, "effects")
end

function dataWrapper.addToPotionEffect(Player: Player, potionID: string): nil
	local potions = dataWrapper.getPotionsEffects(Player)
	if not potions[potionID] then
		potions[potionID] = 0
	end

	local difference = math.max(potions[potionID] - os.time(), 0)
	potions[potionID] = os.time() + 15 * 60 + difference

	dataManager:Set(Player, "effects", potions, true)
end

--= Purchase History =--
function dataWrapper.getPurchaseHistory(player: Player)
	return dataManager:Get(player, "purchaseHistory")
end

function dataWrapper.setPurchaseHistory(player: Player, newValue)
	dataManager:Set(player, "purchaseHistory", newValue, false)
end

function dataWrapper.insertPurchaseHistory(Player: Player, purchasedInfo): nil
	local purchaseHistory = dataWrapper.getPurchaseHistory(Player)
	table.insert(purchaseHistory, purchasedInfo)
	dataWrapper.setPurchaseHistory(Player, purchaseHistory)
end

--= Selected World =--
function dataWrapper.getUnlockedWorld(player: Player)
	return dataManager:Get(player, "worldCompleted")
end

function dataWrapper.setUnlockedWorld(player: Player, newValue : number)
	local current = dataWrapper.getUnlockedWorld(player)
	if current >= newValue then
		return 
	end

	dataManager:Set(player, "worldCompleted", newValue, false)
end

--= Gamepasses =--
function dataWrapper.getGamepasses(player: Player)
	return dataManager:Get(player, "gamepasses")
end

function dataWrapper.setGamepasses(player: Player, newValue)
	dataManager:Set(player, "gamepasses", newValue, false)
end

function dataWrapper.insertGamepasses(Player: Player, gamepassID): nil
	local gamepasses = dataWrapper.getGamepasses(Player)
	if table.find(gamepasses, gamepassID) then
		return false
	end

	table.insert(gamepasses, gamepassID)
	dataWrapper.setGamepasses(Player, gamepasses)
	return true
end

--= Weapons =--
function dataWrapper.getSkins(player: Player)
	return dataManager:Get(player, "skins")
end

function dataWrapper.setSkins(player: Player, newValue)
	dataManager:Set(player, "skins", newValue, true)
end

function dataWrapper.doesOwnSkin(player: Player, skinID: number): boolean
	local weapons = dataWrapper.getSkins(player)
	return table.find(weapons, skinID)
end

function dataWrapper.insertSkin(Player: Player, skinID): nil
	local skins = dataWrapper.getSkins(Player)
	if table.find(skins, skinID) then
		return false
	end

	table.insert(skins, skinID)
	dataWrapper.setSkins(Player, skins)
	return true
end

--= Equipped Weapon =--
function dataWrapper.getEquippedSkin(player: Player)
	return dataManager:Get(player, "equippedSkin")
end

function dataWrapper.setEquippedSkin(player: Player, newValue)
	if not dataWrapper.doesOwnSkin(player, newValue) then
		return false
	end

	dataManager:Set(player, "equippedSkin", newValue, true)
	return true
end

--= Return Job =--
return dataWrapper
