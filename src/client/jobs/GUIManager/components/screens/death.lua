--[[
    death.lua
    Kn0wledqe
    Created on 03/06/2025 @ 14:08:55
    
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
local death = {}

--= Jobs =--(
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local replicator = requireInitialized("jobs/net/replicator")
local dataManager = requireInitialized("jobs/dataManager")

--= Classes =--

--= Modules & Config =--
local SHOP_CONFIG = requireInitialized(game.ReplicatedStorage.config.shop)

--= Roblox Services =--
local marketplaceServie = game:GetService("MarketplaceService")

--= Object References =--

--= Constants =--
local TIME_BEFORE_CLOSE = 20

--= Variables =--

--= Shorthands =--

--= Functions =--

local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end

--= Job API =--
function death.startTimer()
	local time = os.clock() + TIME_BEFORE_CLOSE

	repeat
		task.wait()
		local percent = (time - os.clock()) / TIME_BEFORE_CLOSE
		death.frame.Timer.Bar.Size = UDim2.fromScale(percent, 1)
	until os.clock() - time >= 0

	death.backToLobby()
end

function death.backToLobby()
	replicator:sendToServer("death_manager", "unpair")
end

function death.pairAgain()
	replicator:sendToServer("death_manager", "pair")
end

function death.revive()
	if dataManager:get("revives") - 1 < 0 and not dataManager:get("infiniteRevives") then
		marketplaceServie:PromptProductPurchase(game.Players.LocalPlayer, SHOP_CONFIG.DEV_PRODUCTS.REVIVES[1])
		return
	end

	replicator:sendToServer("death_manager", "revive")
end

--= Job Initializers =--
function death.initialize(HUD): nil
	local deathFrame = HUD.Container.Frames:WaitForChild("Death")
	death.frame = deathFrame

	local pairAgainButton = deathFrame.PairAgain

	initializeButton(deathFrame.Lobby, function()
		death.backToLobby()
	end)

	initializeButton(deathFrame.Revive, function()
		death.revive()
	end)

	initializeButton(pairAgainButton, function()
		death.pairAgain()
	end)

	replicator:listen("death_manager", function(action, arg)
		if action == "prompt" then
			GUIManager:openGui(deathFrame.Name)
		elseif action == "hide" then
			print("called")
			GUIManager:closeGui(deathFrame.Name)
		elseif action == "pairRequest" then
			pairAgainButton.TextLabel.Text = `Pair Again ({arg or 0}/2)`
		end
	end)
	GUIManager.initializeFrame(deathFrame.Name)
	GUIManager:registerGui(deathFrame, death)
end
function death.onOpened(): nil
	death.frame.PairAgain.TextLabel.Text = "Pair Again (0/2)"
	death.thread = task.spawn(death.startTimer)

	pcall(function()
		death.frame.Revive.Amt.Text = `x{dataManager:get("revives")}`
	end)
end

function death.onClosed(): nil
	if not death.thread then
		return
	end

	task.cancel(death.thread)
end

--= Return Job =--
return death
