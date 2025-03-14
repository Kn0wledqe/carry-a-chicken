--[[
    vfxManager.lua
    Kn0wledqe
    Created on 03/06/2025 @ 13:33:19
    
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
local vfxManager = {}

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

--= Job Initializers =--
function vfxManager:InitAsync(): nil
	replicator:listen("vfx_maanger", function(vfx, position)
		vfx = vfx:Clone()
		vfx.Position = position
		vfx.Parent = workspace

		for _, effect in vfx:GetChildren() do
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(1)
		end

		game.Debris:AddItem(vfx, 5)
	end)
end

--= Return Job =--
return vfxManager
