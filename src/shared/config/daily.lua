--[[
    daily.lua
    Kn0wledqe
    Created on 03/02/2025 @ 15:14:44
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
--local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Classes =--

--= Roblox Services =--
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Modules & Config =--

--= Object References =--

--= Constants =--

return {
	currentRewardID = "NEW2025",
	rewards = {

		["NEW2025"] = {
			{
				type = "COINS",
				amount = 50,
			},
			{
				type = "SKINS",

				ID = 2,
			},
			{
				type = "REVIVES",
				amount = 1,
			},
			{
				type = "COINS",
				amount = 250,
			},
			{
				type = "SPINS",
				amount = 2,
			},
			{
				type = "COINS",
				amount = 500,
			},
			{
				type = "SKINS",

				ID = 7,
			},
		},
		--[[
		["NEW2025"] = { -- 3/1
			{
				type = "COINS",
				amount = 25,
			},
			{
				type = "COINS",
				amount = 75,
			},
			{
				type = "COINS",
				amount = 125,
			},
			{
				type = "COINS",
				amount = 175,
			},
			{
				type = "COINS",
				amount = 225,
			},
			{
				type = "COINS",
				amount = 275,
			},
			{
				type = "COINS",
				amount = 375,
			},

		},]]
	},
}
