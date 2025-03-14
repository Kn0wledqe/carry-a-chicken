--[[
    transition.lua
    Kn0wledqe
    Created on 03/11/2025 @ 00:33:33
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")

local player = players.LocalPlayer
local transition = player.PlayerGui:WaitForChild("HUD"):WaitForChild("Transition")
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return function(duration)
	print(duration)
	transition.Size = UDim2.fromScale(0, 0)
	transition.Visible = true
	local tween = tweenService:Create(transition, tweenInfo, {
		Size = UDim2.fromScale(3, 3),
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(duration)
	tween = tweenService:Create(transition, tweenInfo, {
		Size = UDim2.fromScale(0, 0),
	})
	tween:Play()
	tween.Completed:Wait()
	transition.Visible = false
end
