--[[
    favoriteManager.lua
    Kn0wledqe
    Created on 03/15/2025 @ 16:13:45
    
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
local favoriteManager = {}

--= Jobs =--
local replicator = requireInitialized("replicator")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")


--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function hasFavorited(userID)
	local sucess, request = pcall(function()
		return httpService:GetAsync(
			`https://www.roproxy.com/users/favorites/list-json?assetTypeId=9&itemsPerPage=100&pageNumber=1&userId={userID}`
		)
	end)

	if not sucess then
		return true
	end

	request = httpService:JSONDecode(request)
	for _, item in request.Data.Items do
		if item.Item.AssetId == game.PlaceId then
			return true
		end

		continue
	end

	return false
end

--= Job API =--

--= Job Initializers =--
function favoriteManager:InitAsync(): nil
	while task.wait(4 * 60) do
		for _, player in players:GetPlayers() do
            if hasFavorited(player.UserId) then
                continue
            end

            replicator:sendToPlayer("favorite_manager", player)
		end
	end
end

--= Return Job =--
return favoriteManager
