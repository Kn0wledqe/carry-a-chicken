--[[
    skinManager.lua
    Kn0wledqe
    Created on 02/28/2025 @ 18:11:09
    
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
local skinManager = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--
local SKINS_CONFIG = requireInitialized("$config/skins")

--= Variables =--

--= Shorthands =--

--= Functions =--
local function getSkinByID(id)
	for _, skin in SKINS_CONFIG do
		if skin.id ~= id then
			continue
		end

		return skin
	end
end

--= Job API =--

--= Job Initializers =--
function skinManager:InitAsync(): nil
	replicator:listen("skin_manager", function(client: Player, action, skinID)
		if action == "purchase" then
			local skin = getSkinByID(skinID)
			if not skin then
				return false, "An Unknown Error occured"
			end

			if dataWrapper.doesOwnSkin(client) then
				return false, "You already own this skin!"
			end

			if not skin.purchaseable then
				return false, "An UNknown Error occured"
			end

			if skin.gamepassID then
				return false, "An UnKnown Error occured"
			end

			local coins = dataWrapper.getCoins(client)
			if coins - skin.price < 0 then
				return false, "You do not have enough coins to complete this purchase"
			end

			dataWrapper.addToCoins(client, skin.price)
			dataWrapper.insertSkin(client, skinID)

			return true
		elseif action == "equip" then
			local successful = dataWrapper.setEquippedSkin(client, skinID)
			return successful
		end
	end)
end

--= Return Job =--
return skinManager
