--[[
    enviormentManager.lua
    Kn0wledqe
    Created on 03/05/2025 @ 02:26:11
    
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
local enviormentManager = {}

--= Jobs =--
local linkManager = requireInitialized("jobs/linkManager")
local replicator = requireInitialized("jobs/net/replicator")

local controlManager = requireInitialized(script.Parent.controlManager)

--= Classes =--

--= Roblox Services =--
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")
local zonePlus = require(replicatedStorage.lib.zone)

--= Object References =--
local coinsParent = workspace.Coins
local coinColideSFX = replicatedStorage.assets.audio.CoinCollide

local localPlayer = players.LocalPlayer

local soundButton = Instance.new("Sound")
soundButton.Name = "ClickSound"
soundButton.SoundId = "rbxassetid://16480552135"

--= Constants =--
local BUTTON_TWEEN = TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false)

local maxHeight = 0.010
local minHeight = -0.010
local moveSpeed = 0.01
local rotationSpeed = 1

--= Shorthands =--

--= Functions =--
local function playButtonSound(button)
	local sound = button:FindFirstChild(soundButton.Name)
	if not sound then
		sound = soundButton:Clone()
		sound.Parent = button
	end

	if sound.Playing then
		return
	end

	sound:Play()
end

function isInside(position, part, size)
	local size = size or part.Size

	return position.x < (part.Position.x + size.x / 2)
		and position.Z < (part.Position.z + size.z / 2)
		and position.x > (part.Position.x - size.x / 2)
		and position.Z > (part.Position.z - size.z / 2)
end

--[[
local function handleGate(model)
	local gate = model:FindFirstChild("Gate")
	if not gate then
		return
	end

	local button: Model = model:FindFirstChild("Button")
	if not button then
		return
	end

	local function hideDoor(hide)
		print("door bye bye", hide)
		for _, part in gate:GetChildren() do
			if part.Name ~= "Door" then
				continue
			end

			part.CanCollide = not hide
			part.Transparency = hide and 1 or 0
		end
	end

	--local _activated = false
	print(button)
	local mainButton: Part = button:WaitForChild("Main")

	local originalPosition = mainButton.Position
	local activatedPosition = originalPosition - Vector3.new(0, mainButton.Size.Y / 4, 0)

	mainButton.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local player = players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player ~= linkManager:getPair() and player ~= players.LocalPlayer then
			return
		end

		playButtonSound(mainButton)
		hideDoor(true)
		tweenService
			:Create(mainButton, BUTTON_TWEEN, {
				Position = activatedPosition,
			})
			:Play()
	end)

	mainButton.TouchEnded:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local player = players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player ~= linkManager:getPair() and player ~= players.LocalPlayer then
			return
		end

		hideDoor(false)
		tweenService
			:Create(mainButton, BUTTON_TWEEN, {
				Position = originalPosition,
			})
			:Play()
	end)
end

]]

local function handleGate(model)
	local gate = model:FindFirstChild("Gate")
	if not gate then
		return
	end

	local button: Model = model:FindFirstChild("Button")
	if not button then
		return
	end

	local function hideDoor(hide)
		print("door bye bye", hide)
		for _, part in gate:GetChildren() do
			if part.Name ~= "Door" then
				continue
			end

			part.CanCollide = not hide
			part.Transparency = hide and 1 or 0
		end
	end

	--local _activated = false
	print(button)
	local mainButton: Part = button:WaitForChild("Main")
	local activated = false
	local originalPosition = mainButton.Position
	local activatedPosition = originalPosition - Vector3.new(0, mainButton.Size.Y / 4, 0)
	mainButton.Touched:Connect(function(otherPart)
		if activated then
			return
		end

		local character = otherPart.Parent
		if not character then
			return
		end

		local player = players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player ~= linkManager:getPair() and player ~= players.LocalPlayer then
			return
		end

		playButtonSound(mainButton)
		hideDoor(true)
		activated = true
		tweenService
			:Create(mainButton, BUTTON_TWEEN, {
				Position = activatedPosition,
			})
			:Play()

		task.delay(30, function()
			hideDoor(false)
			activated = false
		end)
	end)
end

local function handleElevator(model)
	print("elevator", model)
	local elevator = model.Elevator
	if not elevator then
		return
	end

	local button: Model = model:FindFirstChild("Button")
	if not button then
		return
	end
	print(button)
	local main = elevator:FindFirstChild("Main")
	main:SetAttribute("moving_platform", true)
	local function tweenElevator(up)
		local targetPosition
		if up then
			targetPosition = elevator.Top.Position
		else
			targetPosition = elevator.Bottom.Position
		end

		tweenService:Create(main, TweenInfo.new(3), { Position = targetPosition }):Play()
	end

	--local _activated = false
	print(button)
	local mainButton: Part = button:WaitForChild("Main")

	local originalPosition = mainButton.Position
	local activatedPosition = originalPosition - Vector3.new(0, mainButton.Size.Y / 4, 0)
	local debounce = false
	mainButton.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local player = players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player ~= linkManager:getPair() and player ~= players.LocalPlayer then
			return
		end

		if debounce then
			return
		end
		debounce = true

		playButtonSound(mainButton)
		tweenElevator(true)
		tweenService
			:Create(mainButton, BUTTON_TWEEN, {
				Position = activatedPosition,
			})
			:Play()

		debounce = false
	end)

	local debounce2 = false
	mainButton.TouchEnded:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local player = players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player ~= linkManager:getPair() and player ~= players.LocalPlayer then
			return
		end

		if debounce2 then
			return
		end
		debounce2 = true
		tweenElevator(false)
		tweenService
			:Create(mainButton, BUTTON_TWEEN, {
				Position = originalPosition,
			})
			:Play()

		debounce2 = false
	end)
end

local function handleCoinsFloat()
	for _, coin in coinsParent:GetChildren() do
		local height = 0
		local direction = 1
		runService.Heartbeat:Connect(function(deltaTime: number)
			if coin:GetAttribute("hidden") then
				return
			end

			local rotationAmount = rotationSpeed * deltaTime
			local rotationCFrame = CFrame.Angles(0, rotationAmount, 0)

			height += (moveSpeed * direction * deltaTime)
			if height >= maxHeight then
				height = maxHeight
				direction = -1
			elseif height <= minHeight then
				height = minHeight
				direction = 1
			end

			coin:PivotTo(coin:GetPivot() * rotationCFrame * CFrame.new(0, height, 0))
		end)
	end
end

local function handleCoin(coinModel, visible)
	coinModel:SetAttribute("hidden", visible)
	local explotionVFX = coinModel.Outer.CoinExplosion

	for _, part in coinModel:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		if not visible then
			part:SetAttribute("_transparency", part.Transparency)
			part.Transparency = 1
		else
			part.Transparency = part:GetAttribute("_transparency") or 0
		end
	end

	if not visible then
		for _, emitter in explotionVFX:GetChildren() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local sound: Sound = coinColideSFX:Clone()
		sound.PlayOnRemove = true
		sound.PitchShiftSoundEffect.Octave = math.random(100, 105) / 100
		sound.Parent = coinModel

		sound:Destroy()
	end
end

local function attachmentHandler()
	local lastCframe = nil
	runService.Heartbeat:Connect(function()
		if not localPlayer.Character then
			return
		end
		if not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local RootPart = localPlayer.Character.HumanoidRootPart
		local Ignore = localPlayer.Character
		local ray = Ray.new(RootPart.CFrame.p, Vector3.new(0, -50, 0))

		local Hit: Instance = workspace:FindPartOnRay(ray, Ignore)

		if Hit and Hit:GetAttribute("moving_platform") then
			local platform = Hit

			if lastCframe == nil then
				lastCframe = platform.CFrame
			end
			local cframe = platform.CFrame

			local reverse = cframe * lastCframe:inverse()

			lastCframe = platform.CFrame -- Updated here.

			--local reverse = cframe * lastCframe:inverse()
			lastCframe = platform.CFrame
			RootPart.CFrame = reverse * RootPart.CFrame
		else
			lastCframe = nil
		end
	end)
end

local function leadUserToPairMakers()
	local function handleCharacter(character)
		if identiferFunctions.isLinked() then
			return
		end

		local lead = character:FindFirstChild("lead")
		if not lead then
			return
		end

		local rootAttachment = character.HumanoidRootPart:FindFirstChild("RootAttachment")
		lead.Attachment0 = rootAttachment
	end

	localPlayer.CharacterAdded:Connect(handleCharacter)

	if localPlayer.Character then
		handleCharacter(localPlayer.Character)
	end

	--[[
	localPlayer:GetAttributeChangedSignal("in_machine"):Connect(function()
		local in_machine = localPlayer:GetAttribute("in_machine")
		local lead = localPlayer.Character:FindFirstChild("lead")

		if not lead then
			return
		end

		lead.Enabled = not in_machine
	end)
	]]

	local zone = zonePlus.new(workspace:WaitForChild("Map"):WaitForChild("arrowDisableHitbox"))
	zone.playerEntered:Connect(function(player)
		if localPlayer ~= player then
			return
		end

		if not localPlayer.Character then
			return
		end

		local lead = localPlayer.Character:FindFirstChild("lead")

		if not lead then
			return
		end

		lead.Enabled = false
	end)

	zone.playerExited:Connect(function(player)
		if localPlayer ~= player then
			return
		end

		if not localPlayer.Character then
			return
		end

		local lead = localPlayer.Character:FindFirstChild("lead")

		if not lead then
			return
		end

		lead.Enabled = true
	end)
end

local function handleDropoffPrompts()
	local function updatePrompts()
		for _, dropOff in workspace.Map.Obby.Special.DropPoints:GetChildren() do
			local hitbox = dropOff.Hitbox
			if not hitbox then
				continue
			end

			local proxmity = hitbox:FindFirstChildOfClass("ProximityPrompt")
			if not proxmity then
				proxmity = Instance.new("ProximityPrompt")
				proxmity.MaxActivationDistance = 10
				proxmity.RequiresLineOfSight = false
				proxmity.Enabled = false
				proxmity.KeyboardKeyCode = Enum.KeyCode.F
				proxmity.ActionText = "Drop Chicken"

				proxmity.TriggerEnded:Connect(function(playerWhoTriggered)
					if identiferFunctions.isChicken() then
						return
					end

					if not identiferFunctions.isHolding() then
						proxmity.Enabled = false
						return
					end

					controlManager.drop(hitbox.Position)
				end)

				proxmity.Parent = hitbox
			end

			local enable = false
			if identiferFunctions.isHolding() and not identiferFunctions.isChicken() then
				enable = true
			end

			proxmity.Enabled = enable
		end
	end

	updatePrompts()
	localPlayer:GetAttributeChangedSignal("holding"):Connect(updatePrompts)
end

--= Job API =--

--= Job Initializers =--
function enviormentManager:InitAsync(): nil
	for _, model in workspace.Map.Obby.Special.GateSets:GetChildren() do
		handleGate(model)
	end

	for _, model in workspace.Map.Obby.Special.ElevatorsSets:GetChildren() do
		handleElevator(model)
	end

	handleCoinsFloat()
	attachmentHandler()
	leadUserToPairMakers()
	handleDropoffPrompts()

	replicator:listen("enviorment_manager", function(action, arg)
		if action == "claimCoin" then
			handleCoin(arg.coin, arg.visible)
		elseif action == "resetCoins" then
			for _, coin in coinsParent:GetChildren() do
				handleCoin(coin, true)
			end
		end
	end)
end

--= Return Job =--
return enviormentManager
