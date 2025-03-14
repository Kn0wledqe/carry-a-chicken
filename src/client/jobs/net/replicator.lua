--[[
    replicator.lua
    Originally By FriendlyBiscuit, Rewritten By Kn0wledqe
    Created on 05/04/2022 @ 14:22:18
    
    Description:

    Documentation:

--]]

--= Root =--
local replicator = { Priority = 1 }

--= Roblox Services =--
local players = game:GetService("Players")
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

--= Object References =--
local mainEvent
local mainFunction

--= Constants =--
local MESSAGES = {
	NO_LISTENER = "Failed to handle replicated event %q from the server - no event listener registered!",
}

--= Variables =--
local listeners = {}

--= Internal Functions =--
local function format(template: string, ...): string
	return "[ReplicatorClient] " .. MESSAGES[template]:format(...)
end

--= Job API =--
function replicator:listen(key: string, callback: (...any) -> ())
	local listener = listeners[key]

	if listener then
		table.insert(listener, callback)
	else
		listeners[key] = { callback }
	end
end

function replicator:sendToServer(key: string, ...: any)
	if not mainEvent then
		mainEvent = replicatedStorage:WaitForChild("EVENT")
	end

	mainEvent:FireServer(key, ...)
end

function replicator:fetchFromServer(key: string, ...: any)
	if not mainFunction then
		mainFunction = replicatedStorage:WaitForChild("FUNCTION")
	end

	return mainFunction:InvokeServer(key, ...)
end

--= Job Initializers =--
function replicator:Run()
	mainEvent = replicatedStorage:WaitForChild("EVENT")
	mainFunction = replicatedStorage:WaitForChild("FUNCTION")

	if mainEvent then
		mainEvent.OnClientEvent:Connect(function(key: string, ...: any)
			local listener = listeners[key]

			if listener then
				for _, callback in pairs(listener) do
					callback(...)
				end
			else
				warn(format("NO_LISTENER", key))
			end
		end)
	else
		error()
	end
end

--= Return Job =--
return replicator
