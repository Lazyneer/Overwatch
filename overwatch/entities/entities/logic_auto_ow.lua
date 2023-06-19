AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Logic Auto"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

outputAdded = false

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
    if StrEqual(inputName, "MultiNewRound") then
        self:TriggerOutput("OnMultiNewRound", self)
    elseif StrEqual(inputName, "MultiRoundStart") then
        self:TriggerOutput("OnMultiRoundStart", self)
    end
end