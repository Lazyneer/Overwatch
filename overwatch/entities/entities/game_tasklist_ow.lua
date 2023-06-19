AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Tasklist"
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

    self:SetCount(0)
    self:SetFlash(TASK_FLASH_NONE)
    self:SetColor(Color(255, 0, 0, 255))
    self.FlashCount = 0
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Visible")
    self:NetworkVar("Int", 0, "Count")
    self:NetworkVar("Int", 1, "MaxCount")
    self:NetworkVar("Int", 2, "Priority")
    self:NetworkVar("Int", 3, "Team")
    self:NetworkVar("Int", 4, "Flash")
    self:NetworkVar("String", 0, "Task")
end

function ENT:KeyValue(key, value)
    if key == "objcount" then
        self:SetMaxCount(math.Clamp(tonumber(value), 0, math.huge))
    elseif key == "priority" then
        self:SetPriority(tonumber(value))
    elseif key == "taskmessage" then
        self:SetTask(value)
    elseif key == "team" then
        self:SetTeam(tonumber(value))
    elseif key == "visible" then
        self:SetVisible(tobool(value))
    end

end

local function CheckCount(ent)
    if ent:GetCount() >= ent:GetMaxCount() then
        ent:SetFlash(TASK_FLASH_COMPLETE)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "Complete") then
        self:SetFlash(TASK_FLASH_COMPLETE)
    elseif StrEqual(inputName, "Abort") then
        self:SetFlash(TASK_FLASH_ABORT)
    elseif StrEqual(inputName, "Activate") then
        self:SetFlash(TASK_FLASH_ACTIVATE)
    elseif StrEqual(inputName, "Deactivate") then 
    elseif StrEqual(inputName, "Show") then
        self:SetVisible(true)
    elseif StrEqual(inputName, "Hide") then
        self:SetVisible(false)
    elseif StrEqual(inputName, "AddToCount") then
        self:SetCount(math.Clamp(self:GetCount() + tonumber(data), 0, self:GetMaxCount()))
        CheckCount(self)
    elseif StrEqual(inputName, "SetCount") then
        self:SetCount(math.Clamp(tonumber(data), 0, self:GetMaxCount()))
        CheckCount(self)
    elseif StrEqual(inputName, "SetMaxCount") then
        self:SetMaxCount(math.Clamp(tonumber(data), 0, math.huge))
        CheckCount(self)
    end
end

function ENT:Think()
    if CLIENT then return end

    local flash = self:GetFlash()
    local color = self:GetColor()
    if flash == TASK_FLASH_ACTIVATE then
        if !self.Activated then
            self.Activated = true
            color.r = 50
            color.g = 50
            color.b = 50
        end

        if color.r >= 100 then
            color.r = math.Clamp(color.r + 1, 0, 255)
            color.g = math.Clamp(color.g - 1, 0, 100)
            color.b = math.Clamp(color.b - 1, 0, 100)
        else
            color.r = math.Clamp(color.r + 1, 0, 255)
            color.g = math.Clamp(color.g + 1, 0, 100)
            color.b = math.Clamp(color.b + 1, 0, 100)
        end

        if color.r == 255 then
            self:SetFlash(TASK_FLASH_NONE)
        end
    elseif flash == TASK_FLASH_ABORT then
        if self.FlashCount < 5 then
            if self.FlashCount % 2 == 1 then
                color.r = math.Clamp(color.r + 4, 0, 255)
                color.b = math.Clamp(color.b - 4, 0, 255)
            else
                color.r = math.Clamp(color.r - 4, 0, 255)
                color.b = math.Clamp(color.b + 4, 0, 255)
            end

            if color.r == 0 || color.b == 0 then
                self.FlashCount = self.FlashCount + 1
            end
        elseif color.a == 0 then
            if IsValid(self) then
                self:Remove()
			end
        else
            color.a = math.Clamp(color.a - 4, 0, 255)
        end
    elseif flash == TASK_FLASH_COMPLETE then
        if self.FlashCount < 5 then
            if self.FlashCount % 2 == 1 then
                color.r = math.Clamp(color.r + 4, 0, 255)
                color.g = math.Clamp(color.g - 4, 0, 255)
            else
                color.r = math.Clamp(color.r - 4, 0, 255)
                color.g = math.Clamp(color.g + 4, 0, 255)
            end

            if color.r == 0 || color.g == 0 then
                self.FlashCount = self.FlashCount + 1
            end
        elseif color.a == 0 then
            if IsValid(self) then
                self:Remove()
			end
        else
            color.a = math.Clamp(color.a - 4, 0, 255)
        end
    end

    self:SetColor(color)
    self:NextThink(CurTime())
	return true
end