return {
	cleanChildren = function(instance: Frame, exceptFor)
		for i, v: Frame in instance:GetChildren() do
			if
				v:IsA("UIListLayout")
				or v:IsA("UIGridLayout")
				or v:IsA("UIPadding")
				or (exceptFor and table.find(exceptFor, v.Name) or false)
			then
				continue
			end

			v:Destroy()
		end
	end,

	getRewardIcon = function(rewardType)
		local image = ""
		if rewardType == "COINS" then
			image = "rbxassetid://72803578440784"
		elseif rewardType == "SPINS" then
			image = "rbxassetid://126508372613070"
		elseif rewardType == "REVIVES" then
			image = "rbxassetid://85726196336833"
		end

		return image
	end,
}
