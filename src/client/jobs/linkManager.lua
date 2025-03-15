--[[
    linkManager.lua
    Kn0wledqe
    Created on 02/21/2025 @ 12:54:58
    
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
local linkManager = {}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")
local soundManager = requireInitialized("jobs/soundManager")

--= Classes =--

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")
local transitionAnimation = requireInitialized("utils/transition")

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local contextActionService = game:GetService("ContextActionService")

--= Object References =--
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local pairHighlightModel = replicatedStorage.assets.PairHighlight
local controls = require(localPlayer.PlayerScripts.PlayerModule):GetControls()

--= Constants =--
local FREEZE_ACTION = "FREEZE_MOVEMENT"
local FREEZE_JUMP_ACTION = "FREEZE_JUMP_MOVEMENT"

local DEFAULT_GRAVITY = workspace.Gravity
local LINKED_GRAVITY = 50

local PLAYER_STATS = {
	HOLDING = {
		WalkSpeed = 16,
		Jumppower = 0,
		CanJump = false,
	},
	WITHOUT = {
		WalkSpeed = 16,
		Jumppower = 7,
		CanJump = true,
	},
}

--= Variables =--
local pair = nil
local pairHighlight = nil

--= Shorthands =--

--= Functions =--
local function setCameraSubject(player: Player)
	player = player or localPlayer

	local target = player.Character:WaitForChild("Humanoid")
	camera.CameraSubject = target
end

local function lockJump(lock)
	if lock then
		contextActionService:BindAction(FREEZE_JUMP_ACTION, function()
			return Enum.ContextActionResult.Sink
		end, false, Enum.PlayerActions.CharacterJump)
	else
		contextActionService:UnbindAction(FREEZE_JUMP_ACTION)
	end
end

local function lockMovement(lock)
	if lock then
		contextActionService:BindAction(
			FREEZE_ACTION,
			function()
				return Enum.ContextActionResult.Sink
			end,
			false,
			Enum.PlayerActions.CharacterBackward,
			Enum.PlayerActions.CharacterForward,
			Enum.PlayerActions.CharacterLeft,
			Enum.PlayerActions.CharacterRight
		)

		--controls:Disable()
	else
		contextActionService:UnbindAction(FREEZE_ACTION)
	end
end

local function enableHighlight(enable)
	if not pairHighlight then
		pairHighlight = pairHighlightModel:Clone()
		pairHighlight.Parent = pair.Character
	end

	pairHighlight.Enabled = enable
end

local function setPlayerStats(holdingChicken)
	local humanoid = localPlayer.Character:WaitForChild("Humanoid")

	local stats = holdingChicken and PLAYER_STATS.HOLDING or PLAYER_STATS.WITHOUT

	humanoid.WalkSpeed = stats.WalkSpeed
	humanoid.JumpPower = stats.Jumppower

	lockJump(not stats.CanJump)
end

local function setChickenStats(holdingChicken)
	local humanoid = localPlayer.Character:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	local jumppower = holdingChicken and 0 or 20
	local walkspeed = holdingChicken and 0 or 12.433

	humanoid.JumpPower = jumppower
	humanoid.WalkSpeed = walkspeed
end

local function setPickGui(enable)
	if identiferFunctions.isChicken() then
		return
	end

	if not pair.Character.PrimaryPart then
		return
	end

	local proxmity = pair.Character.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
	if not proxmity then
		proxmity = Instance.new("ProximityPrompt")
		proxmity.MaxActivationDistance = 5
		proxmity.RequiresLineOfSight = false
		proxmity.Enabled = false
		proxmity.KeyboardKeyCode = Enum.KeyCode.F
		proxmity.ActionText = "Pick up"

		proxmity.TriggerEnded:Connect(function(playerWhoTriggered)
			if identiferFunctions.isChicken() then
				return
			end

			if identiferFunctions.isHolding() then
				proxmity.Enabled = false
				return
			end

			replicator:sendToServer("link_manager", "grab")
		end)

		proxmity.Parent = pair.Character.PrimaryPart
	end

	proxmity.Enabled = enable
end

--= Job API =--
function linkManager:getPair()
	return pair
end

--= Job Initializers =--
function linkManager:InitAsync(): nil
	replicator:listen("link_manager", function(action, args)
		if action == "setCamera" then
			--[[
			local target = localPlayer
			if args and args.target then
				target = args.target
			end
            ]]

			setCameraSubject(args.target)
		elseif action == "transition" then
			transitionAnimation(2)
		elseif action == "initialize" then
			pair = args.pair

			if identiferFunctions.isChicken() then
				setCameraSubject(pair)
				--lockMovement(true)
			else
				workspace.Gravity = LINKED_GRAVITY
			end

			--enableHighlight(false)
		elseif action == "picked" then
			soundManager:playSound("PickUp")
			if identiferFunctions.isChicken() then
				setCameraSubject(pair)
				lockMovement(true)
			end

			workspace.Gravity = LINKED_GRAVITY

			setPickGui(false)
		elseif action == "dropped" then
			soundManager:playSound("Drop")
			if identiferFunctions.isChicken() then
				setCameraSubject()
				lockMovement(false)
			else
				workspace.Gravity = DEFAULT_GRAVITY
			end

			setPickGui(true)
			--enableHighlight(true)
		elseif action == "reset" then
			workspace.Gravity = DEFAULT_GRAVITY
			setCameraSubject()
			lockMovement(false)
		end
	end)

	localPlayer:GetAttributeChangedSignal("holding"):Connect(function()
		local holding = identiferFunctions.isHolding()
		local isChicken = identiferFunctions.isChicken()

		if isChicken then
			if holding then
				setCameraSubject(pair)

				--lockMovement(true)
			else
				setCameraSubject()

				--lockMovement(false)
			end

			setChickenStats(holding)
		else
			setPlayerStats(holding)
		end

		if holding then
			enableHighlight(false)
		else
			enableHighlight(true)
		end
	end)
end

--= Return Job =--
return linkManager
