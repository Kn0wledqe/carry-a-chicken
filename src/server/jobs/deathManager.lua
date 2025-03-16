--[[
    deathManager.lua
    Kn0wledqe
    Created on 03/06/2025 @ 13:52:12
    
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
local deathManager = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
--local enviormentManager = requireInitialized("jobs/enviormentManager")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")
--= Classes =--
local linked = requireInitialized("classes/linked")

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function handleDeathParts()
	for _, deathPart in collectionService:GetTagged("deathPart") do
		deathPart.Touched:Connect(function(otherPart)
			local character = otherPart.Parent
			local player = players:GetPlayerFromCharacter(character)
			if not player then
				return
			end

			deathManager.handlePlayerDeath(player)
		end)
	end
end

--= Job API =--
function deathManager.handlePlayerDeath(player, _time)
	local class = linked.getClassByPlayer(player)
	task.wait(0.25)
	if not class then
		player.Character:Destroy()
		if _time then
			task.wait(_time)
		end

		player:LoadCharacter()
		return
	end

	for _, model in class._models do
		if not model then
			continue
		end

		model:Destroy()
		model = nil
	end

	if _time then
		task.wait(_time)
	end

	replicator:sendToPlayers("death_manager", { class._players.player, class._players.chicken }, "prompt")
	print("prompt revive death bs")
end

--= Job Initializers =--
function deathManager:InitAsync(): nil
	handleDeathParts()

	replicator:listen("death_manager", function(player: Player, aciton: string)
		local class = linked.getClassByPlayer(player)
		if not class then
			return
		end

		if aciton == "unpair" then
			replicator:sendToPlayers("death_manager", { class._players.player, class._players.chicken }, "hide")
			class:Destroy()
		elseif aciton == "pair" then
			class._pair += 1

			if class._pair >= 2 then
				class:spawn()
				return
			end

			replicator:sendToPlayers(
				"death_manager",
				{ class._players.player, class._players.chicken },
				"pairRequest",
				class._pair
			)
		elseif aciton == "revive" then
			local revives = dataWrapper.getRevives(player)
			if revives - 1 < 0 and not dataWrapper.hasInfiniteRevives(player) then
				print("not enough revives")
				return
			end

			dataWrapper.addToRevives(player, -1)

			--local progress = enviormentManager.getProgress(class._players.player)
			--	or enviormentManager.getProgress(class._players.chicken)
			local progress = class.progressPart
			print(progress)
			class:spawn(progress)
		end
	end)

	players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character.Humanoid.Died:Connect(function()
				deathManager.handlePlayerDeath(player)
			end)
		end)

		player:LoadCharacter()
	end)

	for _, player in players:GetPlayers() do
		player.CharacterAdded:Connect(function(character)
			character.Humanoid.Died:Connect(function()
				deathManager.handlePlayerDeath(player)
			end)
		end)

		player:LoadCharacter()
	end
end

--= Return Job =--
return deathManager
