AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Teleport"
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
    if key == "target" then
        self.Target = value
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "Teleport") then
        for _, ent in ipairs(ents.FindByName(self.Target)) do
            ent:SetPos(self:GetPos())
            ent:SetAngles(self:GetAngles())

            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then
                phys:EnableMotion(true)
                phys:Wake()
            end
        end
    end
end