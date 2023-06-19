AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Server Command"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if CLIENT then return end

    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "Command") then
        print(data)
        local split = string.Split(data, " ")
        local command = split[1]
        local args = table.concat(split, "", 2, #split)
        RunConsoleCommand(command, args)
    end
end