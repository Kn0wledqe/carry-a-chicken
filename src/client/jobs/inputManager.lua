--[[
    InputManager
    Kn0wledqe
    Created on 06/28/2024 @ 23:09:57

    Description:
        No description provided.
    
    Documentation:
        No documentation provided.
--]]

--= Root =--
local InputManager = {}

--= Services =--
local userInputService = game:GetService("UserInputService")

--= Constants =--

--= Variables =--
local inputs = {}

--= Enumerators =--
InputManager.TRIGGERS = { ALL = 1, BEGAN = 2, ENDED = 3 }

--= Internal =--

--= API =--
function InputManager:unRegister(key)
	local _input = inputs[key]
	if not _input then
		return
	end

	for _, signal in _input.signals do
		pcall(function()
			signal:disconnect()
		end)
	end

	inputs[key] = nil
end

function InputManager:register(inputKey, triggerType, context, once, callback)
	if inputs[inputKey] then
		InputManager:unRegister(inputKey)
	end

	triggerType = triggerType or InputManager.TRIGGERS.BEGAN
	local _template = {
		once = once,
		trigger = triggerType and triggerType or 2,
		signals = {},
		inputs = {},
		callback = callback,
	}

	for _, value in context do
		if typeof(value) == "RBXScriptSignal" then
			table.insert(_template.signals, value:Connect(callback))
		elseif typeof(value) == "EnumItem" then
			if value.EnumType ~= Enum.UserInputType and value.EnumType ~= Enum.KeyCode then
				error("Invalid EnumType supplied. Acceptable types: UserInputType, KeyCode")
			end

			table.insert(_template.inputs, value)
		else
			error("Invalid input context supplied. Acceptable contexts: UserInputType, KeyCode, RBXScriptSignal")
		end
	end

	inputs[inputKey] = _template
end

--= Controller Initializers =--
function InputManager:Init()
	userInputService.InputBegan:Connect(function(_input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		for key, input in pairs(inputs) do
			if input.trigger == InputManager.TRIGGERS.ENDED then
				continue
			end

			for _, value in input.inputs do
				local _valid = false

				if value.EnumType == Enum.UserInputType and _input.UserInputType == value then
					_valid = true
				end

				if value.EnumType == Enum.KeyCode and _input.KeyCode == value then
					_valid = true
				end

				if not _valid then
					continue
				end

				task.spawn(input.callback, _input)

				if input.once then
					InputManager:Unregister(key)
				end
			end
		end
	end)

	userInputService.InputEnded:Connect(function(_input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		for key, input in pairs(inputs) do
			if input.trigger == InputManager.TRIGGERS.BEGAN then
				continue
			end

			for _, value in input.inputs do
				local _valid = false

				if value.EnumType == Enum.UserInputType and _input.UserInputType == value then
					_valid = true
				end

				if value.EnumType == Enum.KeyCode and _input.KeyCode == value then
					_valid = true
				end

				if not _valid then
					continue
				end

				task.spawn(input.callback, _input)

				if input.once then
					InputManager:Unregister(key)
				end
			end
		end
	end)
end

--= Return Controller =--
return InputManager
