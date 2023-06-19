AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Button"
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

    if self:GetCharges() == 0 || self.StartDisabled then
        self:SetEnabled(false)
    else
        self:SetEnabled(true)
        self:SetCooldownEnd(0)
    end

    self.InitialCooldown = self.InitialCooldown || 0

    self:SetColors(self.ColorCooldown .. "-" .. self.ColorDisabled .. "-" .. self.ColorEnabled .. "-" .. self.ColorHover)
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Int", 0, "CooldownEnd")
    self:NetworkVar("Int", 1, "ButtonSize")
    self:NetworkVar("Int", 2, "Charges")
    self:NetworkVar("String", 0, "Icon")
    self:NetworkVar("String", 1, "ToolTip")
    self:NetworkVar("String", 2, "Title")
    self:NetworkVar("String", 3, "Colors")

    if SERVER then
		self:NetworkVarNotify("Charges", self.OnVarChanged)
	end
end

function ENT:OnVarChanged(name, old, new)
    if old > 0 && new == 0 then
        self:TriggerOutput("OnChargesExpired", self)
    end
end

function ENT:KeyValue(key, value)
    if key == "butsizemax" then
        self:SetButtonSize(tonumber(value))
    elseif key == "charges" then
        self:SetCharges(tonumber(value))
    elseif key == "clrcooldown" then
        self.ColorCooldown = value
    elseif key == "clrdisable" then
        self.ColorDisabled = value
    elseif key == "clrenable" then
        self.ColorEnabled = value
    elseif key == "clrmouseover" then
        self.ColorHover = value
    elseif key == "cooldown" then
        self.Cooldown = tonumber(value)
    elseif key == "initialcooldown" then
        self.InitialCooldown = tonumber(value)
    elseif key == "matenable" then
        self:SetIcon(value)
    elseif key == "StartDisabled" then
        self.StartDisabled = tobool(value)
    elseif key == "tooltip" then
        self:SetToolTip(value)
    elseif key == "tooltiptitle" then
        self:SetTitle(value)
    end

    if(string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	end
end

function ENT:Think()
    if SERVER then
        if self:GetCooldownEnd() <= CurTime() then      
            if self.PlaySound then
                self.PlaySound = false
                self:TriggerOutput("OnCooldownFinished", self)

                if !GAMEMODE.PlayingSound then
                    GAMEMODE.PlayingSound = true;
                    timer.Create("PlayingSound", 1, 1, function()
                        GAMEMODE.PlayingSound = false;
                    end)
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:Team() == TEAM_OVERWATCH then
                            net.Start("PlayOverwatchSound")
                            net.WriteString("buttons/blip1.wav")
                            net.Send(ply)
                        end
                    end
                end
            end
        else
            self.PlaySound = true
        end
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    local alivePlayers = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_REBELS && ply:Alive() then
            alivePlayers = alivePlayers + 1
        end
    end

    local cooldownScale = math.Clamp(-0.05 * alivePlayers + 1.25, 0.5, 1)

    if StrEqual(inputName, "SetTooltipTitle") then
        self:SetTitle(data)
    elseif StrEqual(inputName, "SetTooltip") then
        self:SetToolTip(data)

    elseif StrEqual(inputName, "SetCooldown") then
        self.Cooldown = tonumber(data)
    elseif StrEqual(inputName, "ForceCooldown") then
        self:SetCooldownEnd(CurTime() + (data * cooldownScale * GAMEMODE.ConVars.cooldown:GetFloat()))
    elseif StrEqual(inputName, "ForceCooldownAdd") then
        if self:GetCooldownEnd() > CurTime() then
            self:SetCooldownEnd(self:GetCooldownEnd() + (data * cooldownScale * GAMEMODE.ConVars.cooldown:GetFloat()))
        end
    elseif StrEqual(inputName, "ForceCooldownSubtract") then
        if self:GetCooldownEnd() > CurTime() then
            self:SetCooldownEnd(self:GetCooldownEnd() - (data * cooldownScale * GAMEMODE.ConVars.cooldown:GetFloat()))
        end

    elseif StrEqual(inputName, "SetCharges") then
        self:SetCharges(data)
        if self:GetCharges() != 0 then
            self:SetEnabled(true)

            if !GAMEMODE.PlayingSound then
                GAMEMODE.PlayingSound = true;
                timer.Create("PlayingSound", 1, 1, function()
                    GAMEMODE.PlayingSound = false;
                end)
                for _, ply in ipairs(player.GetAll()) do
                    if ply:Team() == TEAM_OVERWATCH then
                        net.Start("PlayOverwatchSound")
                        net.WriteString("buttons/blip1.wav")
                        net.Send(ply)
                    end
                end
            end  
        else
            self:SetEnabled(false)  
        end
    elseif StrEqual(inputName, "ChargesAdd") then
        self:SetCharges(self:GetCharges() + data)
        if self:GetCharges() != 0 then
            self:SetEnabled(true)
        else
            self:SetEnabled(false)
        end
    elseif StrEqual(inputName, "ChargesSubtract") then
        self:SetCharges(self:GetCharges() - data)
        if self:GetCharges() != 0 then
            self:SetEnabled(true)
        else
            self:SetEnabled(false)
        end

    elseif StrEqual(inputName, "Disable") then
        self:SetEnabled(false)
    elseif StrEqual(inputName, "Enable") then
        if self:GetCharges() != 0 then
            self:SetEnabled(true)
        else
            self:SetEnabled(false)
        end
    end
end