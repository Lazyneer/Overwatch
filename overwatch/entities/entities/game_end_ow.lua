AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Game End"
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
    if StrEqual(inputName, "EndGame") then
        ChangeMapTimer()
    elseif StrEqual(inputName, "EndGamePlayersWin") then
        EndRound(TEAM_REBELS, true)
    elseif StrEqual(inputName, "EndGameGMWin") then
        EndRound(TEAM_OVERWATCH, true)
    elseif StrEqual(inputName, "EndGameDraw") then
        EndRound(_, true)

    elseif StrEqual(inputName, "EndRoundPlayersWin") then
        EndRound(TEAM_REBELS)
    elseif StrEqual(inputName, "EndRoundGMWin") then
        EndRound(TEAM_OVERWATCH)
    elseif StrEqual(inputName, "EndRoundDraw") then
        EndRound()
    end
end