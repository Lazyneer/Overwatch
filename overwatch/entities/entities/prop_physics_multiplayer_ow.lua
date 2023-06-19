AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Prop Dynamic"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local pos = self:GetPos()
    pos:Add(Vector(0, 0, 16))
    self:SetPos(pos)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(true)
        phys:Wake()

        local ent = ents.Create("prop_physics_multiplayer");
        ent:SetModel(self.Model);
        ent:Spawn()
        local entPhys = ent:GetPhysicsObject()
        if entPhys:IsValid() then
            self.Mass = entPhys:GetMass()
            self.Volume = math.pow(entPhys:GetVolume(), 1 / 3) --Cube root
        end
        ent:Fire("Kill");
    end
    
    self.Mass = self.Mass || 1
    self.Volume = self.Volume || 1
    self.Reset = self.Reset || 0
    self.ResetTime = 0
    self.ResetPos = pos
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Hint")
end

function ENT:KeyValue(key, value)
    if key == "model" then
        self.Model = value
    elseif key == "HintEntity" then
        self:SetHint(value)
    elseif key == "ReturnHomeTime" then
        self.Reset = tonumber(value)
    end
end

function ENT:Use(activator)
    if self.Mass <= 50 && self.Volume <= 35 then
        activator:PickupObject(self)
        self.ResetTime = -1
    end
end

function ENT:OnTakeDamage(damage)
    self:TakePhysicsDamage(damage)
    if self.ResetTime == 0 then
        self.ResetTime = CurTime() + self.Reset
    end
end

function ENT:Think()
    if CLIENT then return end

    if self.Reset > 0 then
        if self.ResetTime > 0 && self.ResetTime < CurTime() then
            self.ResetTime = 0
            self:SetPos(self.ResetPos)

            local phys = self:GetPhysicsObject()
            if phys:IsValid() then
                phys:EnableMotion(true)
                phys:Wake()
            end
        end
    end
end