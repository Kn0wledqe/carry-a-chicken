
--[[

	Info: This function is used to call a function safely, 
			meaning that if the function errors, it will try again
			a certain number of times


	--/Example of how to use the SafeCall function (failing function)
	-- local success, a, b, c, d, e, f, g = SafeCall(function()
	-- 	game.Workspace.asf.Position = Vector3.new(0, 0, 0)
	-- 	return "a", "b", "c", "d", "e", "f", "g"
	-- end)
	-- warn(success, a, b, c, d, e, f, g)

	--/Example of how to use the SafeCall function (successful function)
	-- local success, a, b, c, d, e, f, g = SafeCall(function()
	-- 	return "a", "b", "c", "d", "e", "f", "g"
	-- end)
	-- warn(success, a, b, c, d, e, f, g)

]]

function SafeCall(func, maxAttempts, repeatInterval, ...)

	--/Holder for the results of the pcall
	local pcallResults

	--/Loop through the maxAttempts
	for i = 1, maxAttempts or 5 do

		--/pcall returns a table with the first value being a boolean indicating success,
		--/and the rest being the return values of the function
		--/so we put all the returned values of the pcall into a table
		--/and then unpack it to get the values
		pcallResults = {pcall(func, ...)}
		local pcallSuccess = pcallResults[1]

		--/if the pcall was successful, then we can return the values
		if pcallSuccess then
			break
		end

		--/if the pcall was not successful, then we wait and try again
		task.wait(repeatInterval or 1)
	end
	
	return table.unpack(pcallResults)
end


return SafeCall