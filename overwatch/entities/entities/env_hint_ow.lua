AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Hint"
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
    
    self:SetTargetName(self:GetName())
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Bool", 1, "Template")
    self:NetworkVar("Bool", 2, "RequireLOS")
    self:NetworkVar("Bool", 3, "Arrow")
    self:NetworkVar("Int", 0, "Range")
    self:NetworkVar("Int", 1, "ButtonSize")
    self:NetworkVar("Int", 2, "Charges")
    self:NetworkVar("Int", 3, "Team")
    self:NetworkVar("String", 0, "Icon")
    self:NetworkVar("String", 1, "Colors")
    self:NetworkVar("String", 2, "Text")
    self:NetworkVar("String", 3, "TargetName")
end

function ENT:KeyValue(key, value)
    if key == "displayrange" then
        self:SetRange(tonumber(value))
    elseif key == "ismaster" then
        self:SetTemplate(tobool(value))
    elseif key == "tiptexture" then
        self:SetIcon(value)
    elseif key == "textcolor" then
        self:SetColors(value)
    elseif key == "requireslos" then
        self:SetRequireLOS(tobool(value))
    elseif key == "text" then
        self:SetText(value)
    elseif key == "showarrows" then
        self:SetArrow(tobool(value))
    elseif key == "team" then
        value = tonumber(value)
        if value == 0 then
            self:SetTeam(TEAM_REBELS)
        elseif value == 1 then
            self:SetTeam(TEAM_OVERWATCH)
        else
            self:SetTeam(1)
        end
    elseif key == "starton" then
        self:SetEnabled(tobool(value))
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "TurnOff") then
        self:SetEnabled(false)
    elseif StrEqual(inputName, "TurnOn") then
        self:SetEnabled(true)
    end
end