--[[
    dataManager.lua
    Kn0wledqe
    Created on 08/21/2024 @ 11:16:24
    
    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Module Loader =--
local requireInitialized = require; if true then requireInitialized = require(game.ReplicatedStorage.requireInitialized) end

--= Root =--
local dataManager = {
	_listners = {},
	_data = nil,

	loaded = false,
}

--= Jobs =--
local replicator = requireInitialized("jobs/net/replicator")

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--
function dataManager:get(key: string)
	repeat
		task.wait()
	until self.loaded

	return self._data[key]
end

function dataManager:listenOnChange(key: string, callback)
	if not self._listners[key] then
		self._listners[key] = {}
	end

	table.insert(self._listners[key], callback)
end

--= Job Initializers =--
function dataManager:InitAsync(): nil
	--[[
	replicator:listen("data_manager", function(key: string, value: any)
		local oldValue = self._data[key]
		self._data[key] = value

		if self._listners[key] then
			for _, callback in self._listners[key] do
				task.spawn(callback, oldValue, value)
			end
		end
	end)

	repeat
		task.wait(1)
	until replicator:fetchFromServer("is_data_ready")
    ]]

	replicator:listen("data_manager", function(key, value): nil
        if not self._data then
            return
        end

        
        print("data changed", key)
		local oldValue
		if self._data[key] then
			oldValue = self._data[key]
		end

		self._data[key] = value

		if self._listners[key] then
			for _, callback in self._listners[key] do
				task.spawn(callback, value, oldValue)
			end
		end
	end)

    print("dddd")
	repeat
		self._data = replicator:fetchFromServer("data_manager")
		task.wait(.1)
	until self._data

    self.loaded = true

	print(self._data)
end

--= Return Job =--
return dataManager
