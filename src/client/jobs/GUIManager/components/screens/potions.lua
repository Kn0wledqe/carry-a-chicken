--[[
    potions.lua
    Kn0wledqe
    Created on 03/06/2025 @ 05:42:52
    
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
local potions = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local dataManager = requireInitialized("jobs/dataManager")

--= Classes =--

--= Modules & Config =--
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)

--= Roblox Services =--
local runService = game:GetService("RunService")
local marketplactService = game:GetService("MarketplaceService")
--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function _formatToMS(Seconds)
	local SS = Seconds % 60
	local MM = (Seconds - SS) / 60
	return string.format("%02i:%02i", MM, SS)
	--return MM .. ":" .. (10 > SS and "0" .. SS or SS)
end

local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end

local function _styleTemplate(template, type)
	print(template, type)
end

--= Job API =--
function handleStats()
	local update = {}
	local function refreshPotion()
		for _, info in update do
			if not info[1] then
				continue
			end

			info[1]:Destroy()
		end
		update = {}

		local data = dataManager:get("effects")
		for effect, time in data do
			local _time = time - os.time()
			if _time <= 0 then
				continue
			end

			local newTemplate = potions.template:Clone()
			_styleTemplate(newTemplate, effect)
			newTemplate.Parent = potions.parent

			table.insert(update, { newTemplate, time })
		end
	end

	runService.RenderStepped:Connect(function()
		for _, data in update do
			local time = data[2] - os.time()
			if time < 0 then
				data[1].Visible = false
				continue
			end

			data[1].Visible = true
			data[1].Timer.Text = _formatToMS(time)
		end
	end)

	refreshPotion()
	dataManager:listenOnChange("effects", refreshPotion)
end

function handlePotion()
	for _, potionFrame in potions.frame.Container:GetChildren() do
		if not potionFrame:IsA("ImageLabel") then
			continue
		end

		initializeButton(potionFrame.Buy, function()
			marketplactService:PromptProductPurchase(
				game.Players.LocalPlayer,
				SHOP_CONFIG.DEV_PRODUCTS.POTIONS[potionFrame.Name]
			)
		end)
	end
end

--= Job Initializers =--
function potions.initialize(HUD): nil
	local potionsFrame = HUD.Container.Frames:WaitForChild("Potions")
	potions.frame = potionsFrame
	potions.parent = HUD.Container.Screen.Potions

	potions.template = potions.parent.Template
	potions.template.Parent = nil

	handleStats()
	handlePotion()

	GUIManager:registerGui(potionsFrame, potions)
end

function potions.onClosed(): nil end

--= Return Job =--
return potions
