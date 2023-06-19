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
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(self.Solid)

    --Making sure it stays in place
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(false)
        phys:Sleep()
    end

    self.Color[1] = self.Color[1] || 255
    self.Color[2] = self.Color[2] || 255
    self.Color[3] = self.Color[3] || 255
    self.Alpha = self.Alpha || 255

    self.RenderMode = self.RenderMode || 0
    self.RenderFX = self.RenderFX || 0

    self:SetColor(Color(self.Color[1], self.Color[2], self.Color[3], self.Alpha)) 
    self:SetRenderMode(self.RenderMode)
    self:SetRenderFX(self.RenderFX)
end

function ENT:KeyValue(key, value)
    if key == "model" then
        self.Model = value
    elseif key == "renderamt" then
        self.Alpha = tonumber(value)
    elseif key == "rendercolor" then
        self.Color = string.Explode(" ", value)
    elseif key == "renderfx" then
        self.RenderFX = tonumber(value)
    elseif key == "rendermode" then
        self.RenderMode = tonumber(value)
    elseif key == "solid" then
        self.Solid = tonumber(value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "Enable") then
        self:SetSolid(self.Solid)
        self:SetRenderMode(self.RenderMode)
    elseif StrEqual(inputName, "Disable") then
        self:SetSolid(SOLID_NONE)
        self:SetRenderMode(RENDERMODE_NONE)
    end
end