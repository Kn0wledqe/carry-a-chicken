--[[
    soundManager.lua
    Kn0wledqe
    Created on 08/20/2024 @ 12:59:37
    
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
local soundManager = {
	previousTrack = "None",
	previousTrackTimePosition = 0,
	soundGroups = {
		SFX = Instance.new("SoundGroup"),
		MUSIC = Instance.new("SoundGroup"),
	},
	playingSounds = {},
	loadedSounds = {},
	failedSounds = {},
	libarries = {
		SFX = {},
		Meme = {},
		UI = {},
		MUSICTRACKS = {},
	},
	loaded = false,
}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--
local contentProvider = game:GetService("ContentProvider")
local tweenService = game:GetService("TweenService")

local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--
local audioFolder = replicatedStorage:WaitForChild("assets"):WaitForChild("audio")

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function soundManager:preloadSound(soundId)
	if self.failedSounds[soundId] then
		return false
	end
	if self.loadedSounds[soundId] then
		return true
	end

	local soundLoaded = false
	local tempSound = Instance.new("Sound")
	tempSound.SoundId = soundId

	contentProvider:PreloadAsync({ tempSound }, function(assetId, assetFetchStatus)
		if assetId == soundId then
			if assetFetchStatus == Enum.AssetFetchStatus.Success then
				soundLoaded = true
				self.loadedSounds[soundId] = true
			else
				self.failedSounds[soundId] = true
			end
		end
	end)

	tempSound:Destroy()
	return soundLoaded
end

function soundManager:registerSound(sound: Sound, group: string)
	if sound and sound:IsA("Sound") and self.soundGroups[group] then
		sound.SoundGroup = self.soundGroups[group]
	end
end

function soundManager:playSound(sound: string, settings: dictionary)
	if not sound then
		warn("Required argument: 'SoundName' is nil!")
		return
	end
	local soundKey = self.libarries.SFX[sound] or self.libarries.Meme[sound] or self.libarries.UI[sound]
	local soundId = soundKey and soundKey.soundId
	if not soundId then
		warn(sound .. " is not a valid SoundEffect!")
		return
	end

	local soundObject = Instance.new("Sound")
	soundObject.Name = sound
	soundObject.Volume = soundKey.baseVolume or 0.5
	if settings and settings.propertiesOverWrites then
		for property, value in settings.propertiesOverWrites do
			soundObject[property] = value
		end
	else
		soundObject.RollOffMaxDistance = 10000
		soundObject.RollOffMinDistance = 10
		soundObject.RollOffMode = Enum.RollOffMode.Inverse
		soundObject.Looped = false
		soundObject.PlaybackSpeed = 1
		soundObject.SoundGroup = self.soundGroups.SFX
	end

	if settings and settings.PitchMultiplier then
		local NewRandom = Random.new()
		local PitchShift = Instance.new("PitchShiftSoundEffect")
		PitchShift.Priority = 1
		PitchShift.Octave += NewRandom:NextNumber(-settings.pitchMultiplier, settings.pitchMultiplier)
		PitchShift.Parent = soundObject
	end

	local dummyPart
	if settings and settings.position then
		if typeof(settings.position) == "Instance" then
			if settings.position:IsA("BasePart") then
				soundObject.Parent = settings.position
			end
		elseif typeof(settings.position) == "Vector3" then
			dummyPart = Instance.new("Attachment")
			dummyPart.WorldPosition = settings.position
			dummyPart.Parent = workspace.Terrain
			soundObject.Parent = dummyPart
		end
	else
		soundObject.Parent = workspace.CurrentCamera
	end

	local fadeTime = settings and settings.fadeTime or 1
	task.spawn(function()
		if self:preloadSound(soundId) then
			soundObject.SoundId = soundId

			if not soundObject.IsLoaded then
				soundObject.Loaded:Wait()
			end

			soundObject:Play()

			if not soundObject.Looped then
				task.delay(settings and settings.Duration or soundObject.TimeLength, function()
					if dummyPart then
						dummyPart:Destroy()
					end
					soundObject:Destroy()
				end)
			elseif settings and settings.Duration then
				task.delay(settings.Duration, function()
					if soundObject then
						tweenService:Create(soundObject, TweenInfo.new(fadeTime), { Volume = 0 }):Play()
						task.delay(fadeTime, function()
							soundObject:Destroy()
							if dummyPart then
								dummyPart:Destroy()
							end
						end)
					end
				end)
			end
			return
		end

		soundObject:Destroy()
	end)

	return soundObject
end

function soundManager:adjustSetting(category: string, level: number)
	if self.SoundGroups[category] then
		self.SoundGroups[category].Volume = (math.clamp(level, 0, 100) / 100)
	end
end

function soundManager:loadMusictrack(trackName: string, settings: dictionary)
	local trackKey = self.libarries.MUSICTRACKS[trackName]
	local track = trackKey and trackKey.soundId

	if not track then
		return
	end

	local thread = function()
		if not self:preloadSound(track) then
			return
		end

		self.musicTrack.SoundGroup = self.soundGroups.MUSIC
		self.musicTrack.Volume = settings and settings.volume or trackKey.baseVolume or 0.15
		self.musicTrack.SoundId = track
		if not self.musicTrack.IsLoaded then
			self.musicTrack.Loaded:Wait()
		end
		self.musicTrack.TimePosition = (
			settings
			and settings.timePosition
			and type(settings.timePosition) == "number"
			and math.min(self.musicTrack.TimeLength, settings.timePosition)
		) or 0
		self.musicTrack.Looped = settings and settings.looped or false
		self.musicTrack:Play()
		self.previousTrack = trackName
	end

	if settings.yield then
		thread()
		task.wait(self.musicTrack.TimeLength - self.musicTrack.TimePosition)
	else
		task.spawn(thread)
	end
end

function soundManager:stopSoundtrack()
	if not self.musicTrack.Playing then
		return
	end

	self.musicTrack:Stop()
	self.musicTrack.SoundId = ""
end

function soundManager:switchTrack(trackName: string, fadeTime: number)
	local trackKey = self.libarries.MUSICTRACKS[trackName]
	local track = trackKey and trackKey.soundId

	if not track then
		return
	end
	if not self:preloadSound(track) then
		return
	end

	fadeTime = fadeTime or 1
	local tween = tweenService:Create(
		self.musicTrack,
		TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
		{ Volume = 0 }
	)
	tween:Play()
	task.delay(fadeTime / 2, function()
		local pos
		if self.PreviousTrack == trackName then
			pos = self.previousTrackTimePosition
		else
			self.previousTrackTimePosition = self.musicTrack.TimePosition
		end
		self.musicTrack.SoundId = track
		self.musicTrack.TimePosition = pos or self.musicTrack.TimePosition
	end)
end

--= Job Initializers =--
function soundManager:InitAsync(): nil
	self._muted = false

	self.musicTrack = Instance.new("Sound")
	self.musicTrack.Parent = script

	for name, soundGroup in self.soundGroups do
		soundGroup.Name = name
		soundGroup.Parent = replicatedStorage
		soundGroup.Volume = 1
	end

	local SFXLibrary = audioFolder:WaitForChild("SFX")
	local MemeLibrary = audioFolder:WaitForChild("Meme")
	local UILibrary = audioFolder:WaitForChild("UI")
	local MUSICLibrary = audioFolder:WaitForChild("music")

	for _, Sound: Sound in SFXLibrary:GetDescendants() do
		if not Sound:IsA("Sound") then
			continue
		end
		self.libarries.SFX[Sound.Name] = { soundId = Sound.SoundId, baseVolume = Sound.Volume }
		if not runService:IsClient() then
			continue
		end

		Sound:Destroy()
	end

	for _, Sound: Sound in MemeLibrary:GetDescendants() do
		if not Sound:IsA("Sound") then
			continue
		end
		self.libarries.Meme[Sound.Name] = { soundId = Sound.SoundId, baseVolume = Sound.Volume }
		if not runService:IsClient() then
			continue
		end

		Sound:Destroy()
	end

	for _, Sound: Sound in UILibrary:GetDescendants() do
		if not Sound:IsA("Sound") then
			continue
		end

		self.libarries.UI[Sound.Name] = { soundId = Sound.SoundId, baseVolume = Sound.Volume }
		if not runService:IsClient() then
			continue
		end

		Sound:Destroy()
	end

	for _, Sound: Sound in MUSICLibrary:GetDescendants() do
		if not Sound:IsA("Sound") then
			continue
		end

		self.libarries.MUSICTRACKS[Sound.Name] = { soundId = Sound.SoundId, baseVolume = Sound.Volume }
		if not runService:IsClient() then
			continue
		end

		Sound:Destroy()
	end

	replicator:listen("sound_manager", function(...)
		self:playSound(...)
	end)

	self.loaded = true
end

--= Return Job =--
return soundManager
