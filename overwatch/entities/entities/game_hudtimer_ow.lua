AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch HUD Timer"
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

    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

    self.Paused = true
    self.CurTime = 0
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Int", 0, "TimeLeft")
    self:NetworkVar("String", 0, "OverwatchText")
    self:NetworkVar("String", 1, "RebelText")
end

function ENT:KeyValue(key, value)
    if key == "GMLabel" then
        self:SetOverwatchText(value)
    elseif key == "InitialTime" then
        self:SetTimeLeft(tonumber(value))
    elseif key == "RebelLabel" then
        self:SetRebelText(value)
    elseif key == "StartOn" then
        self:SetEnabled(tobool(value))
    end

    if(string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	end
end

function ENT:Think()
    if SERVER then
        if self:GetEnabled() && !self.Paused then
            local time = self:GetTimeLeft()
            if self.CurTime < math.floor(CurTime()) && time > 0 then
                self.CurTime = math.floor(CurTime())
                self.CurTimeLast = math.floor(CurTime()) - 1
                self.OnZeroTriggered = false
                local time = time - 1
                self:SetTimeLeft(time)
                if time == 1 then
                    self:TriggerOutput("On1SecondLeft", self)
                elseif time == 2 then
                    self:TriggerOutput("On2SecondsLeft", self)
                elseif time == 3 then
                    self:TriggerOutput("On3SecondsLeft", self)
                elseif time == 4 then
                    self:TriggerOutput("On4SecondsLeft", self)
                elseif time == 5 then
                    self:TriggerOutput("On5SecondsLeft", self)
                elseif time == 10 then
                    self:TriggerOutput("On10SecondsLeft", self)
                elseif time == 15 then
                    self:TriggerOutput("On15SecondsLeft", self)
                elseif time == 30 then
                    self:TriggerOutput("On30SecondsLeft", self)
                elseif time == 60 then
                    self:TriggerOutput("On60SecondsLeft", self)
                end

            elseif time == 0 && self.CurTimeLast == math.floor(CurTime()) - 1 then
                if !self.OnZeroTriggered then
                    self:TriggerOutput("OnZero", self)
                    self.OnZeroTriggered = true
                end
            end
        end
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "ShowTimer") then
        self:SetEnabled(true)
    elseif StrEqual(inputName, "HideTimer") then
        self:SetEnabled(false)
        self.Paused = true
    elseif StrEqual(inputName, "StartCountdown") then
        self.Paused = false
    elseif StrEqual(inputName, "PauseCountdown") then
        self.Paused = true
    elseif StrEqual(inputName, "AddTime") then
        local time = self:GetTimeLeft() + tonumber(data)
        self:SetTimeLeft(time)
    elseif StrEqual(inputName, "SubtractTime") then
        local time = self:GetTimeLeft() - tonumber(data)
        if time < 0 then
            time = 0
        end
        self:SetTimeLeft(time)
    elseif StrEqual(inputName, "SetTime") then
        local time = tonumber(data)
        if time < 0 then
            time = 0
        end
        self:SetTimeLeft(time)
    end
end