AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Rebel Revive"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self.EntId = self:EntIndex()
    if CLIENT then return end

    self:PhysicsInit(SOLID_OBB)
	self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    --Making sure it stays in place
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(false)
		phys:Sleep()
    end

    self:SetColor(Color(255, 255, 255, 200)) 
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetRenderFX(kRenderFxPulseSlow)
 
    self:SetProgress(0)
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Progress")
    self:NetworkVar("Entity", 0, "Player")
    self:NetworkVar("Entity", 1, "Activator")
end

function ENT:Think()
    if CLIENT then return end

    local ply = self:GetPlayer()
    if !IsValid(ply) then
        self:Remove()
    else
        local activator
        for _, ent in ipairs(player.GetAll()) do
            if ent:Team() == TEAM_REBELS && ent:Alive() then
                if self:GetActivator() == ent || !IsValid(self:GetActivator()) then
                    if ent:KeyDown(IN_USE) then
                        local use = ent:GetUseEntity()
                        if IsValid(use) then
                            if use == self then
                                activator = ent
                                break
                            elseif use:GetClass() == "prop_rebel_revive" then
                                if ent == use:GetActivator() then
                                    goto cont
                                end
                            end
                        end
                    end
                end
                
                net.Start("SetReviveEntity")
                net.WriteEntity(ent)
                net.Send(ent)
            end

            ::cont::
        end

        if IsValid(activator) then
            self:SetActivator(activator)
            net.Start("SetReviveEntity")
            net.WriteEntity(self)
            net.Send(activator)

            self:SetProgress(math.Clamp(self:GetProgress() + 0.0015, 0, 1))
            if !ply:Alive() then
                ply.ObsMode = OBS_MODE_IN_EYE
                ply:Spectate(ply.ObsMode)
                ply:SpectateEntity(activator)
                ply.BeingRevived = true;
                ply:SetNWBool("Reviving", true)
    
                net.Start("SetReviveEntity")
                net.WriteEntity(self)
                net.Send(ply)
                if self:GetProgress() == 1 then
                    ply:Spectate(OBS_MODE_NONE)
                    ply:UnSpectate()
                    ply:SetPos(activator:GetPos())
                    ply:KillSilent()
                    ply:Spawn()
                    ply:SetPos(activator:GetPos())
                    self:Remove()
                end
            end
        else
            self:SetActivator(nil)
            self:SetProgress(math.Clamp(self:GetProgress() - 0.003, 0, 1))
            ply.BeingRevived = false;
            ply:SetNWBool("Reviving", false)
        end
        ply:SetNWFloat("ReviveProgress", self:GetProgress())
    end

    self:NextThink(CurTime())
    return true
end