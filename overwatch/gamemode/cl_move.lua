local function SuppressNumberKey()
    LocalPlayer().suppressNumberKey = true
    timer.Create("SuppressNumberKey", 0.5, 1, function()
        LocalPlayer().suppressNumberKey = false
    end)
end 

local screenPanel
function GM:Tick()
    if IsValid(LocalPlayer()) then
        if LocalPlayer().menuOpen || LocalPlayer():Team() == TEAM_OVERWATCH then
            gui.EnableScreenClicker(true)
        else
            gui.EnableScreenClicker(false)
        end

        for _, ent in pairs(ents.GetAll()) do
            if (ent:GetClass() == "func_brush" || string.find(ent:GetClass(), "prop_")) && IsValid(ent) then
                if LocalPlayer():Team() == TEAM_OVERWATCH && ent:GetNWBool("HideOverwatch") then
                    ent:SetNoDraw(true)
                elseif LocalPlayer():Team() != TEAM_OVERWATCH && ent:GetNWBool("HideRebels") then
                    ent:SetNoDraw(true)
                else
                    ent:SetNoDraw(false)
                end
            end
        end

        if LocalPlayer():Team() == TEAM_OVERWATCH then
            local movement = Vector()
            local updateMovement = false
            if LocalPlayer():KeyDown(IN_FORWARD) then
                movement:Add(Vector(0, 17, 0))
                updateMovement = true
            end
            if LocalPlayer():KeyDown(IN_MOVELEFT) then
                movement:Add(Vector(-17, 0, 0))
                updateMovement = true
            end
            if LocalPlayer():KeyDown(IN_BACK) then
                movement:Add(Vector(0, -17, 0))
                updateMovement = true
            end
            if LocalPlayer():KeyDown(IN_MOVERIGHT) then
                movement:Add(Vector(17, 0, 0))
                updateMovement = true
            end

            if(LocalPlayer():KeyDown(IN_SPEED)) then
                movement:Mul(2)
            end

            if updateMovement then
                OverwatchPos:Add(movement)
            end

            if screenPanel == nil then
                screenPanel = vgui.Create("panel")
                screenPanel:SetPos(0, 0)
                screenPanel:SetSize(ScrW(), ScrH())
                screenPanel:SetCursor("blank")
            elseif screenPanel != nil then
                screenPanel:SetCursor("blank")
                if handCursor then
                    screenPanel:SetCursor("hand")
                end
            end

            net.Start("UpdatePosition", true)
            net.WriteVector(OverwatchPos)
            net.SendToServer()
        elseif LocalPlayer():Team() != TEAM_OVERWATCH then
            if screenPanel != nil then
                screenPanel:Remove()
                screenPanel = nil
            end
        end
    end
end

local function IsDroppingRoleWeapon(cmd, wep)
    if IsKeyClicked(cmd:KeyDown(IN_RELOAD), IN_RELOAD) then
        net.Start("DropRoleWeapon")
        net.WriteEntity(wep)
        net.SendToServer()
    end
end

function GM:CreateMove(cmd)
    if !LocalPlayer():IsTyping() && !gui.IsGameUIVisible() then
        if LocalPlayer():Team() != TEAM_OVERWATCH then
            cmd:RemoveKey(IN_SPEED)
        else
            cmd:RemoveKey(IN_DUCK)
        end
        
        if LocalPlayer():Team() == TEAM_OVERWATCH && !LocalPlayer().menuOpen && !LocalPlayer().suppressNumberKey && #selectedNPCs > 0 then
            if input.WasKeyPressed(KEY_1) && input.LookupBinding("ow_order_attack", true) == nil then
                RunConsoleCommand("ow_order_attack")
            elseif input.WasKeyPressed(KEY_2) && input.LookupBinding("ow_order_attackmove", true) == nil then
                RunConsoleCommand("ow_order_attackmove")
            elseif input.WasKeyPressed(KEY_3) && input.LookupBinding("ow_order_move", true) == nil then
                RunConsoleCommand("ow_order_move")
            elseif input.WasKeyPressed(KEY_4) && input.LookupBinding("ow_order_stop", true) == nil then
                RunConsoleCommand("ow_order_stop")
            end
        end

        local activeWeapon = LocalPlayer():GetActiveWeapon()
        if LocalPlayer().menuOpen then
            if input.WasKeyPressed(KEY_1) then
                RunConsoleCommand("ow_jointeam_overwatch")
                SuppressNumberKey()
                LocalPlayer().menuFrame:Close()
                LocalPlayer().menuOpen = false
                LocalPlayer().menuFrame = nil
            elseif input.WasKeyPressed(KEY_2) then
                RunConsoleCommand("ow_jointeam_rebels")
                SuppressNumberKey()
                LocalPlayer().menuFrame:Close()
                LocalPlayer().menuOpen = false
                LocalPlayer().menuFrame = nil
            elseif input.WasKeyPressed(KEY_3) then
                RunConsoleCommand("ow_jointeam_spectator")
                SuppressNumberKey()
                LocalPlayer().menuFrame:Close()
                LocalPlayer().menuOpen = false
                LocalPlayer().menuFrame = nil
            elseif input.WasKeyPressed(KEY_4) then
                LocalPlayer().menuFrame:GetChild(4):GetChild(3):ToggleVisible()
                LocalPlayer().menuFrame:GetChild(4):GetChild(4):ToggleVisible()
            elseif input.WasKeyPressed(KEY_5) then
                LocalPlayer().menuFrame:Close()
                LocalPlayer().menuOpen = false
                LocalPlayer().menuFrame = nil
            end
        elseif LocalPlayer().VoteMenu && !LocalPlayer().suppressNumberKey then
            local voted
            if input.WasKeyPressed(KEY_1) then
                voted = 1
                if activeWeapon:IsValid() then
                    input.SelectWeapon(activeWeapon)
                end
            elseif input.WasKeyPressed(KEY_2) then
                voted = 2
                if activeWeapon:IsValid() then
                    input.SelectWeapon(activeWeapon)
                end
            elseif input.WasKeyPressed(KEY_3) then
                voted = 3
                if activeWeapon:IsValid() then
                    input.SelectWeapon(activeWeapon)
                end
            elseif input.WasKeyPressed(KEY_4) then
                voted = 4
                if activeWeapon:IsValid() then
                    input.SelectWeapon(activeWeapon)
                end
            elseif input.WasKeyPressed(KEY_5) then
                voted = 5
                if activeWeapon:IsValid() then
                    input.SelectWeapon(activeWeapon)
                end
            end

            if voted then
                net.Start("Voted")
                net.WriteUInt(voted, 3)
                net.SendToServer()  
                LocalPlayer().VoteMenu = false
                chat.AddText(team.GetColor(TEAM_REBELS), "You voted for " .. SanitizeMapName(GAMEMODE.Nominated[voted]))
            end
        end

        if !LocalPlayer().menuOpen then
            if input.WasKeyPressed(KEY_PERIOD) && input.LookupBinding("ow_jointeam", true) == nil then
                RunConsoleCommand("ow_jointeam")
            end
        end

        if LocalPlayer():Team() == TEAM_REBELS && LocalPlayer():Alive() then
            if (IsValid(LocalPlayer().ReviveEntity) && LocalPlayer().ReviveEntity:GetClass() == "prop_rebel_revive") || GetRoundState() == ROUND_SETUP then
                cmd:ClearMovement()
                cmd:RemoveKey(IN_ATTACK)
                cmd:RemoveKey(IN_ATTACK2)
                cmd:RemoveKey(IN_JUMP)
            end

            if input.WasKeyPressed(KEY_V) && input.LookupBinding("ow_minimap", true) == nil && !LocalPlayer().SupressMiniMapZoom then
                LocalPlayer().MiniMapZoom = !LocalPlayer().MiniMapZoom
                LocalPlayer().SupressMiniMapZoom = true
                timer.Create("SupressMiniMapZoom", 0.1, 1, function()
                    LocalPlayer().SupressMiniMapZoom = false
                end)
            end

            if GetRoundState() == ROUND_STARTED || #player.GetAll() == 1 then
                if input.WasKeyPressed(KEY_Z) && !LocalPlayer().VoiceMenu && !LocalPlayer().VoteMenu && input.LookupBinding("ow_voicemenu", true) == nil then
                    LocalPlayer().VoiceMenu = true
                elseif LocalPlayer().VoiceMenu then
                    if !input.WasKeyPressed(KEY_0) then
                        local soundType
                        if input.WasKeyPressed(KEY_1) then
                            soundType = VOICE_HELP
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_2) then
                            soundType = VOICE_MEDIC
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_3) then
                            soundType = VOICE_CHEER
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_4) then
                            soundType = VOICE_LEAD
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_5) then
                            soundType = VOICE_GO
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_6) then
                            soundType = VOICE_READY
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_7) then
                            soundType = VOICE_WARN
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_8) then
                            soundType = VOICE_QUESTION
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        elseif input.WasKeyPressed(KEY_9) then
                            soundType = VOICE_ANSWER
                            if activeWeapon:IsValid() then
                                input.SelectWeapon(activeWeapon)
                            end
                        end

                        if soundType then
                            net.Start("EmitNetworkedVoiceLine")
                            net.WriteUInt(soundType, 4)
                            net.WriteBool(true)
                            net.SendToServer()

                            LocalPlayer().VoiceMenu = false
                            BlockSwitch()
                        end
                    else
                        LocalPlayer().VoiceMenu = false
                        input.SelectWeapon(LocalPlayer():GetActiveWeapon())
                    end
                end
            end

            local wep = LocalPlayer():GetActiveWeapon()
            if IsValid(wep) then
                if wep:GetClass() == "weapon_riotshield_ow" then
                    local viewAngle = cmd:GetViewAngles()
                    if viewAngle.x > 25 then
                        viewAngle.x = 25
                    end
                    cmd:SetViewAngles(viewAngle)

                    IsDroppingRoleWeapon(cmd, wep)
                elseif wep:GetClass() == "weapon_medpack_ow" then
                    IsDroppingRoleWeapon(cmd, wep)
                end
            end
            SetKeyState(IN_RELOAD, cmd:KeyDown(IN_RELOAD))
        elseif LocalPlayer():Team() == TEAM_REBELS && !LocalPlayer():Alive() then
            LocalPlayer().VoiceMenu = false
        elseif LocalPlayer():Team() == TEAM_CONNECTING || LocalPlayer():Team() == TEAM_SPECTATOR then
            local spectating = LocalPlayer():GetObserverTarget()
            if !spectating:IsPlayer() && !spectating:IsNPC() then
                cmd:SetViewAngles(GAMEMODE.Cameras.spectator.ang)
            end
        elseif LocalPlayer():Team() == TEAM_COMBINE then
            cmd:RemoveKey(IN_USE)
            cmd:RemoveKey(IN_ATTACK2)

            LocalPlayer().JumpCooldown = LocalPlayer().JumpCooldown || CurTime()
             if LocalPlayer().JumpCooldown > CurTime() then
                cmd:RemoveKey(IN_JUMP)
            elseif cmd:KeyDown(IN_JUMP) && !LocalPlayer():IsOnGround() then
                LocalPlayer().JumpCooldown = CurTime() + 5
            end
        end
    end
end