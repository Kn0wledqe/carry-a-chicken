--[[
    friendPrompt.lua
    Kn0wledqe
    Created on 03/15/2025 @ 14:00:26
    
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
local friendPrompt = { }

--= Jobs =--
local GUIManager = requireInitialized(script.Parent.Parent.Parent)

--= Classes =--
type FRIEND = {
    IsOnline : boolean,
    VisitorId : number,
    UserName: string
}

--= Modules & Config =--

--= Roblox Services =--
local players = game:GetService("Players")
local socialService = game:GetService("SocialService")
--= Object References =--
local localPlayer = players.LocalPlayer


--= Constants =--

--= Variables =--
local currentFriend = nil

--= Shorthands =--

--= Functions =--
local function selectRandomOnlineFriend() : FRIEND
    local friends : {FRIEND} = localPlayer:GetFriendsOnline()
    local onlineFriends : {FRIEND} = {}
  
    for _, friend in friends do
        if not friend.IsOnline then
            continue
        end

        table.insert(onlineFriends, friend)
    end

    if #onlineFriends == 0 then
        return nil
    end

    return onlineFriends[math.random(1, #onlineFriends)]
end

local function initializeButton(button, callback)
	GUIManager.addHover(button, nil, nil, true)
	GUIManager.addClick(button, callback)
end

--= Job API =--
function friendPrompt.open()
    friendPrompt.frame.Visible = true
end

function friendPrompt.close()
    friendPrompt.frame.Visible = false
end

--= Job Initializers =--
function friendPrompt.initialize(HUD): nil
    friendPrompt.frame =  HUD.Container.Frames:WaitForChild('Invite')

    initializeButton(friendPrompt.frame.Close, function()
        friendPrompt.close()
    end)

    initializeButton(friendPrompt.frame.Invite, function()
        pcall(function()
            local inviteOptions = Instance.new("ExperienceInviteOptions")
            inviteOptions.InviteUser = currentFriend.VisitorId
            inviteOptions.PromptMessage = `Invite {currentFriend.UserName} to join you in this adventure!`

            socialService:PromptGameInvite(localPlayer, inviteOptions)
        end)

        friendPrompt.close()
    end)


    while task.wait(60) do

        pcall(function()
            
        
            local randomFriend = selectRandomOnlineFriend()
            if not randomFriend then
                return
            end

            currentFriend = randomFriend

            friendPrompt.frame.Username.Text = currentFriend.UserName
            friendPrompt.frame.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={currentFriend.VisitorId}&w=420&h=420`

            friendPrompt.open()
        end)
    end
end

--= Return Job =--
return friendPrompt