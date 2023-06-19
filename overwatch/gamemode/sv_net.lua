--Client to Server
util.AddNetworkString("ClickGuiButton")
util.AddNetworkString("DropRoleWeapon")
util.AddNetworkString("DisableWeaponSwitch")
util.AddNetworkString("EmitNetworkedVoiceLine")
util.AddNetworkString("HighlightNPC")
util.AddNetworkString("KillNPC")
util.AddNetworkString("MoveNPC")
util.AddNetworkString("StopNPC")
util.AddNetworkString("UpdatePosition")
util.AddNetworkString("UseAbility")
util.AddNetworkString("Voted")

--Server to Client
util.AddNetworkString("AnnounceOverwatch")
util.AddNetworkString("BroadcastConVarMaxRounds")
util.AddNetworkString("BroadcastConVarTimeLimit")
util.AddNetworkString("BroadcastHighlightedNPCs")
util.AddNetworkString("BroadcastNextMap")
util.AddNetworkString("BroadcastRoundState")
util.AddNetworkString("BroadcastUnitCap")
util.AddNetworkString("CloseMenu")
util.AddNetworkString("ControlCooldown")
util.AddNetworkString("NetworkNodes")
util.AddNetworkString("PlayOverwatchSound")
util.AddNetworkString("PrintVoiceLine")
util.AddNetworkString("RespawnTime")
util.AddNetworkString("SetCameras")
util.AddNetworkString("SetReviveEntity")
util.AddNetworkString("ShowOrderTarget")
util.AddNetworkString("ShowRoundWinner")
util.AddNetworkString("ShowSetupTimer")
util.AddNetworkString("SpectatorMessage")
util.AddNetworkString("UpdateConvar")
util.AddNetworkString("UpdateOverwatchPosition")
util.AddNetworkString("VoteMenu")

net.Receive("ClickGuiButton", function()
    local ent = net.ReadEntity()
    if ent:GetClass() == "env_gmbutton_ow" then
        if ent:GetEnabled() == nil then
            ent:Remove()
            return
        end

        if ent:GetEnabled() && GetUnitCount() < GetUnitCap() then
            if ent:GetCooldownEnd() <= CurTime() then   
                ent:TriggerOutput("OnPressed", ent)
                local charges = ent:GetCharges()
                charges = charges - 1
                ent:SetCharges(charges)
                if charges == 0 then
                    ent:SetEnabled(false)
                else
                    local alivePlayers = 0
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:Team() == TEAM_REBELS && ply:Alive() then
                            alivePlayers = alivePlayers + 1
                        end
                    end

                    local cooldownScale = math.Clamp(-0.05 * alivePlayers + 1.25, 0.5, 1)
                    ent:SetCooldownEnd(CurTime() + (ent.Cooldown * cooldownScale * GAMEMODE.ConVars.cooldown:GetFloat()))
                end
            end
        end
    end
end)

net.Receive("DisableWeaponSwitch", function(len, ply)
    if GAMEMODE.DisableWeaponSwitch == nil then
        GAMEMODE.DisableWeaponSwitch = {}
        GAMEMODE.DisableWeaponSwitch[ply:EntIndex()] = false
    end

    GAMEMODE.DisableWeaponSwitch[ply:EntIndex()] = net.ReadBool()
end)

net.Receive("DropRoleWeapon", function(len, ply)
    local wep = net.ReadEntity()
    if IsValid(ply) && IsValid(wep) then
        ply:DropWeapon(wep)
        wep:SetName(wep.TargetName)

        if wep:GetClass() == "weapon_medpack_ow" then
            local model = ply:GetModel()
            model = string.Replace(model, "/group03m/", "/group03/")
            ply:SetModel(model)
        end
    end
end)

local function PrintVoiceLinePrefix(ply, msg)
    net.Start("PrintVoiceLine")
    net.WriteEntity(ply)
    net.WriteString(msg)
    net.Broadcast()
end

net.Receive("EmitNetworkedVoiceLine", function(len, ply)
    local soundType = net.ReadUInt(4)
    local menu = net.ReadBool()
    if IsValid(ply) then
        if (ply.VoiceMenuCooldown < CurTime() && menu) || (ply.VoiceLineCooldown < CurTime() && !menu) then
            ply.VoiceMenuCooldown = CurTime() + 3
            ply.VoiceLineCooldown = CurTime() + 60
            if ply.Gender == GENDER_MALE then
                ply:EmitSound(GAMEMODE.VoiceLines[soundType]["male"][math.random(#GAMEMODE.VoiceLines[soundType]["male"])])
            else
                ply:EmitSound(GAMEMODE.VoiceLines[soundType]["female"][math.random(#GAMEMODE.VoiceLines[soundType]["female"])])
            end

            if soundType == VOICE_HELP then
                PrintVoiceLinePrefix(ply, "Help!")
            elseif soundType == VOICE_MEDIC then
                PrintVoiceLinePrefix(ply, "Medic!")
            elseif soundType == VOICE_LEAD then
                PrintVoiceLinePrefix(ply, "Lead the way.")
            elseif soundType == VOICE_GO then
                PrintVoiceLinePrefix(ply, "Let's go.")
            elseif soundType == VOICE_READY then
                PrintVoiceLinePrefix(ply, "Ready.")
            end
        end
    end
end)

net.Receive("HighlightNPC", function(len, ply)
    highlightedNPCs[ply] = {}
    local size = net.ReadUInt(8)
    for i = 1, size do
        highlightedNPCs[ply][net.ReadEntity()] = true
    end
end)

net.Receive("KillNPC", function()
    local selectedNPCs = net.ReadTable()
    for _, ent in pairs(selectedNPCs) do
        if IsValid(ent) && ent:IsNPC() then
            ent:SetNWBool("FadeNow", true)
            ent:Fire("SetHealth", "-1")
        end
    end
end)

local offsetTable = {
    Vector(),
    Vector(-64, 0),
    Vector(0, 64),
    Vector(64, 0),
    Vector(0, -64),
    Vector(-64, -64),
    Vector(-64, 64),
    Vector(64, 64),
    Vector(64, -64)
}

local function TargetOffset(target, index)
    while index > 9 do
        index = index - 9
    end

    local newTarget = Vector()
    newTarget:Set(target)
    newTarget:Add(offsetTable[index])
    return newTarget
end

net.Receive("MoveNPC", function(len, ply)
    local orderType = net.ReadInt(3)
    local selectedNPCs = net.ReadTable()
    local targetGround = net.ReadVector()
    local targetAir = net.ReadVector()
    local attackPly = net.ReadEntity()

    if targetGround:IsEqualTol(Vector(), 0) then return end

    for _, v in ipairs(player.GetAll()) do
        if v:Team() == TEAM_OVERWATCH && ply != v then
            net.Start("ShowOrderTarget")
            net.WriteEntity(ply)
            net.WriteUInt(orderType, 2)
            net.WriteVector(targetGround)
            net.Send(v)
        end
    end

    local counter = 1
    for _, ent in pairs(selectedNPCs) do
        if IsValid(ent) && ent:IsNPC() then
            
            local target = targetGround
            if ent:GetClass() == "npc_helicopter" then
                for _, entity in pairs(ents.GetAll()) do
                    if entity:GetClass() == "path_track" then
                        entity:Fire("Kill")
                    end
                end

                local path = ents.Create("path_track")
                path:SetName("overwatch_path")
                path:SetPos(targetAir)
                path:Spawn()
                ent:Fire("SetTrack", "overwatch_path")
            elseif GAMEMODE.OverwatchNPCAir[ent:GetClass()] then
                target = targetAir
            end

            if orderType == ORDER_ATTACK then
                ent:SetTarget(attackPly)
                ent:SetSchedule(SCHED_TARGET_CHASE)
                ent.ChaseTarget = true
            elseif orderType == ORDER_ATTACKMOVE then
                local actualTarget = TargetOffset(target, counter)
                ent:ClearEnemyMemory()
                ent:SetLastPosition(actualTarget)
                ent:SetSchedule(SCHED_FORCED_GO_RUN)
                ent.ChaseTarget = true
                ent.MoveTo = actualTarget
                counter = counter + 1
            elseif orderType == ORDER_MOVE then
                local actualTarget = TargetOffset(target, counter)
                ent:ClearEnemyMemory()
                ent:SetLastPosition(actualTarget)
                ent:SetSchedule(SCHED_FORCED_GO_RUN)
                ent.ChaseTarget = false
                ent.MoveTo = actualTarget
                counter = counter + 1
            end
        elseif ent:IsPlayer() && ent:Team() == TEAM_COMBINE then
            net.Start("PlayOverwatchSound")
            net.WriteString("buttons/combine_button_locked.wav")
            net.Send(ent)
            if orderType == ORDER_ATTACK then
                ent:SetNWEntity("Target", attackPly)
                ent:SetNWVector("MoveTo", target)
                ent:SetNWBool("ChaseTarget", true)
            elseif orderType == ORDER_ATTACKMOVE then
                ent:SetNWEntity("Target", ent)
                ent:SetNWVector("MoveTo", target)
                ent:SetNWBool("ChaseTarget", true)
            elseif orderType == ORDER_MOVE then
                ent:SetNWEntity("Target", ent)
                ent:SetNWVector("MoveTo", target)
                ent:SetNWBool("ChaseTarget", false)
            end
        end
    end
end)

net.Receive("StopNPC", function()
    local selectedNPCs = net.ReadTable()
    for _, ent in pairs(selectedNPCs) do
        if IsValid(ent) && ent:IsNPC() then
            ent:ClearSchedule()
            ent:SetSchedule(SCHED_ALERT_STAND)
        elseif ent:IsPlayer() && ent:Team() == TEAM_COMBINE then
            ent:SetNWVector("MoveTo", nil)
            ent:SetNWEntity("Target", ent)
        end
    end
end)

net.Receive("UpdatePosition", function(len, ply)
    if ply:Team() == TEAM_OVERWATCH then
        local position = net.ReadVector()
        ply:SetPos(position)

        for _, target in ipairs(player.GetAll()) do
            if target:Team() == TEAM_OVERWATCH && ply != target then
                net.Start("UpdateOverwatchPosition", true)
                net.WriteEntity(ply)
                net.WriteVector(position)
                net.Send(target)
            end
        end
    end
end)

net.Receive("UseAbility", function()
    local ent = net.ReadEntity()
    if IsValid(ent) then
        if ent:GetClass() == "npc_combine_s" then
            local target = ent:GetEnemy()
            if IsValid(target) then
                if target:IsPlayer() then
                    target = target:GetNWString("targetname")
                else
                    target:GetName()
                end
                ent:Fire("ThrowGrenadeAtTarget", target)
                ent:SetNWInt("NumGrenades", ent:GetNWInt("NumGrenades") - 1)
            end
        elseif ent:GetClass() == "npc_strider" then
            local target = ent:GetEnemy()
            if IsValid(target) then
                if target:IsPlayer() then
                    target = target:GetNWString("targetname")
                else
                    target:GetName()
                end

                if ent.delay == nil then
                    ent.delay = 0
                end
    
                if ent.delay <= CurTime() && ent:GetNWInt("Charges") > 0 then
                    ent.delay = CurTime() + 10
                    ent:SetNWInt("Charges", ent:GetNWInt("Charges") - 1)
                    ent:SetNWInt("Cooldown", ent.delay)
    
                    ent:Fire("SetCannonTarget", target)
                end                
            end
        elseif ent:GetClass() == "npc_clawscanner" then
            ent:Fire("DeployMine")
            ent:SetNWBool("CarryingMine", false)
        elseif ent:GetClass() == "npc_helicopter" then
            if ent.delay == nil then
                ent.delay = 0
            end

            if ent.delay <= CurTime() && ent:GetNWInt("Charges") > 0 then
                ent.delay = CurTime() + 10
                ent:SetNWInt("Charges", ent:GetNWInt("Charges") - 1)
                ent:SetNWInt("Cooldown", ent.delay)

                ent:Fire("StartCarpetBombing")
                timer.Create("HelicopterStopCarpet" .. ent:GetCreationID(), 1.5, 1, function() ent:Fire("StopCarpetBombing") end)
            end
        end
    end
end)

net.Receive("Voted", function(len, ply)
    if !GAMEMODE.Voted[ply] then
        GAMEMODE.Voted[ply] = true
        
        local item = net.ReadUInt(3)
        GAMEMODE.Results[item] = GAMEMODE.Results[item] + 1
    end
end)