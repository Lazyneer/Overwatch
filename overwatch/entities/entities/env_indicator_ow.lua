AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Indicator"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end

    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetModelScale(0.8)
    self:SetNoDraw(true)

    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

    self:SetProgress(0)
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Bool", 1, "ShowProgress")
    self:NetworkVar("Int", 0, "Team")
    self:NetworkVar("Float", 0, "Progress")
    self:NetworkVar("String", 0, "OverwatchText")
    self:NetworkVar("String", 1, "OverwatchIcon")
    self:NetworkVar("String", 2, "RebelText")
    self:NetworkVar("String", 3, "RebelIcon")
end

function ENT:KeyValue(key, value)
    if key == "gmlabel" then
        self:SetOverwatchText(value)
    elseif key == "gmtexture" then
        self:SetOverwatchIcon(value)
    elseif key == "rebellabel" then
        self:SetRebelText(value)
    elseif key == "rebeltexture" then
        self:SetRebelIcon(value)
    elseif key == "showprogress" then
        self:SetShowProgress(tobool(value))
    elseif key == "startactive" then
        self:SetEnabled(tobool(value))
    elseif key == "team" then
        self:SetTeam(tonumber(value))
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "TurnOn") then
        self:SetEnabled(true)
    elseif StrEqual(inputName, "TurnOff") then
        self:SetEnabled(false)
    elseif StrEqual(inputName, "ShowProgress") then
        self:SetShowProgress(tobool(value))
    elseif StrEqual(inputName, "SetProgressRatio") then
        self:SetProgress(tonumber(data))
    end
end