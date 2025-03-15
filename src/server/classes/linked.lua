--[[
    linked.lua
    Kn0wledqe
    Created on 02/21/2025 @ 11:03:24
    
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

--= Class Root =--
local linked = {}
linked.__classname = "linked"

--= Controllers =--
local replicator = requireInitialized("jobs/net/replicator")
local dataWrapper = requireInitialized("jobs/data/dataWrapper")

local enviormentManager = requireInitialized("jobs/enviormentManager")
local badgeManager = requireInitialized("jobs/badgeManager")

--= Other Classes =--

--= Modules & Config =--
local classify = requireInitialized("$lib/classify")
local SKINS_CONFIG = requireInitialized("$config/skins")

local collisionManager = requireInitialized("$jobs/collisionManager")

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local analyticsService = game:GetService("AnalyticsService")

--= Instance References =--
local startTeleport = workspace.Teleports.Start
local chickenModelsFolder = replicatedStorage.assets.skins

local featherVFX = replicatedStorage.assets.FeatherVFX

local dropOffTimer = replicatedStorage.assets.DroppedTimer
local animateScript = game:GetService("StarterPlayer").StarterCharacterScripts.Animate

local shirkVFX = replicatedStorage.assets.ShirkVFX
local expandVFX = replicatedStorage.assets.ExpandVFX

local WELD = Instance.new("Motor6D")
WELD.Name = "Handle"
WELD.C0 = CFrame.new(Vector3.new(-0.128, 0.178, -2.16))

--= Constants =--
local STATES = {
	DROPPED = "dropped",
	PICKED = "picked",
}

local MAXMIUM_DROP = 60
local MAX_PICK_DISTANCE = 10

local SCALE_DROPPED = 0.42
local SCALE_GRABBED = 0.7

--= Variables =--
local linkedClasses = {}

--= Shorthands =--

--= Functions =--
local function setNetworkOwnership(model: Model, player: Player)
	player = player or nil
	for _, part: Part in model:GetChildren() do
		if not part:IsA("BasePart") then
			return
		end

		part:SetNetworkOwner(player)
	end
end

local function resetAttributes(player: Player)
	player:SetAttribute("holding", nil)
	player:SetAttribute("linked", nil)
	player:SetAttribute("isChicken", nil)
end

local function getSkinModelFromID(ID)
	for _, skin in SKINS_CONFIG do
		if skin.ID ~= ID then
			continue
		end

		return chickenModelsFolder[skin.name]
	end
end

local function setCollisions(model: Model, enable)
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if enable then
			if part:GetAttribute("_collision") then
				part.CanCollide = part:GetAttribute("_collision")
			end

			if part:GetAttribute("_canTouch") then
				part.CanTouch = part:GetAttribute("_canTouch")
			end
		else
			if part.CanCollide then
				part:SetAttribute("_collision", true)
				part.CanCollide = false
			end

			if part.CanTouch then
				part:SetAttribute("_canTouch", true)
				part.CanTouch = false
			end
		end
	end
end

--= Class Internal =--
function linked:drop(_, position)
	local player = self._players.player
	local chicken = self._players.chicken
	if not player or not chicken then
		return
	end

	player:SetAttribute("holding", false)
	chicken:SetAttribute("holding", false)
	setCollisions(chicken.Character, true)
	for _, weld in self._welds do
		weld:Destroy()
	end

	self:setState(STATES.DROPPED)
	setNetworkOwnership(chicken.Character, chicken)
	self:setChickenScale(SCALE_DROPPED)

	task.wait(0.1)
	if position then
		chicken.Character:PivotTo(CFrame.new(position))
	end

	replicator:sendToPlayers("link_manager", { player, chicken }, "dropped")
end

function linked:setChickenScale(scale)
	local currentScale = self._models.chicken:GetScale()
	local vfx = shirkVFX
	if currentScale < scale then
		vfx = expandVFX
	end
	self._models.chicken:ScaleTo(scale)
	replicator:sendToAll("vfx_maanger", vfx, self._models.chicken:GetPivot().Position)
	--[[
	vfx = vfx:Clone()
	vfx.Position = self._models.chicken:GetPivot().Position
	vfx.Parent = workspace

	for _, effect in vfx:GetChildren() do
		if not effect:IsA("ParticleEmitter") then
			continue
		end

		effect:Emit(1)
	end
	]]
end

function linked:setState(state)
	local chickenHumanoid: Humanoid = self._models.chicken.Humanoid
	if state == STATES.DROPPED then
		self._timeDropped = workspace:GetServerTimeNow() + MAXMIUM_DROP
		chickenHumanoid.EvaluateStateMachine = true
	elseif state == STATES.PICKED then
		chickenHumanoid.EvaluateStateMachine = false
		self._timeDropped = nil
	end

	self._state = state
end

function linked:_updateTimer()
	if not self._timeDropped then
		if self._timer then
			self._timer.Enabled = false
		end

		return
	end

	if not self._timer then
		self._timer = dropOffTimer:Clone()
		self._timer.Parent = self._models.chicken.PrimaryPart
		self._timer.Enabled = true
	end

	local time = math.max(self._timeDropped - workspace:GetServerTimeNow(), 0)

	if workspace:GetServerTimeNow() - self._lastTimerUpdate > 1 then
		self._timer.Enabled = true
		self._timer.Timer.Text = math.floor(time)
		self._lastTimerUpdate = workspace:GetServerTimeNow()
	end

	if time ~= 0 then
		return
	end

	requireInitialized("jobs/deathManager").handlePlayerDeath(self._players.chicken)
	print("reset char")
end

function linked:grab(ignoreDistance)
	if
		not ignoreDistance
		and (self._models.chicken.PrimaryPart.Position - self._models.player.PrimaryPart.Position).Magnitude
			> MAX_PICK_DISTANCE
	then -- do a distance check
		return
	end

	local player = self._players.player
	local chicken = self._players.chicken
	if not player or not chicken then
		return
	end

	player:SetAttribute("holding", true)
	chicken:SetAttribute("holding", true)

	setNetworkOwnership(chicken.Character, player)
	local newWeld = WELD:Clone()
	newWeld.Part0 = player.Character.Torso
	newWeld.Part1 = chicken.Character.PrimaryPart
	newWeld.Parent = player.Character
	self:setState(STATES.PICKED)
	table.insert(self._welds, newWeld)
	self:setChickenScale(SCALE_GRABBED)
	setCollisions(chicken.Character, false)
	replicator:sendToPlayers("link_manager", { player, chicken }, "picked")
	--replicator:sendToPlayer("link_manager", chicken, "setCamera", {target = player})
end

function linked:unpair()
	self:Destroy()
end

function linked:cleanup()
	self._pair = 0
	self._timeDropped = nil

	for _, player in self._players do
		player:LoadCharacter()
	end

	for _, weld in self._welds do
		weld:Destroy()
	end
	self._welds = {}

	if self._timer then
		self._timer:Destroy()
		self._timer = nil
	end

	for _, player in self._players do
		player:SetAttribute("holding", nil)
		--player:SetAttribute("linked", nil)
	end
end

function linked:spawnCharacters()
	replicator:sendToPlayers("link_manager", { self._players.player, self._players.chicken }, "transition")

	local targetPlayer = self._players.chicken
	local skinID = dataWrapper.getEquippedSkin(targetPlayer) or 1
	local newChicken: Model = getSkinModelFromID(skinID):Clone()
	newChicken:SetAttribute("Chicken", true)
	collisionManager.setGroup(newChicken, collisionManager.GROUPS.CHICKEN)

	animateScript:Clone().Parent = newChicken
	--featherVFXScript:Clone().Parent = newChicken
	for _, child: BasePart in newChicken:GetDescendants() do
		if child:IsA("BasePart") then
			child.Massless = true
		end
	end

	self._featherVFX = featherVFX:Clone()
	self._featherVFX.Parent = newChicken.PrimaryPart

	targetPlayer:SetAttribute("isChicken", true)
	task.wait(0.5)
	targetPlayer.Character = newChicken
	newChicken.Parent = workspace

	self._models.chicken = newChicken
	self._models.player = self._players.player.Character

	--	replicator:sendToPlayer("link_manager", targetPlayer, "setCamera")
	setNetworkOwnership(newChicken, targetPlayer)
	--replicator:sendToPlayers("link_manager", {targetPlayer, self._players.player}, "initialize", {})

	replicator:sendToPlayer("link_manager", targetPlayer, "initialize", { pair = self._players.player })
	replicator:sendToPlayer("link_manager", self._players.player, "initialize", { pair = targetPlayer })
end

function linked:_updateFeatherVFX()
	local rootPart = self._models.player.PrimaryPart
	if not rootPart then
		return
	end
	--print(rootPart.Velocity)
	if rootPart.Velocity.Y < -1 then
		self._featherVFX:Emit(1)
	end
end

function linked:worldFinished(worldID)
	local worldIndexs = {
		{
			--funnel_identifier = { 3, "Finished First World" },
			badge = "FIRST_WORLD",
			coins = 25,
		},

		{
			--funnel_identifier = { 4, "Finished Second World" },
			badge = "SECOND_WORLD",
			coins = 50,
			won = true,
		},
	}

	local worldInfo = worldIndexs[worldID]
	if not worldInfo then
		return
	end

	if self.worldProgress and self.worldProgress >= worldID then
		return
	end

	self.worldProgress = worldID
	for _, player in self._players do
		if worldInfo.badge then
			badgeManager.awardBadge(player, worldInfo.badge)
		end

		if worldInfo.funnel_identifier then
			game:GetService("AnalyticsService")
				:LogOnboardingFunnelStepEvent(player, worldInfo.funnel_identifier[1], worldInfo.funnel_identifier[2])
		end

		if worldInfo.coins then
			dataWrapper.addToCoins(player, worldInfo.coins * (if dataWrapper.hasVip(player) then 2 else 1))
		end

		if worldInfo.won then
			dataWrapper.addToWins(player, 1)
		end

		dataWrapper.setUnlockedWorld(player, worldID)
	end

	if worldInfo.won then
		--self:win()
		self:Destroy()
	end
end

--[[
function linked:win()
	for _, player in self._players do
		if not player then
			continue
		end

		pcall(function()
			dataWrapper.addToWins(player, 1)
			dataWrapper.addToCoins(player, 50 * (if dataWrapper.hasVip(player) then 2 else 1))
			game:GetService("AnalyticsService"):LogOnboardingFunnelStepEvent(player, 4, "Finished Second World")
		end)
	end

	self:Destroy()
end
]]

function linked:spawn(spawn)
	self:cleanup()

	self:spawnCharacters()
	self:grab(true)

	local spawnCFrame = startTeleport.CFrame
	if spawn then
		spawnCFrame = spawn.CFrame
	end
	self._players.player.Character.HumanoidRootPart.CFrame = spawnCFrame

	replicator:sendToPlayers("death_manager", { self._players.player, self._players.chicken }, "hide")
end

function linked:disband()
	self:Destroy()
end

--= Class API =--
function linked.getClassByPlayer(_player): any
	for _, class in linkedClasses do
		for _, player in class._players do
			if player ~= _player then
				continue
			end

			return class
		end
	end
end

--= Class Constructor =--
function linked.new(player, chicken, progress, spawn): any
	local self = classify(linked)

	self._players = {
		player = player,
		chicken = chicken,
	}

	for _, player in self._players do
		enviormentManager.resetCoins(player)
		enviormentManager.resetProgress(player)

		pcall(function()
			analyticsService:LogOnboardingFunnelStepEvent(player, 2, "Paired Up")
			badgeManager.awardBadge(player, "PAIRED_UP")
		end)
	end

	self:_protect("_players")

	self._spawn = nil
	self:_protect("_spawn")

	self._welds = {}
	self._lastTimerUpdate = 0
	self._models = {}
	--print(self)

	player:SetAttribute("linked", true)
	chicken:SetAttribute("linked", true)

	table.insert(linkedClasses, self)
	self.worldProgress = progress
	self:spawn(spawn)

	task.spawn(function()
		local lastFeatherCall = os.clock()
		while task.wait() do
			pcall(function()
				self:_updateTimer()
			end)

			if os.clock() - lastFeatherCall < 0.2 then
				continue
			end
			lastFeatherCall = os.clock()
			pcall(function()
				self:_updateFeatherVFX()
			end)
		end
	end)

	--return self
end

function linked:_onDestroy()
	for i = #linkedClasses, 1, -1 do
		local class = linkedClasses[i]
		if class ~= self then
			continue
		end

		table.remove(linkedClasses, i)
	end

	for _, player: Player in self._players do
		if not player then
			continue
		end

		pcall(function()
			resetAttributes(player)

			replicator:sendToPlayer("link_manager", player, "reset")
			player:LoadCharacter()
		end)
	end
end

--= Internals =--
players.PlayerRemoving:Connect(function(_player)
	for _, class in linkedClasses do
		for _, player in class._players do
			if player ~= _player then
				continue
			end

			class:Destroy()
			return
		end
	end
end)

players.PlayerAdded:Connect(function(player)
	game:GetService("AnalyticsService"):LogOnboardingFunnelStepEvent(player, 1, "Player Joined")
end)

local allowedFunctions = { "drop", "grab", "unpair" }
replicator:listen("link_manager", function(player: Player, action, ...)
	local class = linked.getClassByPlayer(player)
	if not class then
		print("[LINKED] PLAYER NOT LINKED")
		return
	end

	if not table.find(allowedFunctions, action) then
		return
	end

	if (action == "drop" or action == "grab") and class._players.player ~= player then
		return
	end

	local actionFunc = class[action] -- .. "_action"
	if not actionFunc then
		print("[LINKED] ACTION NOT REGONIZED")
		return
	end

	actionFunc(class, player, ...)
end)

--= Class Properties =--
linked.__properties = {}

--= Return Class =--
return linked
