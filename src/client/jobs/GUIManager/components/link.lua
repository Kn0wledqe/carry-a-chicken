--[[
    link.lua
    Kn0wledqe
    Created on 02/26/2025 @ 02:44:06
    
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
local link = {}

--= Jobs =--
local replicator = requireInitialized("replicator")
local GUIManager = require(script.Parent.Parent)

local checkpoint = requireInitialized(script.Parent.screens.checkpoint)

--= Classes =--

--= Modules & Config =--

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--

--= Shorthands =--

--= Functions =--

--= Job API =--

--= Job Initializers =--
function link.initialize(HUD): nil
	local exitButton = HUD.Container.Screen.Exit
	local countDownText = HUD.Container.Screen.Countdown

	local thread
	GUIManager.addHover(exitButton, nil, nil, true)
	GUIManager.addClick(exitButton, function()
		replicator:sendToServer("linking_manager", "exit")
		exitButton.Visible = false
		countDownText.Visible = false
		if thread then
			task.cancel(thread)
            thread = nil
		end
		GUIManager:closeGui("Checkpoint")
	end, true)

	replicator:listen("linking_manager", function(action, info)
        print(action)
		if action == "joined" then
			exitButton.Visible = true
		elseif action == "startCountdown" then
			countDownText.Visible = true
			thread = task.spawn(function()
				while task.wait() do
					local timeLeft = math.max(info.startsOn - os.time(), 0)
					if timeLeft == 0 then
						return
					end


					countDownText.Text = `{timeLeft}s before starting...`
				end
			end)

			if info.worldThereshold then
				checkpoint.setInfo(info.pair, info.worldThereshold)
				GUIManager:openGui("Checkpoint")
			end
		elseif action == "stopCountdown" then
            print("done! called!")
			if thread then
				task.cancel(thread)
                thread = nil
			end

			countDownText.Visible = false
			print("called")
			GUIManager:closeGui("Checkpoint")
		elseif action == "reset" then
			countDownText.Visible = false
			exitButton.Visible = false

			GUIManager:closeGui("Checkpoint")
		end
	end)
end
--= Return Job =--
return link
