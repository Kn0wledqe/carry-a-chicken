--[[
    init.lua
    Kn0wledqe
    Created on 08/20/2024 @ 12:41:12
    
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
local GUIManager = {
	current = nil,
	loadedGui = {},
}

--= Jobs =--
local soundManager = requireInitialized("jobs/soundManager")

--= Classes =--

--= Modules & Config =--
--local topBarGui = require("$lib/topbarPlus")

--= Roblox Services =--
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")

--= Object References =--
local localPlayer = players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD")

local framesFolder = hud.Container.Frames

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--
local function _getGuiInfo(loadedGui, ID)
	local info
	for _, guiInfo in loadedGui do
		if guiInfo.gui.name ~= ID then
			continue
		end

		info = guiInfo
	end

	return info
end

--= Job API =--
function GUIManager.addHover(object: GuiObject, hoverCallback: any?, leaveCallback: any?, resize: boolean?)
	local UIScale = object:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = object
	end

	local enterConnection = object.MouseEnter:Connect(function()
		if userInputService.TouchEnabled then
			return
		end
		object:SetAttribute("_hovering", true)

		soundManager:playSound(object:GetAttribute("_hoverSound") or "Hover")

		if hoverCallback then
			task.spawn(hoverCallback)
		end

		local clicked = object:GetAttribute("_clicked")
		if not clicked and resize then
			tweenService
				:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
					Scale = 1.1,
				})
				:Play()
		end
	end)

	local leaveConnection = object.MouseLeave:Connect(function()
		object:SetAttribute("_hovering", false)
		if leaveCallback then
			task.spawn(leaveCallback)
		end

		local clicked = object:GetAttribute("_clicked")
		if not clicked and resize then
			tweenService
				:Create(UIScale, TweenInfo.new(0.25), {
					Scale = 1,
				})
				:Play()
		end
	end)

	return {
		disconnect = function()
			leaveConnection:Disconnect()
			enterConnection:Disconnect()

			if leaveCallback then
				task.spawn(leaveCallback)
			end

			local clicked = object:GetAttribute("_clicked")
			if not clicked and resize then
				tweenService
					:Create(UIScale, TweenInfo.new(0.25), {
						Scale = 1,
					})
					:Play()
			end
		end,
	}
end

function GUIManager.addClick(object: GuiButton, callback: any?, resize: boolean?)
	local UIScale = object:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = object
	end

	return object.MouseButton1Click:Connect(function()
		if object:GetAttribute("_clicked") then
			return
		end

		object:SetAttribute("_clicked", true)
		soundManager:playSound(object:GetAttribute("_clickSound") or "Click")

		if callback then
			task.spawn(callback)
		end

		if resize then
			tweenService
				:Create(UIScale, TweenInfo.new(0.05), {
					Scale = 0.9,
				})
				:Play()

			task.wait(0.05)

			--local hovering = object:GetAttribute("_hovering")
			tweenService
				:Create(UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1,
				})
				:Play()

			task.wait(0.2)
		end
		object:SetAttribute("_clicked", false)
	end)
end

function GUIManager.initializeFrame(guiName, button)
	local frame = framesFolder:FindFirstChild(guiName)
	print(frame)
	if not frame then
		return
	end

	local info = _getGuiInfo(GUIManager.loadedGui, frame.Name)
	local closePosiiton = UDim2.fromScale(0.5, 1.5)
	if info and info.customClosePosition then
		closePosiiton = info.customClosePosition 
	end

	frame.Visible = true
	frame.Position =closePosiiton-- UDim2.fromScale(0.5, 1.8)

	local closeButton = frame:FindFirstChild("Close")
	if closeButton then
		GUIManager.addHover(closeButton, nil, nil, true)
		GUIManager.addClick(closeButton, function()
			GUIManager:closeGui(guiName)
		end, true)
	end

	if button then
		GUIManager.addHover(button, nil, nil, true)
		GUIManager.addClick(button, function()
			GUIManager:openGui(guiName)
		end, true)
	end
end

function GUIManager:openGui(ID)
	print(ID)
	local frame = framesFolder:FindFirstChild(ID)
	print(frame)
	if not frame or not frame:GetAttribute("_loaded") then
		return
	end

	local info = _getGuiInfo(self.loadedGui, ID)
	if not info then
		print("gui not registered")
		return
	end

	if self.current then
		local current = self.current

		if current.name == ID then
			return
		end

		self:closeGui(current.name, current.name ~= ID)
	elseif not info.noBlur then
		tweenService
			:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ FieldOfView = 45 }
			)
			:Play()
		tweenService:Create(game.Lighting.Blur, TweenInfo.new(0.55), { Size = 20 }):Play()
	end

	soundManager:playSound("Swipe")

	if info.script.onOpened then
		info.script.onOpened()
	end

	self.current = info
	frame:SetAttribute("_open", true)
	tweenService
		:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = info.customPosition or UDim2.fromScale(0.5, 0.5),
		})
		:Play()
end

function GUIManager:closeGui(ID: string, switching: boolean?)
	if not ID then
		return
	end
	local frame = framesFolder:FindFirstChild(ID)

	local info = _getGuiInfo(self.loadedGui, ID)
	if not info then
		print("gui not registered")
		return
	end

	if self.current and self.current.name == self.current.name then
		if not switching then
			soundManager:playSound("Back")
			tweenService
				:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ FieldOfView = 70 }
				)
				:Play()
			tweenService:Create(game.Lighting.Blur, TweenInfo.new(0.3), { Size = 0 }):Play()
		elseif switching and self.current.noBlur then
			tweenService
				:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ FieldOfView = 45 }
				)
				:Play()
			tweenService:Create(game.Lighting.Blur, TweenInfo.new(0.55), { Size = 20 }):Play()
		end

		if info.script.onClosed then
			info.script.onClosed()
		end

		self.current = nil
	end

	frame:SetAttribute("_open", false)
	tweenService
		:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = info.customClosePosition or UDim2.fromScale(0.5, 1.5),
		})
		:Play()
end

function GUIManager:closeCurrentGui()
	if not self.current then
		return
	end

	self:closeGui(self.current.name)
end

function GUIManager:registerGui(gui, script, custom)
	custom = custom or {}
	table.insert(self.loadedGui, {
		name = gui.Name,
		gui = gui,
		customPosition = custom.position,
		customClosePosition = custom.closePosition,
		noBlur = custom.noBlur,
		script = script,
	})

	gui:SetAttribute("_loaded", true)
end

function GUIManager:getCurrentOpened()
	return self.current and self.current.name or nil
end

--= Job Initializers =--
function GUIManager:InitAsync(): nil
	hud.Enabled = true

	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

	for _, module in script.components:GetDescendants() do
		if not module:IsA("ModuleScript") then
			continue
		end

		module = require(module)
		if not module.initialize then
			continue
		end

		task.spawn(module.initialize, hud)
		--require(module):start(HUD)
	end
end

--= Return Job =--
return GUIManager
