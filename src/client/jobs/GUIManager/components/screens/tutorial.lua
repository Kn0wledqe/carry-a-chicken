--[[
    tutorial.lua
    Kn0wledqe
    Created on 03/19/2025 @ 05:48:33
    
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
local tutorial = {}

--= Jobs =--

--= Classes =--

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")

--= Roblox Services =--
local tweenService = game:GetService("TweenService")

--= Object References =--

--= Constants =--
local JUMP_TIMEOUT = 5
local FADE_TIMES = 3
local FADE_DURATION = 0.5

--= Variables =--
local lastJumpTime = tick()

--= Shorthands =--

--= Functions =--

--= Job API =--
function tutorial.onJumped()
	lastJumpTime = tick()
end

--= Job Initializers =--
function tutorial.initialize(HUD): nil
	local tutorialCursor = HUD:WaitForChild("TutorialCursor")

	local function show()
		tutorialCursor.Visible = true
		tutorialCursor.TextLabel.Visible = true
		tutorialCursor.TextLabel.UIStroke.Enabled = true
	end

	local function hide()
		tutorialCursor.Visible = false
		tutorialCursor.TextLabel.Visible = false
		tutorialCursor.TextLabel.UIStroke.Enabled = false
	end

	task.spawn(function()
		while task.wait() do
			if
				not identiferFunctions.isChicken()
				or not identiferFunctions.isLinked()
				or not identiferFunctions.isHolding()
			then
				hide()
				continue
			end

			if tick() - lastJumpTime >= JUMP_TIMEOUT then
				show()
				for _ = 1, FADE_TIMES do
					local fadeInTween =
						tweenService:Create(tutorialCursor, TweenInfo.new(FADE_DURATION), { ImageTransparency = 0 })
					fadeInTween:Play()
					fadeInTween.Completed:Wait()

					local fadeOutTween =
						tweenService:Create(tutorialCursor, TweenInfo.new(FADE_DURATION), { ImageTransparency = 1 })
					fadeOutTween:Play()
					fadeOutTween.Completed:Wait()
				end

				lastJumpTime = tick() -- Reset the timer after animation
				hide()
			end

			task.wait(1) -- Check every second
		end
	end)
end

--= Return Job =--
return tutorial
