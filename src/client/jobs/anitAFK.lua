--[[
    anitAFK.lua
    Kn0wledqe
    Created on 03/15/2025 @ 13:22:58
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild('Infinity'))

--= Root =--
local anitAFK = { }

--= Jobs =--

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")

--= Object References =--
local localPlayer = players.LocalPlayer

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function anitAFK:InitAsync(): nil
    localPlayer.Idled:Connect(function(timeIdled)
		if timeIdled >= 1000 then
			teleportService:Teleport(game.GameId, localPlayer)
		end
	end)
end


--= Return Job =--
return anitAFK