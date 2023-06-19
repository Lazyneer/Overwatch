AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Enemyfinder"
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
        value = string.Replace(value, "SetTargetEntity", "SetTargetEntityName")
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "GetVisibleRebel") then
        local playerFound = false
        local playerTargetName
        for _, ply in ipairs(player.GetAll()) do
            if (ply:Alive() && ply:Team() == TEAM_REBELS) then
                if self:Visible(ply) then
                    playerFound = true
                    playerTargetName = ply:GetNWString("targetname")
                end
            end
        end
        if playerFound then
            self:TriggerOutput("OnGetVisibleRebel", self, playerTargetName)
        end
    end
end