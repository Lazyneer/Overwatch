function GM:KeyPress(ply, key)
    if ply:Team() == TEAM_SPECTATOR || (ply:Team() == TEAM_REBELS && !ply:Alive() && !ply.BeingRevived) then
        if key == IN_ATTACK then
            --Spectate the next target
            local target = GetNextAlivePlayer(ply, ply:GetObserverTarget())

            if IsValid(target) then
                ply:Spectate(OBS_MODE_IN_EYE)
                ply:SpectateEntity(target)
                if target:IsPlayer() then
                    ply:Spectate(ply.ObsMode || OBS_MODE_CHASE)
                    ply:SetupHands(target)
                elseif target:IsNPC() then
                    ply:Spectate(OBS_MODE_CHASE)
                end
            end
        elseif key == IN_ATTACK2 then
            --Spectate the previous target
            local target = GetPreviousAlivePlayer(ply, ply:GetObserverTarget())

            if IsValid(target) then
                ply:Spectate(OBS_MODE_IN_EYE)
                ply:SpectateEntity(target)
                if target:IsPlayer() then
                    ply:Spectate(ply.ObsMode || OBS_MODE_CHASE)
                    ply:SetupHands(target)
                elseif target:IsNPC() then
                    ply:Spectate(OBS_MODE_CHASE)
                end
            end
        elseif key == IN_JUMP then
            --Control NPC
            local target = ply:GetObserverTarget()
            if target:IsNPC() && ply:Team() == TEAM_SPECTATOR && GAMEMODE.ConVars.spectator:GetBool() then
                if team.NumPlayers(TEAM_COMBINE) < math.max(math.floor(team.NumPlayers(TEAM_REBELS) / 3), 1) then
                    if ply.ControlCooldown < CurTime() && GAMEMODE.OverwatchNPCSpectator[target:GetClass()] && target:Health() > 0 then
                        local td = {}
                        td.start = target:GetPos()

                        td.endpos = Vector()
                        td.endpos:Set(td.start)
                        td.endpos:Add(Vector(0, 0, 72))

                        td.mins = Vector(-16, -16)
                        td.maxs = Vector(16, 16, 72)
                        td.filter = target

                        local tr = util.TraceHull(td)
                        if !tr.AllSolid then
                            local data = {
                                model = string.Replace(target:GetModel(), "models/", "models/player/"),
                                weapon = target:GetInternalVariable("additionalequipment"),
                                health = target:Health(),
                                maxHealth = target:GetMaxHealth(),
                                chase = target.ChaseTarget,
                                target = target:GetTarget(),
                                moveTo = target.MoveTo,
                                ang = target:GetAngles(),
                                pos = target:GetPos()
                            }
                            target:Fire("Kill")
                    
                            ply.AllowedWeapon = data.weapon
                            ply:SetTeam(TEAM_COMBINE)
                            ply:UnSpectate()
                            ply:Spawn()
                            ply:SetPos(data.pos)
                            ply:SetEyeAngles(data.ang)
                            ply:SetNWVector("MoveTo", data.moveTo)
                            ply:SetNWEntity("Target", data.target)
                            ply:SetNWBool("ChaseTarget", data.chase)
                            ply:SetNWInt("MaxHealth", data.maxHealth)
                            ply:SetMaxHealth(0)
                            ply:SetHealth(data.health)
                            ply:Give(data.weapon)
                            ply:SetModel(data.model)
                            ply:SetupHands(ply)
                            GAMEMODE:SetPlayerSpeed(ply, 150, 150)
                            SetPlayerRelationships(ply, "combine")
                            if data.weapon == "weapon_shotgun" then
                                ply:SetSkin(1)                  
                            end

                            --Making sure it sets the angles
                            timer.Create("SetPlayerAngles" .. ply:EntIndex(), 0, 1, function()
                                if IsValid(ply) then
                                    ply:SetEyeAngles(data.ang)
                                end
                            end)
                        end
                    end
                end
            else
                --Toggle observermode
                if ply:GetObserverMode() == OBS_MODE_CHASE then
                    ply.ObsMode = OBS_MODE_IN_EYE
                else
                    ply.ObsMode = OBS_MODE_CHASE
                end

                ply:Spectate(OBS_MODE_IN_EYE)
                if target:IsPlayer() then
                    ply:SetObserverMode(ply.ObsMode)
                end
            end
        end
    end
end

function GetNextAlivePlayer(ply, ent)
    local alive = GetAlivePlayers(ply)

    if #alive < 1 then return nil end

    local prev = nil
    local choice = nil
    if IsValid(ent) then
        for _, p in ipairs(alive) do
            if prev == ent then
                choice = p
            end
            prev = p
        end
    end

    if !IsValid(choice) then
        choice = alive[1]
    end

    return choice
end

function GetPreviousAlivePlayer(ply, ent)
    local alive = GetAlivePlayers(ply)

    if #alive < 1 then return nil end

    local prev = nil
    local choice = nil
    local aliveReversed = {}
    for k, p in ipairs(alive) do
        aliveReversed[#alive - (k - 1)] = p
    end

    if IsValid(ent) then
        for _, p in ipairs(aliveReversed) do
            if prev == ent then
                choice = p
            end
            prev = p
        end
    end

    if !IsValid(choice) then
        choice = aliveReversed[1]
    end

    return choice
end

function GetAlivePlayers(caller)
    local alive = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:Team() == TEAM_REBELS then
            table.insert(alive, ply)
        end
    end

    if IsValid(ents.GetMapCreatedEntity(infoStart)) then
        table.insert(alive, ents.GetMapCreatedEntity(infoStart))
    end

    if caller:Team() == TEAM_SPECTATOR && GAMEMODE.ConVars.spectator:GetBool() then
        for _, ent in pairs(ents.GetAll()) do
            if ent:IsNPC() && IsValid(ent) && !ent:GetNWBool("FreeUnit") && GAMEMODE.OverwatchNPCSpectator[ent:GetClass()] && ent:Health() > 0 then
                table.insert(alive, ent)
            end
        end
    end

    return alive
end

function SpectatePlayer(ply)
    ply:Spectate(OBS_MODE_IN_EYE)
    ply:SpectateEntity(nil)

    local alive = GetAlivePlayers(ply)

    if #alive < 1 then return end

    local target = alive[1]
    if IsValid(target) then
        if target:IsPlayer() then
            ply:Spectate(OBS_MODE_CHASE)
        end
        ply:SpectateEntity(target)
    end
end