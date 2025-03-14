--!strict
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

print("called animator script", script.Parent)

local DEFAULT_FADE_TIME: number = 0.1
local ANIMATION_SPEED_MODIFIER = 1

local character: Model = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

local animationTracks: { [string]: AnimationTrack } = {}

-- Store animation instances inside the character to ensure replication
local animationFolder = Instance.new("Folder")
animationFolder.Name = "Animations"
animationFolder.Parent = character

local animationData: { [string]: { any } } = {
	Idle = { "rbxassetid://180435792", Enum.AnimationPriority.Idle },
	Walk = { "rbxassetid://180426354", Enum.AnimationPriority.Movement },
	Jump = { "rbxassetid://125750702", Enum.AnimationPriority.Movement },
	Fall = { "rbxassetid://180436148", Enum.AnimationPriority.Core },
	Holding = { "rbxassetid://111333449829962", Enum.AnimationPriority.Action4 },

	Idle_Chicken = { "rbxassetid://134382103878905", Enum.AnimationPriority.Core },
	Walk_Chicken = { "rbxassetid://94447843738568", Enum.AnimationPriority.Core },
	Jump_Chicken = { "rbxassetid://106139862387628", Enum.AnimationPriority.Core },
	Fall_Chicken = { "rbxassetid://89624804988718", Enum.AnimationPriority.Core },
}

for name, data in animationData do
	local animation = Instance.new("Animation")
	animation.AnimationId = data[1]
	animation.Name = name
	animation.Parent = animationFolder

	local animationTrack = animator:LoadAnimation(animation)
	animationTrack.Priority = data[2]

	animationTracks[name] = animationTrack
end

local animationTrack = animationTracks.Idle
animationTrack:Play(0)

local function play(newAnimationTrack: AnimationTrack, fadeTime: number?)
	if newAnimationTrack.IsPlaying then
		return
	end
	local fadeTime = fadeTime or DEFAULT_FADE_TIME

	animationTrack:Stop(fadeTime)
	animationTrack = newAnimationTrack
	animationTrack:Play(fadeTime)
end

local function onRunning(speed: number)
	local speed = math.round(speed)
	local divider = 16

	local movement_animation = "Walk"
	local idle = "Idle"

	if localPlayer:GetAttribute("isChicken") then
		movement_animation ..= "_Chicken"
		idle ..= "_Chicken"
	end

	if speed > 0 then
		play(animationTracks[movement_animation], 0.2)
		animationTracks[movement_animation]:AdjustSpeed((speed / divider) * ANIMATION_SPEED_MODIFIER)
	else
		play(animationTracks[idle], 0.2)
	end
end

local function onJumping()
	local jump_animation = "Jump"

	if localPlayer:GetAttribute("isChicken") then
		jump_animation ..= "_Chicken"
	end

	play(animationTracks[jump_animation], 0.1)
end

local function onFalling()
	local fall_animation = "Fall"
	local holding = localPlayer:GetAttribute("holding")

	if localPlayer:GetAttribute("isChicken") then
		fall_animation ..= "_Chicken"
	end

	if holding and not localPlayer:GetAttribute("isChicken") then
		return
	end

	play(animationTracks[fall_animation], 0.1)
end

animator.AnimationPlayed:Connect(function(animationTrack: AnimationTrack)
	animationTrack:AdjustSpeed(animationTrack.Speed * ANIMATION_SPEED_MODIFIER)
end)
--[[

local function onAttributeChanged(attribute)
	onRunning(humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed)
end
]]

local function onHolding()
	if localPlayer:GetAttribute("isChicken") then
		return
	end

	local holding = localPlayer:GetAttribute("holding")
	local animationTrack = animationTracks["Holding"]
	if holding then
		animationTrack:Play()
	else
		animationTrack:Stop()
	end
end

localPlayer:GetAttributeChangedSignal("holding"):Connect(onHolding)
onHolding()

humanoid.Running:Connect(onRunning)
humanoid.Jumping:Connect(onJumping)
humanoid.FreeFalling:Connect(onFalling)
