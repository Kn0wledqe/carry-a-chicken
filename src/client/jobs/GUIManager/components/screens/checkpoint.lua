--[[
    checkpoint.lua
    Kn0wledqe
    Created on 03/15/2025 @ 18:54:50
    
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
local checkpoint = {}

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)
local replicator = requireInitialized("jobs/net/replicator")

--= Classes =--

--= Modules & Config =--
local helperFunctions = requireInitialized("utils/helperFunctions")
local CHECK_POINTS = requireInitialized("$config/checkpoints")

--= Roblox Services =--

--= Object References =--

--= Constants =--

--= Variables =--
local worldIndex = 1
local selectedIndex = 1
local checkpointFrames = {}

--= Shorthands =--

--= Functions =--
local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end

local function updateCheckpoints()
	for index, frame in pairs(checkpointFrames) do
		frame.UIStroke.Enabled = false
		frame:FindFirstChild("Selected").Visible = false

		if index == selectedIndex then
			frame:FindFirstChild("Selected").Visible = true
			frame.UIStroke.Enabled = true
		end
	end
end

--= Job API =--
function checkpoint.setInfo(pair: Player, index: number)
	worldIndex = index

	checkpoint.frame:FindFirstChild("Name").Text = pair.Name
	checkpoint.frame.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={pair.UserId}&w=420&h=420`
end

--= Job Initializers =--
function checkpoint.initialize(HUD): nil
	local checkPointFrame = HUD.Container.Frames:WaitForChild("Checkpoint")

	checkpoint.frame = checkPointFrame
	checkpoint.parent = checkPointFrame.Checkpoint
	checkpoint.template = checkpoint.parent.Template
	checkpoint.template.Parent = nil

	GUIManager.initializeFrame(checkPointFrame.Name)
	GUIManager:registerGui(checkPointFrame, checkpoint)
end

function checkpoint.onOpened(): nil

	selectedIndex = 1
	for index, info in CHECK_POINTS do
		print(worldIndex, index)
		if index > worldIndex then
			break
		end

		local newCheckpoint = checkpoint.template:Clone()
		newCheckpoint.ImageLabel.Image = info.image
		newCheckpoint.Title.Text = info.name
		newCheckpoint.UIStroke.Enabled = false

		initializeButton(newCheckpoint, function()
			if selectedIndex == index then
				return
			end

			selectedIndex = index
			replicator:sendToServer("checkpoint_manager", index)

			updateCheckpoints()
		end)
		newCheckpoint.Parent = checkpoint.parent

		table.insert(checkpointFrames, newCheckpoint)
	end

	updateCheckpoints()
end

function checkpoint.onClosed(): nil
	checkpointFrames = {}
	helperFunctions.cleanChildren(checkpoint.parent)
end

--= Return Job =--
return checkpoint
