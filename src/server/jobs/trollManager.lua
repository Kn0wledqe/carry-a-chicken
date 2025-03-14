--[[
    TrollManager.lua
    Kn0wledqe
    Created on 03/06/2025 @ 00:27:35
    
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
local trollManager = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local deathManager = requireInitialized("jobs/deathManager")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--
local fartSound = Instance.new("Sound")
fartSound.SoundId = "rbxassetid://4809574295"
fartSound.PlayOnRemove = true

local fartVFX = replicatedStorage.assets.FartVFX

--= Constants =--
local FOG_TIME = 2 * 60
--= Variables =--
local fogTime = 0
local fogEnabled = false

--= Shorthands =--

--= Functions =--

--= Job API =--
function trollManager.nuke()
	replicator:sendToAll("troll_manager", "nuke")
	for _, player in players:GetPlayers() do
		task.delay(2, function()
			deathManager.handlePlayerDeath(player, 8)
		end)
	end
	return true
end

function trollManager.fog()
	local addition = FOG_TIME
	if fogTime then
		local timeLeft = fogTime - os.clock()
		if timeLeft > 0 then
			addition += timeLeft
		end
	end

	fogEnabled = true
	fogTime = os.clock() + addition
	replicator:sendToAll("troll_manager", "fogStart")
end

function trollManager.fart()
	task.wait(4)
	replicator:sendToAll("troll_manager", "fartAll")

	return true
end

function trollManager.randomMemeSound()
	local audios = replicatedStorage.assets.audio.Meme:GetChildren()
	local randomSound = audios[math.random(1, #audios)]

	replicator:sendToAll("sound_manager", randomSound.Name)
end

--= Job Initializers =--
function trollManager:InitAsync(): nil
	while task.wait(1) do
		if not fogEnabled then
			continue
		end

		local timeLeft = fogTime - os.clock()
		if timeLeft > 0 then
			continue
		end

		fogTime = nil
		fogEnabled = nil
		replicator:sendToAll("troll_manager", "fogEnd")
	end
end

--= Return Job =--
return trollManager
