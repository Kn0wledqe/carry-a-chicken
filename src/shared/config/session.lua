--[[
    session.lua
    Kn0wledqe
    Created on 03/01/2025 @ 16:59:24
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
--local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Classes =--

--= Roblox Services =--

--= Modules & Config =--

--= Object References =--

--= Constants =--

return {
	currentRewardID = "NEW2025",
	rewards = {
		["NEW2025"] = { -- 3/1
			{
				timemark = 0.75,
				reward = {
					type = "COINS",
					amount = 35,
				},
			},
			{
				timemark = 2.5,
				reward = {
					type = "REVIVES",
					amount = 1,
				},
			},
			{
				timemark = 5,
				reward = {
					type = "SPINS",
					amount = 1,
				},
			},
			{
				timemark = 7.5,
				reward = {
					type = "COINS",
					amount = 100,
				},
			},
			{
				timemark = 10,
				reward = {
					type = "SPINS",
					amount = 1,
				},
			},
			{
				timemark = 15,
				reward = {
					type = "REVIVES",
					amount = 1,
				},
			},
			{
				timemark = 30,
				reward = {
					type = "SPINS",
					amount = 2,
				},
			},
			{
				timemark = 45,
				reward = {
					type = "REVIVES",
					amount = 4,
				},
			},
		},
	},
}
