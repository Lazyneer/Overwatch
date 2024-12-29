AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Player Equip"
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
    if key != "weapon" then return end
    self.Weapon = value
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "Use") then
        if activator:IsPlayer() then
            activator:Give(self.Weapon)
        end
    end
end