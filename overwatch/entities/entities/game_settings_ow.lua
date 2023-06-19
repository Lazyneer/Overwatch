AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Settings"
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
    self:NetworkVar("Bool", 0, "NewSpawn")
    self:NetworkVar("Bool", 1, "DeadRespawn")
    self:NetworkVar("Bool", 2, "DeadDefeat")
end

function ENT:KeyValue(key, value)
    if key == "allowspawning" then
        self:SetNewSpawn(tobool(value))
    elseif key == "allowrespawning" then
        self:SetDeadRespawn(tobool(value))
    elseif key == "defeat_dead" then
        self:SetDeadDefeat(tobool(value))
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "EnableNewPlayerSpawning") then
        self:SetNewSpawn(true)
    elseif StrEqual(inputName, "DisableNewPlayerSpawning") then
        self:SetNewSpawn(false)
    elseif StrEqual(inputName, "ToggleNewPlayerSpawning") then
        self:SetNewSpawn(self:GetNewSpawn())
    elseif StrEqual(inputName, "EnableDeadPlayerSpawning") then
        self:SetDeadRespawn(true)
    elseif StrEqual(inputName, "DisableDeadPlayerSpawning") then
        self:SetDeadRespawn(false)
    elseif StrEqual(inputName, "ToggleDeadPlayerSpawning") then
        self:SetDeadRespawn(self:GetDeadRespawn())
    elseif StrEqual(inputName, "EnableDefeatOnPlayersDead") then
        self:SetDeadDefeat(true)
    elseif StrEqual(inputName, "DisableDefeatOnPlayersDead") then
        self:SetDeadDefeat(false)
    end
end