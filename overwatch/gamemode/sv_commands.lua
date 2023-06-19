function JoinTeamSpectators(ply)
    if ply:Team() != TEAM_SPECTATOR then
        if ply:Team() == TEAM_COMBINE then
            ply.ControlCooldown = math.Round(CurTime() + 30)
            net.Start("ControlCooldown")
            net.WriteUInt(ply.ControlCooldown, 16)
            net.Send(ply)
        end

        ply:SetTeam(TEAM_SPECTATOR)
        ply:KillSilent()
        ply.OptInOverwatch = false
        SpectatePlayer(ply)
        SetPlayerRelationships(ply, "neutral")
    end
end

function JoinTeamRebels(ply)
    if ply:Team() != TEAM_REBELS then
        if GetRoundState() < ROUND_STARTED || NewPlayerSpawn(ply) then
            ply:SetTeam(TEAM_REBELS)
            ply:KillSilent()
            ply:Spawn()
            ply:UnSpectate()
            ply.OptInOverwatch = false
            SetPlayerRelationships(ply, "default")
        else
            JoinTeamSpectators(ply)
        end
    end
end
 
function JoinTeamOverwatch(ply)
    if ply:Team() != TEAM_OVERWATCH then
        if GetRoundState() < ROUND_STARTED then
            if #player.GetAll() == 1 then
                SetOverwatch(ply)
            else
                ply:SetTeam(TEAM_REBELS)
                ply:KillSilent()
                ply:Spawn()
                ply:UnSpectate()
                ply.OptInOverwatch = true
                SetPlayerRelationships(ply, "default")
            end
        elseif NewPlayerSpawn(ply) then
            JoinTeamRebels(ply)
        else
            JoinTeamSpectators(ply)
        end
    end
end

function NewPlayerSpawn(ply)
    if ply.HasSpawnedThisRound then
        return false
    end

    local gameSettingsEnts = ents.FindByClass("game_settings_ow")
    if #gameSettingsEnts > 0 then
        local ent = gameSettingsEnts[1]
        if IsValid(ent) then
            return ent:GetNewSpawn()
        end
    end
    return false
end

function CommandNextMap(ply, cmd, args)
    if ply:IsPlayer() then
        if ply:IsAdmin() then
            SetNextMap(args[1])
        end
    else
        SetNextMap(args[1])
    end
end

concommand.Add("ow_jointeam_spectator", JoinTeamSpectators)
concommand.Add("ow_jointeam_rebels", JoinTeamRebels)
concommand.Add("ow_jointeam_overwatch", JoinTeamOverwatch)
concommand.Add("ow_setnextmap", CommandNextMap)