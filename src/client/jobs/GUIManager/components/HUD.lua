--[[
    HUD.lua
    Kn0wledqe
    Created on 02/26/2025 @ 02:35:56
    
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
local HUD = {}

--= Jobs =--
local replicator = requireInitialized("replicator")
local GUIManager = require(script.Parent.Parent)

local controlManager = requireInitialized("jobs/controlManager")

--= Classes =--

--= Modules & Config =--
local identiferFunctions = requireInitialized("$utils/identifer")

--= Roblox Services =--
local players = game:GetService("Players")

--= Object References =--
local localPlayer = players.LocalPlayer

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function initializeScreenButtons(HUD)
	local unpairButton = HUD.Container.Screen.Unpair
	local dropButton = HUD.Container.Screen.DropChicken
	local tutorial = HUD.Container.Screen.Tutorial
	GUIManager.addHover(unpairButton, nil, nil, true)
	GUIManager.addClick(unpairButton, function()
		replicator:sendToServer("link_manager", "unpair")
		unpairButton.Visible = false
	end, true)

	GUIManager.addHover(dropButton, nil, nil, true)
	GUIManager.addClick(dropButton, function()
		controlManager.drop()
	end, true)

	localPlayer:GetAttributeChangedSignal("linked"):Connect(function()
		print(localPlayer, localPlayer:GetAttribute("linked"))
		local linked = localPlayer:GetAttribute("linked")
		unpairButton.Visible = linked

		tutorial.Visible = false
		dropButton.Visible = false
		if linked then
			if identiferFunctions.isChicken() then
				tutorial.Visible = true
			else
				dropButton.Visible = true
			end
		end
	end)

	localPlayer:GetAttributeChangedSignal("holding"):Connect(function()
		local holding = identiferFunctions.isHolding()
		if identiferFunctions.isChicken() then
			tutorial.Visible = holding
			return
		end

		dropButton.Visible = holding
	end)
end

--= Job API =--

--= Job Initializers =--
function HUD.initialize(HUD): nil
	initializeScreenButtons(HUD)

	local hudButtons = HUD.Container.Screen.Buttons
	local topButtons = HUD.Container.Screen.Top
	--[[
    local screensFolder = HUD.Container.Frames

    local registerGui = function(guiName, button)
		local frame = screensFolder:FindFirstChild(guiName)
		if not frame then
			return
		end

		frame.Visible = true
		frame.Position = UDim2.fromScale(0.5, 1.5)
		
		local closeButton = frame:FindFirstChild("Close")
		if closeButton then
			GUIManager.addHover(closeButton, nil, nil, true)
			GUIManager.addClick(closeButton, function()
				GUIManager:closeGui(guiName)
			end, true)
		end

		GUIManager.addHover(button, nil, nil, true)
		GUIManager.addClick(button, function()
			GUIManager:openGui(guiName)
		end, true)
	end
	]]

	local function initializeList(list)
		for _, button: GuiObject in list do
			--print(button)
			if not button:IsA("ImageButton") and not button:IsA("TextButton") then
				continue
			end

			GUIManager.initializeFrame(button.Name, button)
			--registerGui(button.Name, button)
		end
	end

	initializeList(hudButtons:GetDescendants())
	initializeList(topButtons:GetChildren())
end

--= Return Job =--
return HUD
