--[[
    skins.lua
    Kn0wledqe
    Created on 02/26/2025 @ 16:18:21
    
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
local skins = {
	camera = {},
}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local notificationManager = requireInitialized(script.Parent.Parent.notificationManager)
local dataManager = requireInitialized("jobs/dataManager")
local replicator = requireInitialized("jobs/net/replicator")

local soundManager = requireInitialized("jobs/soundManager")

--= Classes =--

--= Modules & Config =--
local SKINS_CONFIG = requireInitialized("$config/skins")
local helperFunctions = requireInitialized("utils/helperFunctions")

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local marketplacService = game:GetService("MarketplaceService")
local runService = game:GetService("RunService")

--= Object References =--
local skinsFolder = replicatedStorage:WaitForChild("assets"):WaitForChild("skins")
local skinStands = workspace:WaitForChild("Map"):WaitForChild("Spawn"):WaitForChild("ItemStands")

--= Constants =--

local VIEWPORT_CAMERA = {
	DISTANCE = 6,
	FOV = 50,
	PITCH_ANGLE = 15,

	ITEM_YAXIS = 0,

	ROTATION_SPEED = 100,
}

local VIEWFRAME_COLOR = {
	OWNED = Color3.new(1, 1, 1),
	NOT_OWNED = Color3.new(0.3, 0.3, 0.3),
}

local BUTTON_PROPERTIES = {
	EQUIPPTABLE = "rbxassetid://125799463084857",

	NON_EQUIPPTABLE = "rbxassetid://114528142665401",
}

--= Variables =--
local skinStandsPrompts = {}

--= Shorthands =--
local function _setUpViewModel(viewportFrame)
	local viewportCamera = Instance.new("Camera")
	--viewportCamera.FieldOfView = VIEWPORT_CAMERA.FOV
	viewportCamera.Parent = viewportFrame
	viewportFrame.CurrentCamera = viewportCamera
end

--= Functions =--

--= Job API =--

--= Job Initializers =--
function initializeSkinStands()
	for _, skinItem in skinStands:GetChildren() do
		local info = SKINS_CONFIG[tonumber(skinItem.Name)]
		if not info then
			continue
		end

		local proxmityPrompt: ProximityPrompt =
			skinItem:WaitForChild("Main"):WaitForChild("Attachment"):WaitForChild("ProximityPrompt")
		proxmityPrompt.ActionText = `Buy {info.price}`
		proxmityPrompt.ObjectText = info.title

		proxmityPrompt.TriggerEnded:Connect(function(playerWhoTriggered)
			soundManager:playSound("OpenRobuxPrompt")
			marketplacService:PromptGamePassPurchase(playerWhoTriggered, info.gamepassID)
		end)
		--skinStandsPrompts[info.ID] = { proxmityPrompt, {} }
	end

	local groupStand = skinStands:WaitForChild("GroupStand")
	local groupStandPrompt: ProximityPrompt =
		groupStand:WaitForChild("Main"):WaitForChild("Attachment"):WaitForChild("ProximityPrompt")
	groupStandPrompt.TriggerEnded:Connect(function(playerWhoTriggered)
		local sucess, message = replicator:fetchFromServer("activity_reward")

		if sucess then
			soundManager:playSound("Reward")
			notificationManager.notify(message, nil, {
				["Content"] = {
					TextColor3 = Color3.fromRGB(75, 255, 96),
					RichText = false,
				},
				["Content/UIStroke"] = {
					Thickness = 2,
					Color = Color3.fromRGB(0, 0, 0), --Color3.fromRGB(41, 141, 53),
				},
				["Content/UIGradient"] = {
					Enabled = false,
				},
			})
		else
			soundManager:playSound("Error")
			notificationManager.notify(`⚠️ {message} ⚠️`, nil, {
				["Content"] = {
					TextColor3 = Color3.fromRGB(221, 30, 75),
					RichText = false,
				},
				["Content/UIStroke"] = {
					Thickness = 2,
					Color = Color3.fromRGB(0, 0, 0), --Color3.fromRGB(41, 141, 53),
				},
				["Content/UIGradient"] = {
					Enabled = false,
				},
			})
		end
	end)
end

function skins.initialize(HUD): nil
	local skinsFrame = HUD.Container.Frames:WaitForChild("Skins")
	skins.frame = skinsFrame
	skins.template = skinsFrame.Container.Template
	skins.template.Parent = nil

	repeat
		task.wait()
	until dataManager.loaded

	initializeSkinStands()

	local t = 0
	runService.PostSimulation:Connect(function(deltaTimeSim)
		t += deltaTimeSim

		for _, camera in skins.camera do
			camera.CFrame = CFrame.Angles(0, math.rad(t * VIEWPORT_CAMERA.ROTATION_SPEED), 0)
				* CFrame.new(0, 0, VIEWPORT_CAMERA.DISTANCE)
		end
	end)

	dataManager:listenOnChange("skins", skins.refresh)
	GUIManager:registerGui(skinsFrame, skins)
end

function skins.refresh(ignoreOpen)
	if not ignoreOpen and GUIManager.getCurrentOpened(GUIManager) ~= skins.frame.Name then
		return
	end

	local ownedSkins = dataManager:get("skins")
	local selectedSkin = dataManager:get("equippedSkin")
	print(ownedSkins)
	local parent = skins.frame.Container
	helperFunctions.cleanChildren(parent)

	local debounce = false
	local current = nil
	for _, skin in SKINS_CONFIG do
		local skinTemplate = skins.template:Clone()
		local isFound = table.find(ownedSkins, skin.ID)
		skinTemplate.Title.Text = skin.title
		skinTemplate.Action.Image = BUTTON_PROPERTIES.EQUIPPTABLE

		if selectedSkin == skin.ID then
			current = skinTemplate
			skinTemplate.LayoutOrder = 0
			skinTemplate.Action.Title.Text = "Equipped"
			skinTemplate.Action.Interactable = false
		elseif isFound then
			skinTemplate.Action.Title.Text = "Equip"
			skinTemplate.LayoutOrder = 1
			skinTemplate.Skin.ImageColor3 = VIEWFRAME_COLOR.OWNED
		else
			skinTemplate.Action.Image = BUTTON_PROPERTIES.NON_EQUIPPTABLE
			skinTemplate.LayoutOrder = 99
			skinTemplate.Action.Title.Text = `{skin.price} Coins`

			if skin.gamepassID then
				skinTemplate.Action.Title.Text = `{skin.price}`
			end

			if skin.purchase_text then
				skinTemplate.Action.Title.Text = skin.purchase_text
			end

			if not skin.purchaseable then
				skinTemplate.Action.Interactable = false
			end

			skinTemplate.Skin.ImageColor3 = VIEWFRAME_COLOR.NOT_OWNED
		end

		if skin.layoutOrder then
			skinTemplate.LayoutOrder = skin.layoutOrder
		end

		local skin_model = skinsFolder:FindFirstChild(skin.name)
		if not skin_model then
			print("no skin model:", skin_model)
			skinTemplate:Destroy()
			continue
		end
		local handle: Part = skin_model:Clone()

		_setUpViewModel(skinTemplate.Skin)
		handle.Parent = skinTemplate.Skin

		handle:PivotTo(
			CFrame.new(0, VIEWPORT_CAMERA.ITEM_YAXIS, 0) * CFrame.Angles(math.rad(VIEWPORT_CAMERA.PITCH_ANGLE), 0, 0)
		)
		skinTemplate.Skin.Camera.CFrame = CFrame.new(Vector3.new(0, 0, VIEWPORT_CAMERA.DISTANCE), Vector3.new(0, 0, 0))

		table.insert(skins.camera, skinTemplate.Skin.Camera)

		GUIManager.addHover(skinTemplate.Action, nil, nil, true)
		GUIManager.addClick(skinTemplate.Action, function()
			if debounce then
				return
			end
			debounce = true

			local action = "purchase"
			if isFound then
				action = "equip"
			end

			if action == "purchase" and skin.gamepassID then
				marketplacService:PromptGamePassPurchase(players.LocalPlayer, skin.gamepassID)
			else
				local successful, error = replicator:fetchFromServer("skin_manager", action, skin.ID)
				if successful then
					if action == "purchase" then
						skinTemplate.Action.Title.Text = "Equip"
						skinTemplate.Skin.ImageColor3 = VIEWFRAME_COLOR.OWNED
					else
						if current then
							current.Action.Title.Text = "Equip"
							current.Action.Interactable = true
						end

						skinTemplate.Action.Title.Text = "Equipped"
						skinTemplate.Action.Interactable = false
						current = skinTemplate
					end
				else
					notificationManager.notify(`⚠️ {error or "An error has occurred"} ⚠️`, nil, {
						["Content"] = {
							TextColor3 = Color3.fromRGB(221, 30, 75),
							RichText = false,
						},
						["Content/UIStroke"] = {
							Thickness = 2,
							Color = Color3.fromRGB(0, 0, 0), --Color3.fromRGB(41, 141, 53),
						},
						["Content/UIGradient"] = {
							Enabled = false,
						},
					})
				end
			end

			debounce = false
		end, false)

		skinTemplate.Parent = parent
	end
end

function skins.onOpened()
	skins.refresh(true)
end

function skins.onClosed(): nil
	local parent = skins.frame.Container
	skins.camera = {}
	helperFunctions.cleanChildren(parent)
end

--= Return Job =--
return skins
