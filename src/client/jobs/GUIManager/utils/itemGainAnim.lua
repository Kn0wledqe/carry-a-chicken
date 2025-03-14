--[[
    ItemGainAnim.lua
    Kn0wledqe
    Created on 08/22/2024 @ 12:12:48
    
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

--= Jobs =--

--= Classes =--

--= Modules & Config =--
local spring = requireInitialized("lib/spr")

--= Roblox Services =--
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local guiService = game:GetService("GuiService")

--= Object References =--
local camera = workspace.CurrentCamera

local localPlayer = players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local overlay = playerGui:WaitForChild("Overlay")

--= Constants =--
local RADIUS = 2
local SIZE_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--= Variables =--

--= Shorthands =--

--= Functions =--
local function randomLocation(screen: Frame?, itemIcon: GuiObject?)
	local itemSizeX = itemIcon and itemIcon.AbsoluteSize.X or 0
	local itemSizeY = itemIcon and itemIcon.AbsoluteSize.Y or 0

	local sizeX, sizeY = camera.ViewportSize.X, camera.ViewportSize.Y
	if screen then
		sizeX = screen.AbsoluteSize.X, screen.AbsoluteSize.Y
	end

	local rangeX = sizeX - RADIUS * 2 - itemSizeX
	local rangeY = sizeY - RADIUS * 2 - itemSizeY
	local x = (math.random(rangeX) + RADIUS + itemSizeX / 2) / sizeX
	local y = (math.random(rangeY) + RADIUS + itemSizeY / 2) / sizeY
	return UDim2.new(x, 0, y, 0)
end

local function isIgnoreGuiInsetEnabled(frame: Frame)
	if frame.ClassName == "ScreenGui" then
		return frame.IgnoreGuiInset
	end

	return isIgnoreGuiInsetEnabled(frame.Parent)
end

--= Return Job =--
return function(
	target: GuiObject,
	clonedItem: GuiObject,
	onReachedCallback,
	config: {
		amountOfSpawnedItems: number?,
		scaleTargetOnReached: boolean?,
		scaleAmount: number?,
		yield: boolean?,
	}?
)
	local amountOfSpawnedItems = config and config.amountOfSpawnedItems or 20
	local scaleTargetOnReached = config and config.scaleTargetOnReached or false
	local scaleAmount = config and config.scaleAmount or 1.7
	local yield = config and config.yield or false -- 1.7

	local uiScale = target:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = target
	end

	local amount = 0
	for i = 1, amountOfSpawnedItems, 1 do
		task.spawn(function()
			task.wait(math.random() * 1)
			local randomPosition = randomLocation()
			local newIcon = clonedItem:Clone()

			local scale = Instance.new("UIScale")
			scale.Scale = 0.2
			scale.Parent = newIcon

			newIcon.Position = randomPosition
			newIcon.Parent = overlay
			local tween = tweenService:Create(scale, SIZE_TWEEN, { Scale = 1 })
			tween:Play()

			--task.wait()
			task.wait(0.15)

			local insetOffset = 0
			if isIgnoreGuiInsetEnabled(target) then
				local inset1, inset2 = guiService:GetGuiInset()
				insetOffset = inset1 - inset2
			end

			local centerPosition = target.AbsolutePosition + insetOffset + target.AbsoluteSize / 2
			spring.target(newIcon, 1, 5, {
				Position = UDim2.fromOffset(centerPosition.X, centerPosition.Y),
			})
			task.wait(0.2)
			newIcon:Destroy()

			if onReachedCallback then
				onReachedCallback()
			end

			if scaleTargetOnReached then
				local tween = tweenService:Create(
					uiScale,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = scaleAmount }
				)
				tween:Play()
				tween.Completed:Connect(function(playbackState: Enum.PlaybackState)
					if playbackState == Enum.PlaybackState.Completed then
						tweenService
							:Create(
								uiScale,
								TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{ Scale = 1 }
							)
							:Play()
					end
				end)
			end
			amount += 1
		end)
	end

	if yield then
		repeat
			task.wait()
		until amount == amountOfSpawnedItems
	end
end
