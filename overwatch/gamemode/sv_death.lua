hook.Add("PlayerDeath", "PlayerDeath", function(ply, inflictor, attacker)
    SetUnitCap()
    local gameRespawnEnts = ents.FindByClass("game_respawn_ow")
    local gameSettingsEnts = ents.FindByClass("game_settings_ow")
    local deadRespawn = false
    if #gameSettingsEnts > 0 then
        local ent = gameSettingsEnts[1]
        if IsValid(ent) && #gameRespawnEnts == 0 then
            deadRespawn = ent:GetDeadRespawn()
        end
    end

    if ply:Team() == TEAM_REBELS then
        timer.Create("TriggerActivityDeath", 0, 1, function()
            for _, ent in pairs(ents.GetAll()) do
                if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                    ent:TriggerOutput("OnPlayerDeath", ent)
                end
            end
        end)

        local model = ply:GetModel()
        model = string.Replace(model, "/group03m/", "/group03/")
        ply:SetModel(model)

        if ply:HasWeapon("weapon_riotshield_ow") then
            local pos = ply:GetPos()
            pos:Add(Vector(0, 0, 48))
    
            local wep = ply:GetWeapon("weapon_riotshield_ow")
            local weapon = ents.Create("weapon_riotshield_ow")
            weapon:SetPos(pos)
            weapon:SetAngles(ply:GetAngles())
            weapon:Spawn()
            weapon:SetName(wep.TargetName)
        elseif ply:HasWeapon("weapon_medpack_ow") then
            local pos = ply:GetPos()
            pos:Add(Vector(0, 0, 16))

            local wep = ply:GetWeapon("weapon_medpack_ow")
            local weapon = ents.Create("weapon_medpack_ow")
            weapon:SetPos(pos)
            weapon:SetAngles(ply:GetAngles())
            weapon:Spawn()
            weapon:SetName(wep.TargetName)
        end
    end

    if ply:Team() == TEAM_REBELS && GetRoundState() == ROUND_STARTED && #gameRespawnEnts == 0 && !deadRespawn then
        if IsValid(ply.DeathMarker) then
            ply.DeathMarker:Remove()
        end

        local prop = ents.Create("prop_rebel_revive")
        prop:SetModel(ply:GetModel())
        prop:SetPos(ply:GetPos())
        prop:SetAngles(ply:GetAngles())
        prop:Spawn()
        prop:SetPlayer(ply)
        
        local pos = ply:GetPos()
        ply:SetNWEntity("Revive", prop)
        ply.DeathMarker = prop
        ply.BeingRevived = false
        ply.Ammo = ply:GetAmmo()
        local weapons = ply:GetWeapons()
        for k, v in pairs(weapons) do
            weapons[k] = v:GetClass()
        end
        ply.Weapons = weapons
    elseif ply:Team() == TEAM_REBELS && GetRoundState() == ROUND_STARTED then
        ply.Ammo = ply:GetAmmo()
        local weapons = ply:GetWeapons()
        for k, v in pairs(weapons) do
            weapons[k] = v:GetClass()
        end
        ply.Weapons = weapons

        if deadRespawn then
            ply.RespawnTime = math.Round(CurTime() + 5)
            net.Start("RespawnTime")
            net.WriteUInt(ply.RespawnTime, 16)
            net.Send(ply)
        end
    elseif ply:Team() == TEAM_COMBINE then
        timer.Create("BackToSpectator", 0.1, 1, function()
            JoinTeamSpectators(ply)
        end)

        ply.ControlCooldown =  math.Round(CurTime() + 30)
        net.Start("ControlCooldown")
        net.WriteUInt(ply.ControlCooldown, 16)
        net.Send(ply)
    end
end)

function GM:PlayerDeathThink(ply)
    local gameRespawnEnts = ents.FindByClass("game_respawn_ow")
    local gameSettingsEnts = ents.FindByClass("game_settings_ow")
    if #gameSettingsEnts > 0 then
        local ent = gameSettingsEnts[1]
        if IsValid(ent) && #gameRespawnEnts == 0 then
            deadRespawn = ent:GetDeadRespawn()
        end
    end
    
    if ply:Team() == TEAM_REBELS && ((GetRoundState() == ROUND_STARTED || GetRoundState() == ROUND_ENDED) && !deadRespawn) then return false end
    if ply:Team() == TEAM_SPECTATOR then return false end
    if ply:Team() == TEAM_COMBINE then return true end

    if ply:Team() == TEAM_OVERWATCH then
       ply:Spawn()
       ply:Spectate(OBS_MODE_DEATHCAM)
       ply:SpectateEntity(ents.GetMapCreatedEntity(overwatchCamera))
       return true
    end

    if ply:Team() == TEAM_REBELS && GetRoundState() == ROUND_STARTED then
        if ply.RespawnTime <= math.Round(CurTime()) then
            ply:Spawn()
            return true
        end
    end

    if (ply:IsBot() || ply:KeyPressed(IN_ATTACK) || ply:KeyPressed(IN_ATTACK2) || ply:KeyPressed(IN_JUMP)) && (!deadRespawn || GAMEMODE.SoloSetup) then
		ply:Spawn()
        return true
	end

    return false
end

function GM:CanPlayerSuicide(ply)
    return false
end