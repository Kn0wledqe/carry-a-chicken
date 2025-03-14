--[[
    controlManager.lua
    Kn0wledqe
    Created on 02/26/2025 @ 12:00:50
    
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
local controlManager = {}

--= Jobs =--
local replicator = requireInitialized("replicator")

--= Classes =--
local linkedClass = requireInitialized("classes/linked")

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function controlManager:InitAsync(): nil
	replicator:listen("control_manager", function(player: Player, action)
		if not identiferFunctions.isChicken(player) then
			return
		end

		local linked = linkedClass.getClassByPlayer(player)
		if not linked then
			return
		end

		replicator:sendToPlayers("control_manager", { linked._players.player, linked._players.chicken }, "jump")
	end)
end

--= Return Job =--
return controlManager
