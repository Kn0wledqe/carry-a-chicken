task.wait(10)
local avatarEditorService = game:GetService("AvatarEditorService")
avatarEditorService:PromptAllowInventoryReadAccess()

while task.wait(4 * 60) do
	pcall(function()
		local Favorited = avatarEditorService:GetFavorite(game.PlaceId, 1)
		if not Favorited then
			avatarEditorService:PromptSetFavorite(game.PlaceId, 1, true)
		end
	end)
end
