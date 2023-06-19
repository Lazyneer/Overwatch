AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Rebel Player"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end

    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)

    if self.Enabled == nil then
        self.Enabled = true
    end
end

function ENT:KeyValue(key, value)
    if key == "startdisabled" then
        self.Enabled = !tobool(value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "DisableSpawn") then
        self.Enabled = false
    elseif StrEqual(inputName, "EnableSpawn") then
        self.Enabled = true
    elseif StrEqual(inputName, "ToggleSpawn") then
        self.Enabled = !self.Enabled
    end
end