AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Player Count"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end
    
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
end

function ENT:KeyValue(key, value)
    if(string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "GetClientCount") then
        local countPlayers = 0
        for _, ply in ipairs(player.GetAll()) do
            countPlayers = countPlayers + 1
        end
        self:TriggerOutput("OnGetClientCount", self, countPlayers)
    elseif StrEqual(inputName, "GetAlivePlayerCount") then
        local countPlayers = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() && ply:Team() == TEAM_REBELS then
                countPlayers = countPlayers + 1
            end
        end
        self:TriggerOutput("OnGetAlivePlayerCount", self, countPlayers)
    elseif StrEqual(inputName, "GetPlayerCount") then
        local countPlayers = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply:Team() == TEAM_REBELS then
                countPlayers = countPlayers + 1
            end
        end
        self:TriggerOutput("OnGetPlayerCount", self, countPlayers)
    end
end