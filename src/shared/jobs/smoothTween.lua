--[[
    smoothTween.lua
    Kn0wledqe
    Created on 02/25/2025 @ 23:03:09
    
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
local smoothTween = {}

--= Jobs =--
local replicator = requireInitialized("replicator")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

--= Object References =--

--= Constants =--
local REMOTE_KEY = "smooth_tween"

--= Variables =--
local currentTweens = {}

--= Shorthands =--

--= Functions =--

--= Job API =--
function smoothTween.play(target: Instance, info: TweenInfo, properties: { [string]: any }): ()
	local tweenInfo = info :: TweenInfo

	if next(properties) == nil then
		return
	end

	if runService:IsServer() then
		replicator:sendToAll(REMOTE_KEY, target, {
			tweenInfo.Time,
			tweenInfo.EasingStyle,
			tweenInfo.EasingDirection,
		}, properties)

		local currentTime = tick()
		if not currentTweens[target] then
			currentTweens[target] = {}
		end

		local tweenPropertyTimes = currentTweens[target]
		for Name, _ in properties do
			tweenPropertyTimes[Name] = currentTime
		end

		task.delay(tweenInfo.Time, function()
			for Name, Value in properties do
				if tweenPropertyTimes[Name] == currentTime then
					target[Name] = Value
					tweenPropertyTimes[Name] = nil
				end
			end

			if next(tweenPropertyTimes) == nil then
				currentTweens[target] = nil
			end
		end)
		return
	end

    
	tweenService:Create(target, TweenInfo.new(unpack(info)), properties):Play()
end

--= Job Initializers =--
function smoothTween:InitAsync(): nil
	if runService:IsServer() then
		return
	end

	replicator:listen(REMOTE_KEY, function(target, ...)
		if target == nil then
			return
		end

		smoothTween.play(target, ...)
	end)
end

--= Return Job =--
return smoothTween
