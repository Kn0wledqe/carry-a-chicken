--[[
    identifer.lua
    Kn0wledqe
    Created on 02/26/2025 @ 11:41:16
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--

--= Root =--

--= Jobs =--

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Initializers =--


return {
    isChicken = function(player : Player) : boolean
        player = player or players.LocalPlayer

        return player:GetAttribute("isChicken")
    end,

    isLinked = function(player : Player) : boolean
        player = player or players.LocalPlayer

        return player:GetAttribute("linked")
    end,


    isHolding = function(player : Player) : boolean
        player = player or players.LocalPlayer

        return player:GetAttribute("holding")
    end


}