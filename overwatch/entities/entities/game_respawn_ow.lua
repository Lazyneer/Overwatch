AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Respawn"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end
    
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)

    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Message")
end

function ENT:KeyValue(key, value)
    if key == "activemessage" then
        self:SetMessage(tonumber(value))
    elseif key == "message01" then
        self:SetNWString(key, value)
    elseif key == "message02" then
        self:SetNWString(key, value)
    elseif key == "message03" then
        self:SetNWString(key, value)
    elseif key == "message04" then
        self:SetNWString(key, value)
    elseif key == "message05" then
        self:SetNWString(key, value)
    elseif key == "message06" then
        self:SetNWString(key, value)
    elseif key == "message07" then
        self:SetNWString(key, value)
    elseif key == "message08" then
        self:SetNWString(key, value)
    end

    if(string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "ForceRespawn") then
        self:TriggerOutput("OnForceRespawn", self)
        for _, ply in ipairs(player.GetAll()) do
            if !ply:Alive() && ply:Team() == TEAM_REBELS then
                ply:UnSpectate()
                ply:Spawn()
            end
        end
    elseif StrEqual(inputName, "SetActiveMessage") then
        self:SetMessage(tonumber(data))
    end
end