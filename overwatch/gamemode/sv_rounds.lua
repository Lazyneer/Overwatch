function SetRoundState(state)
    GAMEMODE.RoundState = state

    net.Start("BroadcastRoundState")
    net.WriteInt(state, 4)
    net.Broadcast()

    hook.Run("OverwatchRoundState", state)
    if state == ROUND_WAITING then
        hook.Run("OverwatchRoundWaiting")
    elseif state == ROUND_PREPARING then
        hook.Run("OverwatchRoundPreparing")
    elseif state == ROUND_SETUP then
        hook.Run("OverwatchRoundSetup")
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "logic_auto_ow" && IsValid(ent) then
                ent:Fire("MultiNewRound")
            end
        end
    elseif state == ROUND_STARTED then
        hook.Run("OverwatchRoundStarted")
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "logic_auto_ow" && IsValid(ent) then
                ent:Fire("MultiRoundStart")
            elseif ent:GetClass() == "env_gmbutton_ow" && IsValid(ent) then
                ent:SetCooldownEnd(ent.InitialCooldown + math.Round(CurTime()))
            end
        end
    elseif state == ROUND_ENDED then
        hook.Run("OverwatchRoundEnded")
    end
end

function GetRoundState(state)
    return GAMEMODE.RoundState
end

function WaitingForPlayers()
    SetRoundState(ROUND_WAITING)
    GAMEMODE.SoloSetup = false
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() != TEAM_CONNECTING then
            if ply:IsBot() then
                ply:SetTeam(TEAM_REBELS)
                ply:KillSilent()
                ply:UnSpectate()
                ply:Spawn()
                ply.Model = playerModels[math.random(#playerModels)]
                ply.Gender = GENDER_MALE
                if string.find(ply.Model, "female") then
                    ply.Gender = GENDER_FEMALE
                end
                ply:SetModel(ply.Model)
                ply.OptInOverwatch = false
                SetPlayerRelationships(ply, "default")
            else
                ply:SetTeam(TEAM_SPECTATOR)
                ply:KillSilent()
                ply:Spectate(OBS_MODE_IN_EYE)
                ply:SpectateEntity(ents.GetMapCreatedEntity(infoStart))
                ply.OptInOverwatch = false
                ply.HasSpawnedThisRound = false
                ply:ConCommand("ow_jointeam")
                SetPlayerRelationships(ply, "neutral")
            end
        end
    end
end

function EnoughPlayers()
    local ready = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_OVERWATCH || ply:Team() == TEAM_REBELS then
            ready = ready + 1
        end
    end

    if #player.GetAll() == 1 && !GAMEMODE.SoloSetup then
        GAMEMODE.SoloSetup = true
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "logic_auto_ow" && IsValid(ent) then
                ent:Fire("MultiNewRound")
                ent:Fire("MultiRoundStart")
            end
        end
    elseif #player.GetAll() > 1 && GAMEMODE.SoloSetup then
        WaitingForPlayers()
    end

    return ready > 1
end

function PrepareRound()
    SetRoundState(ROUND_PREPARING)

    table.Empty(highlightedNPCs)

    local maxrounds = GAMEMODE.ConVars.maxrounds.convar:GetInt()
    local played = GAMEMODE.ConVars.maxrounds.played
    local timelimit = GAMEMODE.ConVars.timelimit.convar:GetInt()

    if GAMEMODE.NextMap == nil then
        if  (maxrounds > 0 && played >= maxrounds - 2) ||
            (timelimit > 0 && CurTime() >= GAMEMODE.ConVars.timelimit.start + timelimit - 600) then
            GAMEMODE.Nominated = {}
            GAMEMODE.Results = {}
            GAMEMODE.Voted = {}
            GAMEMODE.VoteActive = true
            local mapcycle = {}
            local count = 5
            mapcycle = table.Copy(GAMEMODE.MapCycle)
            table.RemoveByValue(mapcycle, game.GetMap())

            net.Start("VoteMenu")
            net.WriteUInt(count, 3)
            for i = 1, count do
                random = math.random(#mapcycle)
                table.insert(GAMEMODE.Nominated, mapcycle[random])
                net.WriteString(mapcycle[random])
                table.remove(mapcycle, random)

                GAMEMODE.Results[i] = 0
            end
            net.Broadcast()
        end
    end

    for _, ply in ipairs(player.GetAll()) do
        ply.ShowMenuAtWFP = false
        if ply:Team() == TEAM_OVERWATCH || ply:Team() == TEAM_REBELS then
            if ply:IsBot() then
                ply:SetTeam(TEAM_REBELS)
                ply:KillSilent()
                ply:UnSpectate()
                ply:Spawn()
                ply.Model = ply.Model || playerModels[math.random(#playerModels)]
                ply.Gender = GENDER_MALE
                if string.find(ply.Model, "female") then
                    ply.Gender = GENDER_FEMALE
                end
                ply:SetModel(ply.Model)
                ply.OptInOverwatch = true
            end
        end
    end

    net.Start("SetCameras")
    net.WriteVector(GAMEMODE.Cameras.overwatch.pos)
    net.WriteAngle(GAMEMODE.Cameras.overwatch.ang)
    net.WriteAngle(GAMEMODE.Cameras.spectator.ang)
    net.Broadcast()

    if !timer.Start("SelectingOverwatch") then
        GAMEMODE.countDown = 15
        net.Start("ShowSetupTimer")
        net.WriteInt(GAMEMODE.countDown, 5)
        net.Broadcast()
        
        timer.Create("SelectingOverwatch", 1, 0, SelectingOverwatch)
    end
end

function SelectingOverwatch()
    if GAMEMODE.countDown > 0 then
        net.Start("ShowSetupTimer")
        net.WriteInt(GAMEMODE.countDown, 5)
        net.Broadcast()
        GAMEMODE.countDown = GAMEMODE.countDown - 1
    else
        timer.Stop("SelectingOverwatch")
        game.CleanUpMap()
        SetRoundState(ROUND_SETUP)

        local players = {}
        for _, ply in ipairs(player.GetAll()) do
            if ply:Team() == TEAM_REBELS then
                table.insert(players, ply)
            end
        end

        table.sort(players, function(a, b)
            if a.OptInOverwatch && b.OptInOverwatch then
                return a.HasBeenOverwatch < b.HasBeenOverwatch
            elseif a.OptInOverwatch != b.OptInOverwatch then
                return a.OptInOverwatch
            end

            if a:IsBot() || b:IsBot() then
                return a:IsBot()
            end

            return a.HasBeenOverwatch < b.HasBeenOverwatch
        end)

        local overwatchCount = 1
        if GAMEMODE.ConVars.multiple:GetInt() > 0 then
            local ratio = GAMEMODE.ConVars.multiple:GetInt() + 1
            overwatchCount = math.ceil(#players / ratio)
        end

        while overwatchCount > 0 && #players > 0 do
            local overwatchPlayer = players[1]
            SetOverwatch(overwatchPlayer)
            overwatchPlayer.HasBeenOverwatch = overwatchPlayer.HasBeenOverwatch + 1
            overwatchCount = overwatchCount - 1
            table.remove(players, 1)
        end

        for _, ply in ipairs(player.GetAll()) do
            if ply:Team() == TEAM_REBELS then
                ply:KillSilent()
                ply:UnSpectate()
                ply:Spawn()
            elseif ply:Team() == TEAM_SPECTATOR then
                SpectatePlayer(ply)
            end

            if ply:Team() == TEAM_OVERWATCH || ply:Team() == TEAM_REBELS then
                net.Start("CloseMenu")
                net.Send(ply)
            end
        end

        if(IsValid(overwatchPlayer)) then
            net.Start("AnnounceOverwatch")
            net.WriteEntity(overwatchPlayer)
            net.Broadcast()
        end

        GAMEMODE.countDown = 4
        net.Start("ShowSetupTimer")
        net.WriteInt(GAMEMODE.countDown + 1, 5)
        net.Broadcast()

        timer.Create("RoundStarting", 1, 0, RoundStarting)
    end
end

function RoundStarting()
    if GAMEMODE.countDown > 0 then
        net.Start("ShowSetupTimer")
        net.WriteInt(GAMEMODE.countDown, 5)
        net.Broadcast()
        GAMEMODE.countDown = GAMEMODE.countDown - 1
    else
        timer.Stop("RoundStarting")
        SetRoundState(ROUND_STARTED)

        if GAMEMODE.VoteActive then
            GAMEMODE.VoteActive = false

            local tied = {}
            local votes = 0
            local total = 0
            for k, v in SortedPairsByValue(GAMEMODE.Results, true) do
                total = total + v
                if v > votes then
                    votes = v
                    table.insert(tied, GAMEMODE.Nominated[k])
                end
            end

            local index = math.random(#tied)
            SetNextMap(tied[index], votes, total)
        end

        local timelimit = GAMEMODE.ConVars.timelimit.convar:GetInt()
        if timelimit > 0 then
            local start = GAMEMODE.ConVars.timelimit.start
            if start == 0 then
                start = math.floor(CurTime())
                GAMEMODE.ConVars.timelimit.start = start
            end

            net.Start("BroadcastConVarTimeLimit")
            net.WriteUInt(start, 16)
            net.Broadcast()
        end

        for _, ply in ipairs(player.GetAll()) do
            if ply:Team() == TEAM_SPECTATOR then
                net.Start("CloseMenu")
                net.Send(ply)
            elseif ply:Team() == TEAM_REBELS then
                ply.HasSpawnedThisRound = true
            end
        end
    end
end

function EndRound(team, changelevel)
    SetRoundState(ROUND_ENDED)

    team = team || 1
    changelevel = changelevel || false

    net.Start("ShowRoundWinner")
    net.WriteInt(team, 3)
    net.Broadcast()

    local maxrounds = GAMEMODE.ConVars.maxrounds.convar:GetInt()
    local played = GAMEMODE.ConVars.maxrounds.played + 1
    GAMEMODE.ConVars.maxrounds.played = played

    net.Start("BroadcastConVarMaxRounds")
    net.WriteUInt(played, 8)
    net.Broadcast()

    local timelimit = GAMEMODE.ConVars.timelimit.convar:GetInt()

    if  (maxrounds > 0 && played >= maxrounds) ||
        (timelimit > 0 && CurTime() >= GAMEMODE.ConVars.timelimit.start + timelimit) ||
        changelevel then
        timer.Create("ChangeMap", 15, 1, ChangeMapTimer)
    else
        timer.Create("RestartRound", 5, 1, RestartRoundTimer)
    end
end

function RestartRoundTimer()
    for _, ply in ipairs(player.GetAll()) do
        ply.ShowMenuAtWFP = true
        ply.Ammo = nil
    end

    game.CleanUpMap()
    WaitingForPlayers()
end

function ChangeMapTimer()
    local nextMap
    if GAMEMODE.NextMap == nil then
        nextMap = game.GetMap()
    else
        nextMap = GAMEMODE.NextMap
    end
    RunConsoleCommand("changelevel", nextMap)
end

function GM:PostCleanupMap()
    local filter = ents.Create("filter_activator_team")
    filter:SetKeyValue("filterteam", 3)
    filter:SetKeyValue("Negated", 0)
    filter:SetName("filter_team_ow")
    filter:Spawn()
    
    GAMEMODE.TeamFilter = filter

    for _, ent in pairs(ents.GetAll()) do
        if (ent:GetClass() == "trigger_multiple" || ent:GetClass() == "trigger_once") && IsValid(ent) then
            local keys = ent:GetKeyValues()
            if ent:HasSpawnFlags(1) && #keys["filtername"] == 0 then
                ent:SetSaveValue("m_hFilter", GAMEMODE.TeamFilter)
            end
        end
    end
end