--[[
    wingFlap.lua
    Kn0wledqe
    Created on 03/06/2025 @ 12:30:13
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local parent = player.PlayerGui:WaitForChild("Overlay")

-- Wing template setup
local wingTemplate = Instance.new("ImageLabel")
wingTemplate.Size = UDim2.new(0, 20, 0, 20)
wingTemplate.Image = "rbxassetid://103536381003661"
wingTemplate.BackgroundTransparency = 1
wingTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
wingTemplate.Visible = false

local function createWing()
	local screenSize = workspace.CurrentCamera.ViewportSize

	local wing = wingTemplate:Clone()
	wing.Visible = true
	wing.Parent = parent

	-- Random position on screen
	local randomX = math.random(50, screenSize.X - 50)
	local randomY = math.random(50, screenSize.Y - 100)
	wing.Position = UDim2.new(0, randomX, 0, randomY)
	wing.Size = UDim2.new(0, 20, 0, 20)

	local growTween = TweenService:Create(wing, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 100, 0, 100),
	})

	local flapTween =
		TweenService:Create(wing, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true), {
			Rotation = 30,
		})

	growTween:Play()
	flapTween:Play()

	flapTween.Completed:Connect(function()
		local fallTween =
			TweenService:Create(wing, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 300, 0, 300),
				ImageTransparency = 1,
				Rotation = math.random(10, 30),
			})
		fallTween:Play()

		fallTween.Completed:Connect(function()
			wing:Destroy()
		end)
	end)
end

return createWing
