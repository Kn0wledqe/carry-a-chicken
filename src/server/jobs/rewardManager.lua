--[[
    rewardManager.lua
    Kn0wledqe
    Created on 03/01/2025 @ 00:23:06
    
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
local rewardManager = {}

--= Jobs =--
local dataWrapper = requireInitialized("jobs/data/dataWrapper")
--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function rewardManager.handleReward(player: Player, reward): nil
	--print(player, reward)
	if reward.type == "COINS" then
		dataWrapper.addToCoins(player, reward.amount)
	elseif reward.type == "POTION" then
		dataWrapper.addToPotion(player, reward.ID, reward.amount)
	elseif reward.type == "SKINS" then
		
		dataWrapper.insertSkin(player, reward.ID)
	elseif reward.type == "REVIVES" then
		dataWrapper.addToRevives(player, reward.amount)
	elseif reward.type == "SPINS" then
		dataWrapper.addToSpins(player, reward.amount)
	end
end

--= Return Job =--
return rewardManager
