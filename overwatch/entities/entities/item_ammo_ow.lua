AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Ammo"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(true)
        phys:Wake()
    end
    
    self:SetTrigger(true)
    self:UseTriggerBounds(true, 24)
    self.AmmoType = 0
    self.AmmoCount = -1
end

function ENT:Think()
    if SERVER then
        if self.AmmoCount == 0 then
            self:Remove()
        end
    end
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() then
        local ammo = ent:GetAmmoCount(self.AmmoType)
        local weapon = ent:GetWeapon(GAMEMODE.AmmoLimits[self.AmmoType][2] || "nil")
        local extra = 0

        if(IsValid(weapon)) then
            if !GAMEMODE.AmmoLimits[self.AmmoType][3] then
                extra = weapon:GetMaxClip1() - weapon:Clip1()
            end

            if ammo < GAMEMODE.AmmoLimits[self.AmmoType][1] + extra then
                local difference = (GAMEMODE.AmmoLimits[self.AmmoType][1] + extra) - ammo
                ent:GiveAmmo(difference, self.AmmoType)
                self.AmmoCount = math.Clamp(self.AmmoCount - difference, 0, 9999)
            end
        end
    end
end