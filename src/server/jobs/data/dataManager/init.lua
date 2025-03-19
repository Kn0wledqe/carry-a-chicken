--[[
    DataManager.lua
    Kn0wledqe
    Created on 09/02/2022 @ 02:19:33
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Root =--
local DataManager = { Priority = 2 }

--= Jobs =--
local replicator = require("jobs/net/replicator")

--= Classes =--

--= Modules & Config =--
local ProfileService = require(script:WaitForChild("profileService"))
local DataSchema = require(script:WaitForChild("dataSchema"))

--= Roblox Services =--
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--= Constants =--
local StoreKey = "PlayerData_"

local DataVersion = 1

local BLACKLISTED_IDS = {}

--= Object References =--

--= Variables =--
local ProfileCache = {}

local MockStore = false

local GameStore = nil

--= Shorthands =--

--= Functions =--
function setOrderedDataStoreRequest(dataStore: OrderedDataStore, userID, value)
	local done = false

	repeat
		local success, err = pcall(function(...)
			dataStore:SetAsync(userID, value)
		end)

		if not success then
			warn("Failed to set data:", err)
		end

		done = success
		task.wait()
	until done
end

function loadLeaderStats(player: Player, data)
	local leaderstatsFolder = Instance.new("Folder")
	leaderstatsFolder.Name = "leaderstats"
	leaderstatsFolder.Parent = player

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = data["wins"]
	wins.Parent = leaderstatsFolder
	DataManager:Listen(player, "wins", function(value)
		wins.Value = value
	end)

	local kills = Instance.new("IntValue")
	kills.Name = "Coins"
	kills.Value = data["coins"]
	kills.Parent = leaderstatsFolder
	DataManager:Listen(player, "coins", function(value)
		kills.Value = value
	end)
end

function onPlayerJoin(Player: Player)
	if ProfileCache[Player] then
		return
	end

	print("Player joined:", Player.Name)

	local ProfileKey = "Player_" .. Player.UserId
	local Profile = nil
	if RunService:IsStudio() and MockStore then
		Profile = GameStore.Mock:LoadProfileAsync(ProfileKey, "ForceLoad")
	else
		Profile = GameStore:LoadProfileAsync(ProfileKey, "ForceLoad")
	end

	--Profile = GameStore:LoadProfileAsync("Player_" .. Player.UserId, "ForceLoad")
	if Profile then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			ProfileCache[Player] = nil
			Player:Kick("Data accessed remotely.")
		end)

		if Player:IsDescendantOf(Players) then
			if ProfileCache[Player] then
				ProfileCache[Player] = nil
			end

			local DataTemplate = {
				profile = Profile,
				listeners = {},
			}

			local Event = Instance.new("BindableEvent")
			DataTemplate._event = Event
			DataTemplate.Changed = Event.Event

			ProfileCache[Player] = DataTemplate

			-- new badge
			if os.time() - Profile.Data.lastAwardedSpin > 24 * 60 * 60 then
				Profile.Data.spins += 1
				Profile.Data.lastAwardedSpin = os.time()
			end

			Profile.Data.sessions += 1

			---replicator:sendToPlayer("data_manager", Player, "set", Profile.Data)

			loadLeaderStats(Player, Profile.Data)
		else
			Profile:Release()
		end
	else
		Player:Kick("Player Data (Not Loaded)")
	end

	return nil
end

--= Job API =--
function DataManager:WaitForData(Player: Player): nil
	while
		not Player
		or not ProfileCache[Player]
		or not ProfileCache[Player].profile
		or not ProfileCache[Player].profile.Data
	do
		RunService.Stepped:Wait()
	end
end

function DataManager:GetProfile(Player: Player): table
	DataManager:WaitForData(Player)
	return ProfileCache[Player]
end

function DataManager:LoadProfile(userID)
	local ProfileKey = "Player_" .. userID
	local Profile = nil
	if RunService:IsStudio() and MockStore then
		Profile = GameStore.Mock:LoadProfileAsync(ProfileKey, "ForceLoad")
	else
		Profile = GameStore:LoadProfileAsync(ProfileKey, "ForceLoad")
	end

	if not Profile then
		return nil
	end

	Profile:AddUserId(userID)
	Profile:Reconcile()

	return Profile
end

function DataManager:ReleaseProfile(Player: Player): nil
	DataManager:WaitForData(Player)
	local Profile = ProfileCache[Player]
	if Profile and Profile.profile then
		--Profile.Data["profilesShownThisSession"] = {}
		Profile.profile:Release()
	else
		----------------print("Failed to release profile - no profile found!")
	end
	return nil
end

function DataManager:Listen(Player: Player, Key: string, Callback): nil
	local Profile = DataManager:GetProfile(Player)
	if Profile then
		table.insert(Profile.listeners, {
			key = Key,
			callback = Callback,
		})
	end
end

function DataManager:Get(Player: Player, Key: string): table | nil
	DataManager:WaitForData(Player)
	local Profile = DataManager:GetProfile(Player)
	if Profile then
		return Profile.profile.Data[Key]
	end
	return nil
end

function DataManager:Set(Player: Player, Key: string, Value: any, notify: boolean): nil
	DataManager:WaitForData(Player)
	local Profile = DataManager:GetProfile(Player)
	if Profile then
		Profile.profile.Data[Key] = Value
		if notify then
			-- update data clinet
			Profile._event:Fire(Key, Value)
			replicator:sendToPlayer("data_manager", Player, Key, Value)
			for _, Listener in ipairs(Profile.listeners) do
				if Listener.key == Key then
					Listener.callback(Value)
				end
			end
		end
	end
	return nil
end

function DataManager:GetVersion(): string
	return StoreKey .. DataVersion
end

--= Job Initializers =--
function DataManager:InitAsync(): nil
	Players.PlayerAdded:Connect(onPlayerJoin)
	Players.PlayerRemoving:Connect(function(Player: Player)
		local Profile = ProfileCache[Player]
		if Profile and Profile.profile then
			--saveToLeaderboard(Player)

			Profile.profile:Release()
			ProfileCache[Player] = nil

			pcall(function()
				ProfileCache[Player]._event:Destroy()
			end)
		end
	end)

	for _, player in Players:GetPlayers() do
		onPlayerJoin(player)
	end

	--local replicator = require("jobs/net/replicator")
	replicator:listen("is_data_ready", function(player: Player)
		return ProfileCache[player] ~= nil
	end)

	replicator:listen("data_manager", function(player: Player)
		print("called")
		if not ProfileCache[player] then
			return nil
		end

		return ProfileCache[player].profile.Data
	end)

	replicator:listen("setFavorited", function(player: Player)
		ProfileCache[player].profile.Data.favorited = true
	end)
end

function DataManager:Init(): nil
	GameStore = ProfileService.GetProfileStore(StoreKey .. DataVersion, DataSchema)
	print("Data Manager initialized.")
end

--= Return Job =--
return DataManager
