local sillyRequire = require(script.Parent.Infinity)

return function(module: ModuleScript | string)
	if typeof(module) == "string" then
		return sillyRequire(module)
	end

	local required = require(module)
	if typeof(required) == "table" and (required.Init or required.InitAsync) then
		if not module:GetAttribute("_loaded") then
			module:GetAttributeChangedSignal("_loaded"):Wait()
		end
	end

	return required
end
