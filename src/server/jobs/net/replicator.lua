--[[
    replicator.lua
   	Originally By FriendlyBiscuit, Rewritten By Kn0wledqe
    Created on 05/02/2022 @ 16:05:36
    
    Description:

    Documentation:

--]]

--= Root =--
local replicator = { Priority = 0 }

--= Roblox Services =--
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

--= Object References =--
local mainEvent
local mainFunction

--= Constants =--
local MESSAGES = {
	NO_LISTENER = "Failed to handle replicated event %q from %q - no event listener registered!",
	STUDIO_MODE = "Running in Studio Environment Mode.",
}

--= Variables =--
local listeners = {}

--= Internal Functions =--
local function format(template: string, ...: any): string
	return "[ReplicatorServer] " .. MESSAGES[template]:format(...)
end

--= Job API =--
function replicator:listen(key: string, callback: (client: Player, ...any) -> ())
	local listener = listeners[key]

	if listener then
		table.insert(listener, callback)
	else
		listeners[key] = { callback }
	end
end

function replicator:sendToAll(key: string, ...: any)
	mainEvent:FireAllClients(key, ...)
end

function replicator:sendToPlayer(key: string, target: Player, ...: any)
	mainEvent:FireClient(target, key, ...)
end

function replicator:sendToPlayers(key: string, targets: { Player }, ...: any)
	for _, player in players:GetPlayers() do
		if table.find(targets, player) then
			mainEvent:FireClient(player, key, ...)
		end
	end
end

function replicator:sendToOthers(key: string, skip: Player, ...: any)
	for _, player in pairs(players:GetPlayers()) do
		if player ~= skip then
			mainEvent:FireClient(player, key, ...)
		end
	end
end

--= Job Initializers =--
function replicator:Init()
	--mainEvent = replicatedStorage:WaitForChild("EVENT")
	mainEvent = Instance.new("RemoteEvent")
	mainEvent.Name = "EVENT"
	mainEvent.Parent = replicatedStorage
	--mainFunction = replicatedStorage:WaitForChild("FUNCTION")
	mainFunction = Instance.new("RemoteFunction")
	mainFunction.Name = "FUNCTION"
	mainFunction.Parent = replicatedStorage

	mainEvent.OnServerEvent:Connect(function(client: Player, key: string, ...)
		local listener = listeners[key]

		if listener then
			for _, callback in pairs(listener) do
				callback(client, ...)
			end
		else
			warn(format("NO_LISTENER", key, client.name))
		end
	end)

	mainFunction.OnServerInvoke = function(client: Player, key: string, ...)
		local listener = listeners[key]

		if listener then
			return listener[1](client, ...)
		else
			warn(format("NO_LISTENER", key, client.name))
		end
	end
end
--[[
function Replicator:Immediate()
	if EVENT_UUID == "" or self.FLAGS.IS_STUDIO then
		EVENT_UUID = "REPLICATOR_STUDIO"
	end
end
]]
--= Return Job =--
return replicator
