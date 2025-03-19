--[[
    controlManager.lua
    Kn0wledqe
    Created on 02/26/2025 @ 11:35:52
    
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
local controlManager = {}

--= Jobs =--
local inputManager = requireInitialized(script.Parent.inputManager)
local replicator = requireInitialized("replicator")
local linkManager = requireInitialized("jobs/linkManager")
local soundManager = requireInitialized("jobs/soundManager")

local tutorialGui = requireInitialized("jobs/GUIManager/components/screens/tutorial")

--= Classes =--

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")
local wingFlapAnimation = requireInitialized("utils/wingFlap")

--= Roblox Services =--
local players = game:GetService("Players")
local RunService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local contextActionService = game:GetService("ContextActionService")

local tweenService = game:GetService("TweenService")


--= Object References =--
local localPlayer = players.LocalPlayer

--= Constants =--
--local JUMP_FORCE = Vector3.new(0, 1500, 0)
local MAX_JUMPS = 5
local MAX_JUMPS_PER_SECOND = 2
local JUMP_COOLDOWN = 1 / MAX_JUMPS_PER_SECOND
local JUMP_HEIGHT = 5

--= Variables =--
local jumpsUsed = 0

local wingFlapChickenAnimation = Instance.new("Animation")
wingFlapChickenAnimation.AnimationId = "rbxassetid://89624804988718"

--= Shorthands =--

--= Functions =--
local function getJumpVelocity()
	return Vector3.new(0, math.sqrt(2 * workspace.Gravity * JUMP_HEIGHT), 0)
end

local function initializeChickenControls()

	local function onJumpRequest()
		--print("jumpping yo")
		if not identiferFunctions.isChicken() then
			return
		end

		if not identiferFunctions.isHolding() then
			return
		end

		replicator:sendToServer("control_manager", "jump")
		tutorialGui.onJumped()
	end

	userInputService.InputBegan:Connect(function(input, gameProccesedEvent)
		if gameProccesedEvent then
			return
		end

		if
			not (
				input.KeyCode == Enum.KeyCode.Space
				or input.KeyCode == Enum.KeyCode.ButtonA
				or input.KeyCode == Enum.KeyCode.ButtonX
				or input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch

			)
		then
			return
		end

		onJumpRequest()
	end)

	
	--[[
	if userInputService.TouchEnabled then
		local JumpButton: ImageButton =
			localPlayer.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")

		JumpButton.MouseButton1Click:Connect(onJumpRequest)
	end
	]]
end

local function initializeDrop()
	inputManager:register(
		"drop",
		inputManager.TRIGGERS.BEGAN,
		{ Enum.KeyCode.F, Enum.KeyCode.ButtonR1 },
		false,
		controlManager.drop
	)
	--[[]
	contextActionService:BindAction("Drop", function()
		if identiferFunctions.isChicken() then
			return
		end

		if not identiferFunctions.isHolding() then
			return
		end

		replicator:sendToServer("link_manager", "drop")
	end, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR1)

	local buttonAction = contextActionService:GetButton("Drop")

	contextActionService:SetTitle("Drop", "Drop")
	contextActionService:SetPosition("Drop", UDim2.fromScale(0.15, 0.15))
	if buttonAction then
		buttonAction.Size = UDim2.fromScale(0.3, 0.3)
		buttonAction.Visible = false
	end
	]]
end

local function initializeJumpReseter()
	local function handleCharacter(character)
		local humanoid: Humanoid = character:WaitForChild("Humanoid")
		if not humanoid then
			return
		end

		humanoid.StateChanged:Connect(function(_, newState)
			if newState ~= Enum.HumanoidStateType.Landed then
				return
			end

			jumpsUsed = 0
		end)
	end

	handleCharacter(localPlayer.Character)
	localPlayer.CharacterAdded:Connect(handleCharacter)
end

--= Job API =--
function controlManager.drop(position)
	if identiferFunctions.isChicken() then
		return
	end

	if not identiferFunctions.isHolding() then
		return
	end

	replicator:sendToServer("link_manager", "drop", position)
end

--= Job Initializers =--
function controlManager:InitAsync(): nil
	initializeChickenControls()
	initializeJumpReseter()
	--initializeDrop()

	--= Jump functionality =--
	local lastJumpTime = 0
	replicator:listen("control_manager", function(action)
		if action == "jump" then
			task.spawn(wingFlapAnimation)
			local sound = { "WingFlap1", "WingFlap2" }
			sound = sound[math.random(1, #sound)]

			soundManager:playSound(sound)
			if identiferFunctions.isChicken() then
				local animator: Animator = localPlayer.Character.Humanoid.Animator
				animator:LoadAnimation(wingFlapChickenAnimation):Play()

				return
			end

			if not identiferFunctions.isHolding() then
				return
			end

			local character = localPlayer.Character
			if not character then
				return
			end

			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			local hasJumpBoost = false
			local pair = linkManager:getPair()
			if localPlayer:GetAttribute("doubleWingStrength") then
				hasJumpBoost = true
			elseif pair and pair:GetAttribute("doubleWingStrength") then
				hasJumpBoost = true
			end

			local now = tick()
			if jumpsUsed < MAX_JUMPS and (now - lastJumpTime >= JUMP_COOLDOWN) then
				jumpsUsed += 1
				lastJumpTime = now

				print("applied force ")
				--humanoidRootPart:ApplyImpulse(getJumpVelocity())
				humanoidRootPart.AssemblyLinearVelocity += getJumpVelocity() * (hasJumpBoost and 1.5 or 1)
			end
		end
	end)
end

--= Return Job =--
return controlManager
