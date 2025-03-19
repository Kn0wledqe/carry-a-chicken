--[[
    badgeManager.lua
    Kn0wledqe
    Created on 03/09/2025 @ 22:44:09
    
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
local badgeManager = {}

--= Jobs =--

--= Classes =--

--= Roblox Services =--
local badgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
--= Modules & Config =--
local badge = requireInitialized(replicatedStorage.config.badges)
--= Object References =--

--= Constants =--
local DEVELOPER_USERIDS = {
	2024411780,
	1826347804,
	3891429115,
	1342592770,
}

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function badgeManager.awardBadge(player: Player, name: string)
	local badgeID = badge[name]
	if not badgeID then
		return
	end

	pcall(function()
		badgeService:AwardBadge(player.UserId, badgeID)
	end)
end


--= Job Initializers =--
function badgeManager:InitAsync(): nil
	game.Players.PlayerAdded:Connect(function(player)
		local hasDeveloper = false
		for _, player: Player in game.Players:GetPlayers() do
			--print(player.UserId, player, table.find(DEVELOPER_USERIDS, player.UserId))
			if not table.find(DEVELOPER_USERIDS, player.UserId) then
				continue
			end

			hasDeveloper = true
			break

			
		end

		if not hasDeveloper then
			return
		end

		for _, player in Players:GetPlayers() do
			badgeManager.awardBadge(player, "MEET_A_DEVELOPER")
		end
	end)
end

function badgeManager:PlayerAdded(player: Player): nil
	badgeService:AwardBadge(player.UserId, badge.WELCOME)
end

--= Return Job =--
return badgeManager
