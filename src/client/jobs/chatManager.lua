--[[
    chatManager.lua
    Kn0wledqe
    Created on 08/25/2024 @ 19:03:54
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Root =--
local chatManager = {}

--= Jobs =--

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local textChatService = game:GetService("TextChatService")
local players = game:GetService("Players")

--= Object References =--

--= Constants =--
local customTags = {
	["<font color='#ff0000'>[Developer]</font>"] = {
		2024411780,
		1826347804,
		3891429115,
		1342592770,
	},
}

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function chatManager:InitAsync(): nil
	-- #FFB806

	textChatService.OnIncomingMessage = function(textChatMessage: TextChatMessage)
		local textChatMessageProperties = Instance.new("TextChatMessageProperties")

		if textChatMessage.TextSource then
			local tag = ""
			local player = players:GetPlayerByUserId(textChatMessage.TextSource.UserId)

			if player:GetAttribute("hasVip") then
				tag = "<font color='#ffb806'>[⭐VIP]</font>"
			end

			for _tag, holders in customTags do
				if not table.find(holders, textChatMessage.TextSource.UserId) then
					continue
				end

				tag = _tag
			end

			if tag then
				tag ..= " "
			end

			textChatMessageProperties.PrefixText = tag .. textChatMessage.PrefixText
		end

		return textChatMessageProperties
	end
end

--= Return Job =--
return chatManager
