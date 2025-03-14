--[[
    trollManager.lua
    Kn0wledqe
    Created on 03/06/2025 @ 00:32:48
    
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

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local tweenService = game:GetService("TweenService")

--= Object References =--
local fartSound = Instance.new("Sound")
fartSound.SoundId = "rbxassetid://4809574295"
fartSound.PlayOnRemove = true

local fartVFX = replicatedStorage.assets.FartVFX
local localPlayer = players.LocalPlayer

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)

--= Constants =--
local FOG_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NUKE_TIME = 5

local FOG_START = {
	Density = 0.75,
}
local FOG_END = {
	Density = 0.35,
}

--= Variables =--

--= Shorthands =--

--= Functions =--
local function fartAll()
	for _, player in players:GetPlayers() do
		if not player.Character then
			continue
		end

		local rootPart: Part = player.Character.HumanoidRootPart
		local newFart = fartVFX:Clone()
		newFart.Position = rootPart.Position
			- Vector3.new(0, rootPart.Size.Y / 2, 0)
			+ (rootPart.CFrame.LookVector * -2)
		local newSound = fartSound:Clone()
		newSound.Parent = rootPart
		newFart.Parent = workspace

		for _, particleEmitter: ParticleEmitter in newFart:GetChildren() do
			if not particleEmitter:IsA("ParticleEmitter") then
				continue
			end

			particleEmitter:Emit(5)
		end

		newSound:Destroy()
		game.Debris:AddItem(newFart, 5)
	end
end

local function nuke()
	local colorCorrection = colorCorrection:Clone()
	colorCorrection.Parent = game.Lighting
	local tween = tweenService:Create(
		colorCorrection,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Brightness = 1 }
	)
	tween:Play()
	tween.Completed:Connect(function(playbackState)
		tweenService
			:Create(
				colorCorrection,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Brightness = 0.95, TintColor = Color3.fromRGB(199, 119, 0) }
			)
			:Play()
	end)

	local time = os.clock()
	repeat
		local x = Random.new():NextNumber(-0.1, 0.1)
		local y = Random.new():NextNumber(-0.1, 0.1)
		local z = Random.new():NextNumber(-0.1, 0.1)

		if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
			localPlayer.Character.Humanoid.CameraOffset = Vector3.new(x, y, z)
		end
		workspace.CurrentCamera.CFrame *= CFrame.Angles(x / 5, y / 5, z / 5)

		task.wait()

	until os.clock() - time > NUKE_TIME

	tweenService
		:Create(
			colorCorrection,
			TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TintColor = Color3.new(1, 1, 1), Brightness = 0 }
		)
		:Play()

	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
		localPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	game.Debris:AddItem(colorCorrection, 0.7)
end
--= Job API =--

--= Job Initializers =--
function trollManager:InitAsync(): nil
	replicator:listen("troll_manager", function(action)
		if action == "nuke" then
			nuke()
		elseif action == "fogEnd" then
			tweenService:Create(game.Lighting:FindFirstChildOfClass("Atmosphere"), FOG_TWEENINFO, FOG_END):Play()
		elseif action == "fogStart" then
			tweenService:Create(game.Lighting:FindFirstChildOfClass("Atmosphere"), FOG_TWEENINFO, FOG_START):Play()
		elseif action == "fartAll" then
			fartAll()
		end
	end)
end

--= Return Job =--
return trollManager
