function GM:PlayerConnect(name, ip)
    timer.Create("TriggerActivityTeam", 0, 1, function()
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                ent:TriggerOutput("OnConnect", ent)
            end
        end
    end)
end

function GM:PlayerInitialSpawn(ply)
    ply:ConCommand("ow_jointeam")
    ply:SetName("player_" .. ply:UserID())
    ply:SetNWString("targetname", "player_" .. ply:UserID())
    ply:SetCustomCollisionCheck(true)
    ply:AllowFlashlight(true)
    ply.Relationships = "default"
    ply.ControlCooldown = math.Round(CurTime() + 30)
    ply.HasBeenOverwatch = 0

    net.Start("ControlCooldown")
    net.WriteUInt(ply.ControlCooldown, 16)
    net.Send(ply)

    if ply:IsBot() then
        ply:SetTeam(TEAM_REBELS)
        ply:UnSpectate()
        ply:Spawn()
        ply.Model = playerModels[math.random(#playerModels)]
        ply.Gender = GENDER_MALE
        if string.find(ply.Model, "female") then
            ply.Gender = GENDER_FEMALE
        end
        ply:SetModel(ply.Model)
    end

    net.Start("BroadcastRoundState")
    net.WriteInt(GetRoundState(), 4)
    net.Send(ply)

    net.Start("NetworkNodes")
    net.WriteUInt(#GAMEMODE.Nodes[NODE_TYPE_GROUND], 12)
    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_GROUND] do
        net.WriteVector(GAMEMODE.Nodes[NODE_TYPE_GROUND][i])
    end
    net.WriteUInt(#GAMEMODE.Nodes[NODE_TYPE_AIR], 12)
    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_AIR] do
        net.WriteVector(GAMEMODE.Nodes[NODE_TYPE_AIR][i])
    end
    net.Send(ply)

    net.Start("BroadcastConVarTimeLimit")
    net.WriteUInt(GAMEMODE.ConVars.timelimit.start, 16)
    net.Send(ply)

    net.Start("UpdateConvar")
    net.WriteString("maxrounds")
    net.WriteUInt(GAMEMODE.ConVars.maxrounds.convar:GetInt(), 8)
    net.Send(ply)

    net.Start("UpdateConvar")
    net.WriteString("timelimit")
    net.WriteUInt(GAMEMODE.ConVars.timelimit.convar:GetInt(), 16)
    net.Send(ply)

    net.Start("SetCameras")
    net.WriteVector(GAMEMODE.Cameras.overwatch.pos || Vector())
    net.WriteAngle(GAMEMODE.Cameras.overwatch.ang || Angle())
    net.WriteAngle(GAMEMODE.Cameras.spectator.ang || Angle())
    net.Send(ply)
end

function GM:PlayerChangedTeam(ply, oldTeam, newTeam)
    ply.Model = nil
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

    timer.Create("TriggerActivityTeam", 0, 1, function()
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                if newTeam == TEAM_REBELS then
                    ent:TriggerOutput("OnTeamJoinPlayer", ent)
                elseif newTeam == TEAM_OVERWATCH then
                    ent:TriggerOutput("OnTeamJoinGM", ply)
                end

                if oldTeam == TEAM_REBELS then
                    ent:TriggerOutput("OnTeamLeavePlayer", ply)
                elseif oldTeam == TEAM_OVERWATCH then
                    ent:TriggerOutput("OnTeamLeaveGM", ply)
                end
            end
        end
    end)
end

function GM:PlayerSpawn(ply)
    ply:UnSpectate()
    if ply:Team() == TEAM_CONNECTING || ply:Team() == TEAM_SPECTATOR then
        ply:KillSilent()
        ply:SetTeam(TEAM_CONNECTING)
        ply.ObsMode = OBS_MODE_CHASE
        ply:Spectate(OBS_MODE_IN_EYE)
        ply:SpectateEntity(ents.GetMapCreatedEntity(infoStart))
        ply:SetNoTarget(true)
    elseif ply:Team() == TEAM_REBELS then
        SetLoadout(ply)
        ply:SetJumpPower(200)
        ply.Model = ply.Model || playerModels[math.random(#playerModels)]
        ply.Gender = GENDER_MALE
        if string.find(ply.Model, "female") then
            ply.Gender = GENDER_FEMALE
        end
        ply:SetModel(ply.Model)
        ply:SetupHands(ply)
        ply:SetCrouchedWalkSpeed(0.45)
        GAMEMODE:SetPlayerSpeed(ply, 200, 200)

        timer.Create("TriggerActivitySpawn", 0, 1, function()
            for _, ent in pairs(ents.GetAll()) do
                if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                    ent:TriggerOutput("OnPlayerSpawn", ent)
                end
            end
        end)
    elseif ply:Team() == TEAM_COMBINE then
        ply:SetupHands(ply)
        ply:SetJumpPower(200)
    end

    SetUnitCap()
    ply.VoiceLineCooldown = 0
    ply.VoiceMenuCooldown = 0
    if IsValid(ply.DeathMarker) then
        ply.DeathMarker:Remove()
    end
end

function GM:PlayerSelectSpawn(ply)
    local spawnPoints = {}
    for _, ent in pairs(ents.FindByClass("info_player_rebel_ow")) do
        ent.Used = ent.Used || 0
        if ent.Enabled then
            table.insert(spawnPoints, ent)
        end
    end

    if #spawnPoints == 0 then
        return nil
    end

    table.sort(spawnPoints, function(a, b) return a.Used < b.Used end)
    local spawn = spawnPoints[1]
    spawn.Used = spawn.Used + 1

    return spawn
end

function GM:PlayerSetHandsModel(ply, ent)
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

function GM:SetupPlayerVisibility(ply, viewEntity)
    if ply:Team() == TEAM_OVERWATCH then
        for _, ent in pairs(ents.GetAll()) do
            if IsValid(ent) then
                AddOriginToPVS(ent:GetPos()) 
            end
        end
    elseif ply:Team() == TEAM_REBELS || ply:Team() == TEAM_COMBINE then
        for _, ent in ipairs(player.GetAll()) do
            if IsValid(ent) then
                AddOriginToPVS(ent:GetPos())
            end
        end
    end
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
    if teamOnly then
        if !IsValid(listener) || !IsValid(speaker) then return false end
        if listener:Team() == TEAM_COMBINE && speaker:Team() == TEAM_OVERWATCH then return true end
        if listener:Team() == TEAM_OVERWATCH && speaker:Team() == TEAM_COMBINE then return true end
        if listener:Team() != speaker:Team() then return false end
    end
    return true
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    return true, false
end

function GM:PlayerSay(sender, text, teamChat)
    if sender:Team() == TEAM_SPECTATOR then
        net.Start("SpectatorMessage")
        net.WriteEntity(sender)
        net.WriteString(text)
        net.WriteBool(teamChat)
        net.Broadcast()

        local command = "say"
        if teamChat then command = "say_team" end
        local author = string.format("%s<%u><%s><Team>", sender:Name(), sender:UserID(), sender:SteamID())
        local log = string.format("%q %s %q\n", author, command, text)
        ServerLog(log)
        
        return ""
    end
    return text
end

function GM:PlayerCanPickupWeapon(ply, wep)
    if ply:Team() == TEAM_COMBINE then
        if wep:GetClass() == ply.AllowedWeapon then return true end
    end

    if ply:Team() != TEAM_REBELS then return false end
    if GetRoundState() < ROUND_SETUP && !GAMEMODE.SoloSetup then return false end
    if wep:GetClass() == "weapon_stunstick" then return false end

    local ammo = wep:GetPrimaryAmmoType()
    if ammo > 0 && ply:HasWeapon(wep:GetClass()) then
        if ply:GetAmmoCount(ammo) >= GAMEMODE.AmmoLimits[ammo][1] then return false end
    end

    if wep:GetClass() == "weapon_frag" then
        if(wep.noPickup) then
            return false
        end

        local fragData = {}
        fragData["respawnTime"] = CurTime() + 20
        fragData["origin"] = wep.origin
        fragData["targetname"] = wep:GetName()
        fragSpawns[wep:GetCreationID()] = fragData
    elseif wep:GetClass() == "weapon_medpack_ow" || wep:GetClass() == "weapon_riotshield_ow" then
        if IsValid(ply:GetWeapon("weapon_riotshield_ow")) || IsValid(ply:GetWeapon("weapon_medpack_ow")) then
            return false
        end
    end

    return true
end

function GM:AllowPlayerPickup(ply, ent)
    if ply:Team() != TEAM_REBELS then return false end

    if ent:GetClass() == "npc_turret_floor" && IsValid(ent) then
        --Friendly turrets only
        return ent:HasSpawnFlags(512)
    end
    return true
end

function GM:OnPlayerPhysicsDrop(ply, ent, thrown)
    if ent:GetClass() == "prop_physics_multiplayer_ow" then
        ent.ResetTime = CurTime() + ent.Reset
    end
end

function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:GetClass() == "npc_turret_floor" && IsValid(attacker) then
        --Friendly turrets only
        return !(attacker:HasSpawnFlags(512) && ply:Team() == TEAM_REBELS)
    end

    if ply:Team() == TEAM_OVERWATCH then return true end
    if !attacker:IsPlayer() then return true end
    if attacker == ply then return true end
    return (ply:Team() != attacker:Team() || GAMEMODE.FriendlyFire)
end

function GM:GetFallDamage(ply, flFallSpeed)
	return (flFallSpeed - 526.5) * (100 / 396)
end

function GM:EntityTakeDamage(target, dmg)
    local baseDamage = dmg:GetDamage()

    local class
    local weapon
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) && (attacker:IsPlayer() || attacker:IsNPC()) then
        weapon = attacker:GetActiveWeapon()
        if IsValid(weapon) then
            class = weapon:GetClass()
        end
    end

    if attacker:IsPlayer() then
        if attacker:Team() == TEAM_REBELS then
            local scale = GAMEMODE.WeaponDamageScale.player[class] || 1
            dmg:ScaleDamage(scale)
        else
            local scale = GAMEMODE.WeaponDamageScale.combine[class] || 1
            dmg:ScaleDamage(scale)
        end
    elseif attacker:IsNPC() then
        local scale = GAMEMODE.WeaponDamageScale.npc[class] || 1
        dmg:ScaleDamage(scale)
    end

    local totalPlayers = 0
    local alivePlayers = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_REBELS then
            totalPlayers = totalPlayers + 1
            if ply:Alive() then
                alivePlayers = alivePlayers + 1
            end
        end
    end

    if attacker:GetClass() == "prop_vehicle_jeep" && target:IsPlayer() then
        return true
    elseif target:IsNPC() && attacker:IsPlayer() then
        dmg:ScaleDamage(GAMEMODE.ConVars.damage.players:GetFloat())
        if target:Disposition(attacker) == D_LI then
            return true
        else
            --[[if alivePlayers < totalPlayers && alivePlayers < 5 then
                dmg:ScaleDamage(-0.125 * (alivePlayers - 1) + 1.5)
            elseif totalPlayers < 5 then
                dmg:ScaleDamage(-0.0625 * (totalPlayers - 1) + 1.25)
            else]]
            
            if alivePlayers > 5 && !GAMEMODE.OverwatchNPCBlacklist[attacker:GetClass()] then
                dmg:ScaleDamage(math.max(-0.05 * alivePlayers + 1.25, 0.5))
            end

            if GetUnitCount() >= GetUnitCap() + 4 then
                local overUnitCap = math.floor(GetUnitCount() - GetUnitCap(), 4)
                dmg:ScaleDamage(1 + overUnitCap / 10)
            end
        end
    elseif target:IsPlayer() && attacker:IsNPC() then
        dmg:ScaleDamage(GAMEMODE.ConVars.damage.npcs:GetFloat())
        if alivePlayers > 5 && !GAMEMODE.OverwatchNPCBlacklist[attacker:GetClass()] then
            dmg:ScaleDamage(0.025 * alivePlayers + 0.875)
        end

        if IsValid(target:GetActiveWeapon()) then
            if target:GetActiveWeapon():GetClass() == "weapon_riotshield_ow" then
                if dmg:GetAttacker():GetClass() == "npc_sniper" then
                    --People got killed despite holding the shield, this should hopefully fix it.
                    local vec = Vector(dmg:GetAttacker():GetPos())
                    vec:Sub(target:GetPos())
                    local a = vec:Angle().y
                    local b = target:GetRenderAngles().y

                    if a > 180 then
                        a = a - 360
                    end

                    if math.abs(a - b) <= 45 then
                        return true
                    end
                elseif baseDamage < 100 then
                    dmg:ScaleDamage(0.75)
                end
            end
        end
    --[[elseif target:IsPlayer() && attacker:IsPlayer() && attacker:Team() == TEAM_COMBINE then
        dmg:ScaleDamage(GAMEMODE.ConVars.damage.npcs:GetFloat())]]
    end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmg)
    if dmg:GetAttacker():GetClass() == "npc_sniper" then
        if hitgroup == 1 && ply:GetActiveWeapon():GetClass() == "weapon_riotshield_ow" then
            --The shield is part of hitgroup 1 (head).
            --The sniper seems to prefer to shoot the center of mass, so this should be fine.
            --return true
        end
    end
end

function GM:PlayerDisconnected(ply)
    local ent = ply.DeathMarker
    if IsValid(ent) then
        ent:Remove()
    end

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

    timer.Create("TriggerActivityTeam", 0, 1, function()
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                ent:TriggerOutput("OnDisconnect", ent)
            end
        end
    end)
end

function SetLoadout(ply)
    ply:Give("weapon_crowbar")
    if GetRoundState() == ROUND_STARTED && ply.Ammo != nil then
        for k, v in pairs(ply.Ammo) do
            ply:SetAmmo(v, k)
        end
        for k, v in pairs(ply.Weapons) do
            if v != "weapon_frag" && v != "weapon_riotshield_ow" && v != "weapon_medpack_ow" then
                ply:Give(v)
            end
        end
    elseif GetRoundState() >= ROUND_WAITING || GAMEMODE.SoloSetup then
        for k, v in pairs(loadout) do
            if k == "hammerid" || k == "classname" || k == "origin" then continue end
            if GAMEMODE.AmmoCount[k] then
                for i = 1, v do
                    ply:GiveAmmo(GAMEMODE.AmmoCount[k][2], GAMEMODE.AmmoCount[k][1])
                end
            else
                ply:Give(k)
            end
        end
    end
end

function SetPlayerRelationships(ply, relationship)
    ply.Relationships = relationship
    if relationship == "neutral" then
        for _, ent in pairs(ents.GetAll()) do
            if ent:IsNPC() then
                ent:AddEntityRelationship(ply, D_NU, 99)
            end
        end
    else
        ResetPlayerRelationships(ply)
        if relationship != "default" then
            for _, ent in pairs(ents.GetAll()) do
                if ent:IsNPC() then
                    local disposition = GAMEMODE.Relationships[relationship][ent:GetClass()] || D_ER
                    if disposition > 0 then
                        if ent:GetClass() == "npc_turret_floor" && ent:HasSpawnFlags(512) then
                            --Friendly turrets only
                            ent:AddEntityRelationship(ply, GAMEMODE.Relationships.default[ent:GetClass()], 99)
                        else
                            ent:AddEntityRelationship(ply, disposition, 99)
                        end
                    end
                end
            end
        end
    end
end

function ResetPlayerRelationships(ply)
    for _, ent in pairs(ents.GetAll()) do
        if ent:IsNPC() then
            local disposition = GAMEMODE.Relationships.default[ent:GetClass()] || D_ER
            if disposition > 0 then
                if ent:GetClass() == "npc_turret_floor" && ent:HasSpawnFlags(512) then
                    --Friendly turrets only
                    ent:AddEntityRelationship(ply, D_NU, 99)
                else
                    ent:AddEntityRelationship(ply, disposition, 99)
                end
            end
        end
    end
end

--Debug Noclip
function GM:PlayerNoClip(ply, desiredState)
    if GAMEMODE.FriendlyFire then return true end
    return false
end