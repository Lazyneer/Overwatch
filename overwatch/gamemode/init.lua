loadout = loadout || {}
fragSpawns = fragSpawns || {}
playerModels = playerModels || {}

infoStart = infoStart || -1
overwatchCamera = overwatchCamera || -1
highlightedNPCs = highlightedNPCs || {}

AddCSLuaFile("cl_commands.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_gamemode.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_move.lua")
AddCSLuaFile("cl_net.lua")
AddCSLuaFile("cl_overwatch.lua")
AddCSLuaFile("cl_render.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("sh_enum.lua")
AddCSLuaFile("sh_gamemode.lua")
AddCSLuaFile("sh_relationships.lua")
AddCSLuaFile("sh_voicelines.lua")
AddCSLuaFile("shared.lua")
 
include('sh_enum.lua')
include('sh_gamemode.lua')
include('sh_relationships.lua')
include('sh_voicelines.lua')
include('shared.lua')
include('sv_commands.lua')
include('sv_death.lua')
include('sv_net.lua')
include('sv_nodegraph.lua')
include('sv_player.lua')
include('sv_rounds.lua')
include('sv_spectate.lua')
include('config/config.lua')

local files = file.Find("overwatch/gamemode/overviews/" .. game.GetMap() .. ".lua", "LUA")
if(#files > 0) then
	for _, v in pairs(files) do
        AddCSLuaFile("overviews/" .. v)
	end
end

function GM:Initialize()
    print("Overwatch Version " .. GAMEMODE.Version)

    for i = 1, 9 do
        util.PrecacheModel("models/player/group03/male_0" .. i .. ".mdl")
        util.PrecacheModel("models/player/group03m/male_0" .. i .. ".mdl")
        table.insert(playerModels, "models/player/group03/male_0" .. i .. ".mdl")
        if i < 7 then
            util.PrecacheModel("models/player/group03/female_0" .. i .. ".mdl")
            util.PrecacheModel("models/player/group03m/female_0" .. i .. ".mdl")
            table.insert(playerModels, "models/player/group03/female_0" .. i .. ".mdl")
        end
    end

    WaitingForPlayers()
    SetUnitCap()
end

function GM:OnReloaded()
    local ent = ents.GetMapCreatedEntity(overwatchCamera)
        if IsValid(ent) then
        GAMEMODE.Cameras.overwatch.pos = ent:GetPos()
        GAMEMODE.Cameras.overwatch.ang = ent:GetAngles()
    end
end

function GM:OnEntityCreated(ent)
    if ent:IsNPC() && IsValid(ent) then
        ent:ClearSchedule()
        ent:SetSchedule(SCHED_ALERT_STAND)
        ent:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)

        for _, ply in ipairs(player.GetAll()) do
            if ply.Relationships == "neutral" then
                ent:AddEntityRelationship(ply, D_NU, 99)
            elseif ply.Relationships != "default" then
                local disposition = GAMEMODE.Relationships[ply.Relationships][ent:GetClass()] || D_ER
                if disposition > 0 then
                    ent:AddEntityRelationship(ply, disposition, 99)
                end
            end
        end

        if ent:GetClass() == "npc_clawscanner" then
            ent:Fire("EquipMine")
            ent:SetNWBool("CarryingMine", true)
        elseif ent:GetClass() == "npc_combine_s" then
            if !ent:HasSpawnFlags(131072) then
                ent:SetKeyValue("spawnflags", ent:GetSpawnFlags() + 131072)
            end
        elseif ent:GetClass() == "npc_helicopter" then
            ent:SetNWInt("Charges", 4)
            ent:SetNWInt("Cooldown", 0)
        elseif ent:GetClass() == "npc_strider" then
            ent:SetNWInt("Charges", 2)
            ent:SetNWInt("Cooldown", 0)
        end

        if GAMEMODE.OverwatchNPCSpectator[ent:GetClass()] then
            if #player.GetAll() > 5 then
                local multiplier = ((#player.GetAll() - 5) * 0.2) + 1
                local health = ent:GetMaxHealth() * multiplier
                ent:SetMaxHealth(health)
                ent:SetHealth(health)
            end
        end

        if !GAMEMODE.OverwatchNPCBlacklist[ent:GetClass()] && !GAMEMODE.OverwatchNPCNoUnitCap[ent:GetClass()] then
            if GetUnitCount() >= GetUnitCap() then
                timer.Create("RemoveEntity" .. ent:GetCreationID(), 0, 1, function()
                    if ent:IsValid() then
                        ent:Fire("Kill")
                    end
                end)
            end
        end
    elseif IsValid(ent) && GAMEMODE.AmmoCount[ent:GetClass()] != nil then
        timer.Create("ReplaceAmmo" .. ent:GetCreationID(), 0, 1, function()
            if IsValid(ent) then
                local ammo = ents.Create("item_ammo_ow")
                ammo:SetPos(ent:GetPos())
                ammo:SetAngles(ent:GetAngles())
                ammo:SetModel(ent:GetModel())
                ammo:Spawn()
                ammo.AmmoType = game.GetAmmoID(GAMEMODE.AmmoCount[ent:GetClass()][1])
                ammo.AmmoCount = GAMEMODE.AmmoCount[ent:GetClass()][2]

                ent:Remove()
            end
        end)
    elseif IsValid(ent) && (string.find(ent:GetClass(), "item_") || string.find(ent:GetClass(), "weapon_")) then
        ent:AddEFlags(EFL_NO_DAMAGE_FORCES)
    elseif IsValid(ent) && ent:GetClass() == "prop_ragdoll" then
        timer.Create("RemoveRagdoll" .. ent:GetCreationID(), 10, 1, function()
            if ent:IsValid() then
                if string.find(ent:GetModel(), "strider") then
                    ent:Remove()
                end
            end
        end)
    end

    if IsValid(ent) && ent:GetClass() == "weapon_frag" then
        timer.Create("FragOrigin" .. ent:GetCreationID(), 0, 1, function()
            if IsValid(ent) then
                ent.origin = ent:GetPos()
                ent.noPickup = false
            end
        end)
    end
end

function GM:EntityKeyValue(ent, key, value)
    if ent:GetClass() == "game_player_equip_ow" && IsValid(ent) then
        loadout[key] = value
    elseif ent:IsNPC() && IsValid(ent) then
        if ent:GetClass() == "npc_combine_s" then
            if key == "NumGrenades" then
                ent:SetNWInt("NumGrenades", tonumber(value))
            end
        end

        if key == "freeunit" then
            ent:SetNWBool("FreeUnit", tobool(value))
        elseif key == "ignoreunseenenemies" then
            if !tobool(value) then
                ent:SetKeyValue("ignoreunseenenemies", "1")
            end
        elseif key == "squadname" then
            if #value == 0 then
                if ent:GetClass() == "npc_manhack" then
                    ent:Fire("SetSquad", "overwatch_squad_manhacks")
                --[[else
                    ent:Fire("SetSquad", "overwatch_squad")]]
                end
            end
        end
    elseif ent:GetClass() == "func_brush" && IsValid(ent) then
        if key == "hideoverwatch" then
            ent:SetNWBool("HideOverwatch", tobool(value))
        elseif key == "hiderebels" then
            ent:SetNWBool("HideRebels", tobool(value))
        elseif key == "barrier" then
            ent:SetNWBool("Barrier", tobool(value))
        end
    elseif string.find(ent:GetClass(), "prop_") && IsValid(ent) then
        if key == "hideoverwatch" then
            ent:SetNWBool("HideOverwatch", tobool(value))
        end
    elseif IsValid(GAMEMODE.TeamFilter) then
        if (ent:GetClass() == "trigger_multiple" || ent:GetClass() == "trigger_once") && IsValid(ent) then
            local keys = ent:GetKeyValues()
            if ent:HasSpawnFlags(1) && #keys["filtername"] == 0 then
                ent:SetSaveValue("m_hFilter", GAMEMODE.TeamFilter)
            end
        end
    end
end

function GM:InitPostEntity()
    RunConsoleCommand("sk_manhack_health", "10")

    --Not sure why, but the initial Overwatch camera doesnt show the right position when these loops are condensed into a single loop.
    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "info_player_gm_ow" && IsValid(ent) then
            overwatchCamera = ent:MapCreationID()
            GAMEMODE.Cameras.overwatch.pos = ent:GetPos()
            GAMEMODE.Cameras.overwatch.ang = ent:GetAngles()
            break
        end
    end

    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "info_player_start" && IsValid(ent) then
            infoStart = ent:MapCreationID()
            GAMEMODE.Cameras.spectator.ang = ent:GetAngles()
            break
        end
    end

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

    local _R = debug.getregistry()
    local nodegraph = _R.Nodegraph.Read()
    local nodes = nodegraph:GetNodes()
    local ground = 0
    local air = 0

    GAMEMODE.Nodes[NODE_TYPE_GROUND] = {}
    GAMEMODE.Nodes[NODE_TYPE_AIR] = {}

    for _, node in pairs(nodes) do
        if node.type == NODE_TYPE_GROUND then
            ground = ground + 1
            GAMEMODE.Nodes[NODE_TYPE_GROUND][ground] = node.pos
        elseif node.type == NODE_TYPE_AIR then
            air = air + 1
            GAMEMODE.Nodes[NODE_TYPE_AIR][air] = node.pos
        end
    end
end

function GM:Tick()
    if GetRoundState() == ROUND_SETUP || GetRoundState() == ROUND_STARTED then
        if #team.GetPlayers(TEAM_OVERWATCH) == 0 then
            EndRound(TEAM_REBELS)
        end
    end

    if GetRoundState() == ROUND_STARTED then
        local gameSettingsEnts = ents.FindByClass("game_settings_ow")
        local deadDefeat = true
        
        if #gameSettingsEnts > 0 then
            local ent = gameSettingsEnts[1]
            if IsValid(ent) then
                deadDefeat = ent:GetDeadDefeat()
            end
        end

        local alivePlayers = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() && ply:Team() == TEAM_REBELS then
                alivePlayers = alivePlayers + 1
            end
        end

        if alivePlayers == 0 then
            for _, ent in pairs(ents.GetAll()) do
                if ent:GetClass() == "game_activity_ow" && IsValid(ent) then
                    ent:TriggerOutput("OnAllPlayersDead", self)
                end
            end

            if deadDefeat then
                EndRound(TEAM_OVERWATCH)
            end
        end

        if #team.GetPlayers(TEAM_OVERWATCH) > 1 then
            local buffer = {}
            for _, v in pairs(highlightedNPCs) do
                for ent, _ in pairs(v) do
                    buffer[ent] = true
                end
            end

            local selectedNPCs = {}
            for ent, _ in pairs(buffer) do
                table.insert(selectedNPCs, ent)
            end

            for _, ply in ipairs(player.GetAll()) do
                if ply:Team() == TEAM_OVERWATCH then
                    net.Start("BroadcastHighlightedNPCs")
                    net.WriteUInt(#selectedNPCs, 8)
                    for _, ent in pairs(selectedNPCs) do
                        net.WriteEntity(ent)
                    end
                    net.Send(ply)
                end
            end
        end
    elseif GetRoundState() == ROUND_WAITING then
        if EnoughPlayers() then
            PrepareRound()
        end
    end

    for k, v in pairs(fragSpawns) do
        if CurTime() >= v["respawnTime"] then
            if v["origin"] != nil then
                local frag = ents.Create("weapon_frag")
                frag.noPickup = true
                frag:SetName(v["targetname"])
                frag:SetPos(v["origin"])
                frag:Spawn()
                frag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                frag:EmitSound("ambient/machines/teleport1.wav")
                frag.FragID = key

                fragSpawns[k] = nil
            else
                fragSpawns[k] = nil
            end
        end
    end

    for _, ent in pairs(ents.GetAll()) do
        if ent:IsNPC() && IsValid(ent) then
            local schedule = ent:GetCurrentSchedule()
            if schedule == SCHED_PATROL_WALK || schedule == 109 then
                ent:ClearSchedule()
                ent:SetSchedule(SCHED_ALERT_STAND)
            elseif (schedule == SCHED_TARGET_CHASE || schedule == 96 || schedule == 97) && !ent.ChaseTarget then
                ent:ClearSchedule()
                ent:SetSchedule(SCHED_ALERT_STAND)
            end
        end 
    end

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() && ply:Team() == TEAM_REBELS then
            for i = 1, 10 do
                local ammo = ply:GetAmmoCount(i)
                local weapon = ply:GetWeapon(GAMEMODE.AmmoLimits[i][2] || "nil")
                local extra = 0

                if(IsValid(weapon)) then
                    extra = weapon:GetMaxClip1() - weapon:Clip1()
                end
                
                if ammo > GAMEMODE.AmmoLimits[i][1] + extra then
                    ply:RemoveAmmo(ammo - (GAMEMODE.AmmoLimits[i][1] + extra), i)
                end
            end
        elseif ply:Alive() && ply:Team() == TEAM_COMBINE then
            for i = 1, 10 do
                ply:SetAmmo(999, i)
                if ply:GetActiveWeapon():GetClass() == "weapon_smg1" && ply:GetActiveWeapon():Clip1() > 15 then
                    ply:GetActiveWeapon():SetClip1(15)
                end
            end
        elseif ply:Team() == TEAM_OVERWATCH then
            --local ang = ents.GetMapCreatedEntity(overwatchCamera):GetAngles()
            local ang = Angle(80, 90, 0)
            ply:SetEyeAngles(ang)
        end
    end
end

function SetUnitCap()
    local countPlayers = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() && ply:Team() == TEAM_REBELS then
            countPlayers = countPlayers + 1
        end
    end
    
    if countPlayers == 0 then
        GAMEMODE.UnitCap = 50
    else
        GAMEMODE.UnitCap = math.Clamp(countPlayers * 4, 0, 50)
    end

    net.Start("BroadcastUnitCap")
    net.WriteUInt(GetUnitCap(), 6)
    net.Broadcast()
end

function GetUnitCap()
    return GAMEMODE.UnitCap
end

function SetOverwatch(ply)
    if overwatchCamera == -1 then return end

    if !IsValid(ply) then return end

    --local ang = ents.GetMapCreatedEntity(overwatchCamera):GetAngles()
    local ang = Angle(80, 90, 0)
    ply:SetTeam(TEAM_OVERWATCH)
    ply:KillSilent()
    ply:Spawn()
    ply:SetNoTarget(true)
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetEyeAngles(ang)
    ply:SetNoDraw(true)
    ply:SetNotSolid(true)
end

function SetNextMap(map, votes, total)
    GAMEMODE.NextMap = map

    net.Start("BroadcastNextMap")
    net.WriteString(map)
    if votes != nil then
        net.WriteBool(true)
        net.WriteUInt(votes, 8)
        net.WriteUInt(total, 8)
    end
    net.Broadcast()
end

cvars.AddChangeCallback("ow_maxrounds", function(convar, oldValue, newValue)
    net.Start("UpdateConvar")
    net.WriteString("maxrounds")
    net.WriteUInt(newValue, 8)
    net.Broadcast()
end)

cvars.AddChangeCallback("ow_timelimit", function(convar, oldValue, newValue)
    net.Start("UpdateConvar")
    net.WriteString("timelimit")
    net.WriteUInt(newValue, 16)
    net.Broadcast()
end)