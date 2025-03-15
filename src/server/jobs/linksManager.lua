--[[
    linksManager.lua
    Kn0wledqe
    Created on 02/21/2025 @ 12:27:34
    
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
local linksManager = {}

--= Roblox Services =--
local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local players = game:GetService("Players")

--= Jobs =--
local smoothTween = requireInitialized(replicatedStorage.jobs.smoothTween)
local replicator = requireInitialized("replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

--= Classes =--
local linkedClass = requireInitialized("classes/linked")

--= Modules & Config =--
local zonePlus = require(replicatedStorage.lib.zone)

--= Object References =--
local teleportToOnExit = workspace.Teleports.ExitLinker

--= Constants =--
local COLORS = {
	-- PLAYER
	playerNotOccupiedSignColor = Color3.fromRGB(26, 76, 103), -- also change material to SmoothPlastic
	playerNotOccupiedConnectorColor = Color3.fromRGB(15, 76, 88),
	playerOccupiedSignColor = Color3.fromRGB(42, 122, 166), -- also change material to Neon
	playerOccupiedConnectorColor = Color3.fromRGB(26, 137, 156),

	-- CHICKEN
	chickenNotOccupiedSignColor = Color3.fromRGB(103, 27, 27), -- also change material to SmoothPlastic
	chickenNotOccupiedConnectorColor = Color3.fromRGB(88, 19, 19),
	chickenOccupiedSignColor = Color3.fromRGB(165, 43, 43), -- also change material to Neon
	chickenOccupiedConnectorColor = Color3.fromRGB(159, 34, 34),
}

local MATERIALS = {

	occupied = Enum.Material.Neon,
	notOccupied = Enum.Material.SmoothPlastic,
}

local DOOR_TWEEN = TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local START_AFTER = 10 --5

local CHECK_POINTS = requireInitialized("$config/checkpoints")

--= Variables =--
local selectedWorlds = {}

--= Shorthands =--

--= Functions =--
local function setbillboardAvaterImage(avaterHolder: BillboardGui, playerID: number)
	local avater: ImageLabel = avaterHolder.GUI.Avater
	avaterHolder.GUI.Enabled = true
	if not playerID then
		avaterHolder.GUI.Enabled = false
		return
	end

	avater.Image = `rbxthumb://type=AvatarHeadShot&id={playerID}&w=420&h=420`
end

local function handleLinker(model)
	print(model)
	local players = {
		chicken = nil,
		player = nil,
	}

	local glassData = {}

	local player_hitbox = model:WaitForChild("PlayerHitbox")
	local chicken_hitbox = model:WaitForChild("ChickenHitbox")

	local player_glass = model:WaitForChild("PlayerGlass")
	local chicken_glass = model:WaitForChild("ChickenGlass")

	local function storeGlassData(glass: Part)
		local extendedPosition = {
			Position = glass.Position,
			Size = glass.Size,
		}

		local contracted = {
			Position = extendedPosition.Position + Vector3.new(0, extendedPosition.Size.Y / 2, 0), --+ Vector3.new(0, extendedPosition.Size.Y, 0),
			Size = Vector3.new(extendedPosition.Size.X, 0, extendedPosition.Size.Z),
		}

		glassData[glass] = {
			extended = extendedPosition,
			contracted = contracted,
		}

		glass.CanCollide = true
		glass.Transparency = 0.65

		glass.Position = contracted.Position
		glass.Size = contracted.Size
	end

	storeGlassData(player_glass)
	storeGlassData(chicken_glass)

	local function setColor(parts: {}, color, material)
		for _, part: Part in parts do
			if part:GetAttribute("_dontChange") then
				continue
			end

			part.Color = color
			part.Material = material
		end
	end

	local function updateAppearance()
		setbillboardAvaterImage(player_hitbox.AvaterHolder, players.player and players.player.UserId or nil)
		setbillboardAvaterImage(chicken_hitbox.AvaterHolder, players.chicken and players.chicken.UserId or nil)

		setColor(model.ChickenSign:GetChildren(), COLORS.chickenNotOccupiedSignColor, MATERIALS.notOccupied)
		setColor({ model.Connectors.Chicken }, COLORS.chickenNotOccupiedConnectorColor, MATERIALS.notOccupied)
		if players.chicken then
			setColor({ model.Connectors.Chicken }, COLORS.chickenOccupiedConnectorColor, MATERIALS.occupied)
			setColor(model.ChickenSign:GetChildren(), COLORS.chickenOccupiedSignColor, MATERIALS.occupied)
		end

		setColor(model.PlayerSign:GetChildren(), COLORS.playerNotOccupiedSignColor, MATERIALS.notOccupied)
		setColor({ model.Connectors.Player }, COLORS.playerNotOccupiedConnectorColor, MATERIALS.notOccupied)
		if players.player then
			setColor({ model.Connectors.Player }, COLORS.playerOccupiedConnectorColor, MATERIALS.notOccupied)
			setColor(model.PlayerSign:GetChildren(), COLORS.playerOccupiedSignColor, MATERIALS.occupied)
		end
	end
	updateAppearance()

	local function link()
		if not players.chicken or not players.player then
			print("Can't link insufficent players")
			return
		end

		local worldUnlocked =
			math.min(dataWrapper.getUnlockedWorld(players.chicken), dataWrapper.getUnlockedWorld(players.player))
		print("worldUnlocked", worldUnlocked)
		local timeToStart = os.time() + START_AFTER
		replicator:sendToPlayer("linking_manager", players.chicken, "startCountdown", { startsOn = timeToStart })
		replicator:sendToPlayer(
			"linking_manager",
			players.player,
			"startCountdown",
			{ startsOn = timeToStart, pair = players.chicken, worldThereshold = worldUnlocked }
		)

		while task.wait() do
			local timeLeft = math.max(0, timeToStart - os.time())
			if timeLeft == 0 then
				break
			end

			if not players.chicken or not players.player then
				print("called")

				for _, player in players do
					replicator:sendToPlayer("linking_manager", player, "stopCountdown")
				end
				--   replicator:sendToPlayers("linking_manager", {players.chicken, players.player}, "stopCountdown")
				return
			end
		end

		for _, player in players do
			player.Character.HumanoidRootPart.Anchored = false
		end

		local selectedIndex = selectedWorlds[players.player] or 1
		local selectedWorld = CHECK_POINTS[selectedIndex]
		local world

	
		if selectedIndex and selectedWorld then
			world = selectedWorld.spawnPoint
		end
	
		replicator:sendToPlayers("linking_manager", { players.chicken, players.player }, "reset")
		linkedClass.new(players.player, players.chicken, selectedIndex, world)
	end

	local function handlePlatform(hitbox, name, glass)
		local zone = zonePlus.new(hitbox)
		zone.playerEntered:Connect(function(player)
			if players[name] then -- player already exist
				return
			end

			selectedWorlds[player] = nil

			players[name] = player
			updateAppearance()
			player:SetAttribute("in_machine", true)

			player.Character.HumanoidRootPart.Anchored = true
			player.Character.HumanoidRootPart.CFrame = hitbox:FindFirstChild("Position").WorldCFrame
				* CFrame.Angles(0, math.rad(-90), 0)

			smoothTween.play(glass, DOOR_TWEEN, glassData[glass].extended)
			replicator:sendToPlayer("linking_manager", player, "joined")
			link()
		end)

		zone.playerExited:Connect(function(player)
			players[name] = nil
			player:SetAttribute("in_machine", false)
			updateAppearance()

			smoothTween.play(glass, DOOR_TWEEN, glassData[glass].contracted)
		end)
	end

	handlePlatform(player_hitbox, "player", player_glass)
	handlePlatform(chicken_hitbox, "chicken", chicken_glass)
end

--= Job API =--

--= Job Initializers =--
function linksManager:InitAsync(): nil
	for _, linker in collectionService:GetTagged("linker_platform") do
		handleLinker(linker)
	end

	replicator:listen("linking_manager", function(player: Player, action)
		if action == "exit" then
			player.Character.HumanoidRootPart.Anchored = false
			player.Character.HumanoidRootPart.CFrame = teleportToOnExit.CFrame
		end
	end)

	replicator:listen("checkpoint_manager", function(player: Player, index: number)
		selectedWorlds[player] = index
	end)
end

--= Return Job =--
return linksManager
