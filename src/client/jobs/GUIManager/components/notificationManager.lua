--[[
    notificationManager.lua
    Kn0wledqe
    Created on 08/25/2024 @ 15:55:53
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local require = require(game.ReplicatedStorage:WaitForChild("Infinity"))

--= Root =--
local notificationManager = {}

--= Jobs =--
local replicator = require("jobs/net/replicator")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

--= Object References =--
local notifciationTemplate 

--= Constants =--
local CONFIG = {
	["RICHTEXT"] = {
		["Content"] = {
			RichText = true,
		},
		["Content/UIStroke"] = {
			Enabled = false,
		},
		["Content/UIGradient"] = {
			Enabled = false,
		},
	},
}

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function notificationManager.notify(text, duration, customProperties)
	duration = duration or 3

    if not notifciationTemplate then
        return
    end
    
	local notification = notifciationTemplate:Clone()
	notification.Parent = notificationManager.parent
	notification.Visible = true
	notification.Content.Position = UDim2.fromScale(0, 1)
	notification.Content.TextTransparency = 1
	notification.Content.UIStroke.Transparency = 1

	if customProperties then
		for path, properties in customProperties do
			local child = notification
			local paths = string.split(path, "/")
			for _, path in paths do
				child = child:FindFirstChild(path)
			end

			for property, value in properties do
				child[property] = value
			end
		end
	end

	notification.Content.Text = text
	--notification.Content.TextColor3 = color or Color3.new(1, 1, 1)
	--notification.Content.UIStroke.Color = stroke or Color3.new(0, 0, 0)
	notification.Content.UIGradient.Enabled = false

	tweenService
		:Create(notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0, 0),
			TextTransparency = 0,
		})
		:Play()
	tweenService
		:Create(
			notification.Content.UIStroke,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 0,
			}
		)
		:Play()

	task.delay(duration or 3, function()
		tweenService
			:Create(notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0, -1),
				TextTransparency = 1,
			})
			:Play()
		tweenService
			:Create(
				notification.Content.UIStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1,
				}
			)
			:Play()
		task.wait(0.5)
		notification:Destroy()
	end)
end

--= Job Initializers =--
function notificationManager.initialize(HUD): nil
	notificationManager.parent = HUD:WaitForChild("Notification")
    notifciationTemplate = notificationManager.parent.Template
    notifciationTemplate.Parent = nil

	replicator:listen("notification_manager", function(text, duration, configName)
		notificationManager.notify(text, duration, CONFIG[configName])
	end)
end

--= Return Job =--
return notificationManager
