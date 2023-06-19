local lastHealth = 100
local startGlowHealth = 0

local lastWeapon = 0
local lastAmmo = 0
local startGlowAmmo = 0
local lastSecondary = 0
local startGlowSecondary = 0
local startGlowBackground = 0
local ammoOffset = 0
local ammoWidth = 297
local ammoSpeed = 3

local glowLength = 2

local function DrawHealth()
    if LocalPlayer():Health() != lastHealth then
        lastHealth = LocalPlayer():Health()
        startGlowHealth = CurTime()
    end

    local alpha = math.max(0, (glowLength - (CurTime() - startGlowHealth)) * 200)
    local health = math.max(LocalPlayer():Health(), 0)

    draw.RoundedBox(8, 37 * hudScale, ScrH() - (108 * hudScale), 229 * hudScale, 81 * hudScale, Color(0, 0, 0, 75))

    if health < 20 then
        draw.SimpleText("#Valve_Hud_HEALTH", "Overwatch.VerdanaBold", 54 * hudScale, ScrH() - (53 * hudScale), Color(200, 0, 0, 200), _, TEXT_ALIGN_CENTER)
        draw.SimpleText(health, "Overwatch.Number", 149 * hudScale, ScrH() - (69 * hudScale), Color(200, 0, 0, 200), _, TEXT_ALIGN_CENTER)
        draw.SimpleText(health, "Overwatch.NumberGlow", 149 * hudScale, ScrH() - (69 * hudScale), Color(200, 0, 0, alpha), _, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("#Valve_Hud_HEALTH", "Overwatch.VerdanaBold", 54 * hudScale, ScrH() - (53 * hudScale), Color(255, 236, 12, 200), _, TEXT_ALIGN_CENTER)
        draw.SimpleText(health, "Overwatch.Number", 149 * hudScale, ScrH() - (69 * hudScale), Color(255, 240, 40, 200), _, TEXT_ALIGN_CENTER)
        draw.SimpleText(health, "Overwatch.NumberGlow", 149 * hudScale, ScrH() - (69 * hudScale), Color(255, 240, 40, alpha), _, TEXT_ALIGN_CENTER)
    end
end

local function DrawRole()
    local drawRole = false
    local role
    if LocalPlayer():HasWeapon("weapon_riotshield_ow") then
        drawRole = true
        role = "defender"
    elseif LocalPlayer():HasWeapon("weapon_medpack_ow") then
        drawRole = true
        role = "medic"
    end

    if drawRole then
        draw.RoundedBox(8, 37 * hudScale, ScrH() - (183 * hudScale), 229 * hudScale, 64 * hudScale, Color(0, 0, 0, 75))
        draw.SimpleText(string.upper(role), "Overwatch.VerdanaBold", 232 * hudScale, ScrH() - (151 * hudScale), Color(255, 236, 12, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.SetMaterial(GAMEMODE.Textures["hud_" .. role])
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawTexturedRect(37 * hudScale, ScrH() - (183 * hudScale), 64 * hudScale, 64 * hudScale)
    end
end

local function DrawAmmo()
    local weapon = LocalPlayer():GetActiveWeapon()
    local desiredOffset = 0
    local desiredWidth = 297
    if IsValid(weapon) then
        local clip = weapon:Clip1()
        local ammoType = weapon:GetPrimaryAmmoType()
        local ammo = LocalPlayer():GetAmmoCount(ammoType)
        local secondary = -1

        if weapon:GetSecondaryAmmoType() >= 0 then
            secondary = LocalPlayer():GetAmmoCount(weapon:GetSecondaryAmmoType())
        end

        if clip >= 0 || ammoType >= 0 then
            if  (clip == -1 && ammoType >= 0) ||
                (clip >= 0 && ammoType == -1) then
                desiredWidth = 225
                desiredOffset = -72
            elseif secondary >= 0 then
                desiredOffset = 162
            else
                desiredOffset = 0
                desiredWidth = 297
            end

            if weapon != lastWeapon then
                lastWeapon = weapon
                startGlowBackground = CurTime()
            end

            if clip != lastAmmo && clip >= 0 then
                lastAmmo = clip
                startGlowAmmo = CurTime()
            elseif (clip == -1 && ammoType >= 0) && ammo != lastAmmo then
                lastAmmo = ammo
                startGlowAmmo = CurTime()
            end

            local color = math.max(0, (1 - (CurTime() - startGlowBackground)) * 255)
            local alpha = math.max(0, (glowLength - (CurTime() - startGlowAmmo)) * 200)
            draw.RoundedBox(8, ScrW() - ((337 + ammoOffset) * hudScale), ScrH() - (108 * hudScale), ammoWidth * hudScale, 81 * hudScale, Color(color, color, 0, 75))

            if desiredWidth == 225 then
                local counter = math.max(clip, ammo)

                if counter > 0 then
                    draw.SimpleText("#Valve_Hud_AMMO", "Overwatch.VerdanaBold", ScrW() - ((320 + ammoOffset) * hudScale), ScrH() - (53 * hudScale), Color(255, 236, 12, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(counter, "Overwatch.Number", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(counter, "Overwatch.NumberGlow", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, alpha), _, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("#Valve_Hud_AMMO", "Overwatch.VerdanaBold", ScrW() - ((320 + ammoOffset) * hudScale), ScrH() - (53 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(counter, "Overwatch.Number", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(counter, "Overwatch.NumberGlow", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, alpha), _, TEXT_ALIGN_CENTER)
                end
            else
                if clip > 0 then
                    draw.SimpleText("#Valve_Hud_AMMO", "Overwatch.VerdanaBold", ScrW() - ((320 + ammoOffset) * hudScale), ScrH() - (53 * hudScale), Color(255, 236, 12, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(clip, "Overwatch.Number", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(clip, "Overwatch.NumberGlow", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, alpha), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(ammo, "Overwatch.NumberSmall", ScrW() - ((117 + ammoOffset) * hudScale), ScrH() - (54 * hudScale), Color(255, 240, 25, 200), _, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("#Valve_Hud_AMMO", "Overwatch.VerdanaBold", ScrW() - ((320 + ammoOffset) * hudScale), ScrH() - (53 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(clip, "Overwatch.Number", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(clip, "Overwatch.NumberGlow", ScrW() - ((247 + ammoOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, alpha), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(ammo, "Overwatch.NumberSmall", ScrW() - ((117 + ammoOffset) * hudScale), ScrH() - (54 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                end
            end

            if secondary >= 0 then
                if secondary != lastSecondary then
                    lastSecondary = secondary
                    startGlowSecondary = CurTime()
                end

                alpha = math.max(0, (glowLength - (CurTime() - startGlowSecondary)) * 200)
                draw.RoundedBox(8, ScrW() - ((22 + desiredOffset) * hudScale), ScrH() - (108 * hudScale), desiredOffset * hudScale, 81 * hudScale, Color(color, color, 0, 75))

                if secondary > 0 then
                    draw.SimpleText("#Valve_Hud_AMMO_ALT", "Overwatch.VerdanaBold", ScrW() - ((4 + desiredOffset) * hudScale), ScrH() - (49 * hudScale), Color(255, 236, 12, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(secondary, "Overwatch.Number", ScrW() - ((-36 + desiredOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(secondary, "Overwatch.NumberGlow", ScrW() - ((-36 + desiredOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 240, 40, alpha), _, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("#Valve_Hud_AMMO_ALT", "Overwatch.VerdanaBold", ScrW() - ((4 + desiredOffset) * hudScale), ScrH() - (49 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(secondary, "Overwatch.Number", ScrW() - ((-36 + desiredOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, 200), _, TEXT_ALIGN_CENTER)
                    draw.SimpleText(secondary, "Overwatch.NumberGlow", ScrW() - ((-36 + desiredOffset) * hudScale), ScrH() - (69 * hudScale), Color(255, 0, 0, alpha), _, TEXT_ALIGN_CENTER)
                end
            end
        end

        local speed = ammoSpeed * math.Round(60 / (1 / RealFrameTime()), 1)

        if desiredOffset > ammoOffset then
            ammoOffset = ammoOffset + speed;
        elseif desiredOffset < ammoOffset then
            ammoOffset = ammoOffset - speed;
        end

        if desiredWidth > ammoWidth then
            ammoWidth = ammoWidth + speed;
        elseif desiredWidth < ammoWidth then
            ammoWidth = ammoWidth - speed;
        end

        if math.abs(desiredOffset - ammoOffset) < speed then
            ammoOffset = desiredOffset
        end

        if math.abs(desiredWidth - ammoWidth) < speed then
            ammoWidth = desiredWidth
        end
    end
end

local function RetrieveObjectives()
    local visible = {}
    local objectives = {}
    local longestObjective = 0
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "game_tasklist_ow" && IsValid(ent) then
            if ent:GetVisible() then
                local playerTeam = LocalPlayer():Team()
                if LocalPlayer():Team() == TEAM_COMBINE then
                    playerTeam = TEAM_OVERWATCH
                elseif LocalPlayer():Team() == TEAM_SPECTATOR then
                    playerTeam = TEAM_REBELS
                end

                if ent:GetTeam() == playerTeam || ent:GetTeam() == 4 then
                    local task = {}
                    task.Count = ent:GetCount()
                    task.MaxCount = ent:GetMaxCount()
                    task.TaskMessage = ent:GetTask()
                    task.Priority = ent:GetPriority()
                    task.Flash = ent:GetFlash()
                    task.Entity = ent
                    table.insert(objectives, task)
                end
            end
        end
    end

    if #objectives > 0 then
        table.sort(objectives, function(a, b) return a.Priority > b.Priority end)

        for _, task in ipairs(objectives) do
            local count = task.MaxCount
            local taskMessage = task.TaskMessage
            local ent = task.Entity

            if count > 1 then
                taskMessage = taskMessage .. " (" .. task.Count .. "/" .. count .. ")"
            end

            local data = {}
            data.Message = taskMessage
            data.Color = ent:GetColor()
            if data.Color.a > 0 then
                table.insert(visible, data)
            end
        end

        surface.SetFont("Overwatch.Objectives")
        for _, task in ipairs(visible) do
            if surface.GetTextSize(task.Message) > longestObjective then
                longestObjective = surface.GetTextSize(task.Message)
            end
        end
    end
    return visible, longestObjective
end

local function DrawObjectives()
    surface.SetFont("Overwatch.VerdanaBold")
    local minLength = surface.GetTextSize("Objectives:")
    local objectives, longestObjective = RetrieveObjectives()
    local width = math.max(minLength, longestObjective) + (19 * hudScale)
    local height = 32 + (#objectives * 20)
    local offset = width + (40 * hudScale)

    if #objectives > 0 then
        draw.RoundedBox(8, ScrW() - offset, 36 * hudScale, width, height * hudScale, Color(0, 0, 0, 75))
        draw.SimpleText("Objectives:", "Overwatch.VerdanaBold", ScrW() - ((-9 * hudScale) + offset), 51 * hudScale, team.GetColor(TEAM_REBELS), _, TEXT_ALIGN_CENTER)

        for k, task in ipairs(objectives) do
            draw.SimpleText(task.Message, "Overwatch.Objectives", ScrW() - ((-10 * hudScale) + offset), (51 + (20 * k)) * hudScale, task.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

local function DrawTimer()
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "game_hudtimer_ow" && IsValid(ent) then
            if ent:GetEnabled() then
                local timerLabel = ent:GetRebelText()
                if LocalPlayer():Team() == TEAM_OVERWATCH || LocalPlayer():Team() == TEAM_COMBINE then
                    timerLabel = ent:GetOverwatchText()
                end

                surface.SetFont("Overwatch.Verdana")
                local width = surface.GetTextSize(timerLabel) + (20 * hudScale)
                local height = 60
                local offset = width / 2
                local time = ent:GetTimeLeft()

                draw.RoundedBox(8, (ScrW() / 2) - offset, 36 * hudScale, width, height * hudScale, Color(0, 0, 0, 75))
                draw.SimpleText(timerLabel, "Overwatch.Verdana", ScrW() / 2, 51 * hudScale, Color(255, 236, 12, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(SecondsToTimer(time), "Overwatch.Timer", ScrW() / 2, 75 * hudScale, Color(255, 236, 12, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(SecondsToTimer(time), "Overwatch.TimerGlow", ScrW() / 2, 75 * hudScale, Color(255, 236, 12, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                break
            end
        end
    end
end

local function DrawRadioMenu(items, title)
    local longestItem = 0
    surface.SetFont("Overwatch.VerdanaBold")

    for k, v in ipairs(items) do
        if surface.GetTextSize(k .. ". " .. v) > longestItem then
            longestItem = surface.GetTextSize(k .. ". " .. v)
        end
    end

    if title != nil && surface.GetTextSize(title) > longestItem then
        longestItem = surface.GetTextSize(title)
    end

    local count = #items
    if title != nil then
        count = count + 1
    end

    local width = longestItem + (20 * hudScale)
    local height = (count * 20) + (12 * hudScale)
    local offset = height / 2
    draw.RoundedBox(8, 37 * hudScale, (ScrH() / 2) - offset, width, height, Color(0, 0, 0, 75))

    local i = count - #items
    if title != nil then
        draw.SimpleText(title, "Overwatch.VerdanaBold", 46 * hudScale, (ScrH() / 2) - (offset - 15), Color(234, 209, 175, 255), _, TEXT_ALIGN_CENTER)
    end

    for k, v in pairs(items) do
        draw.SimpleText(math.fmod(k, 10) .. ". " .. v, "Overwatch.VerdanaBold", 46 * hudScale, (ScrH() / 2) - ((-20 * i) + offset - 15), Color(234, 209, 175, 255), _, TEXT_ALIGN_CENTER)
        i = i + 1
    end
end

local function DrawRoundEnd()
    local text = "No one has won, it's a draw."
    if GAMEMODE.winner == TEAM_OVERWATCH then
        text = "Overwatch has defeated the Resistance."
    elseif GAMEMODE.winner == TEAM_REBELS then
        text = "The Resistance has won the fight."
    end

    local maxrounds = GAMEMODE.ConVars.maxrounds.client
    local timelimit = GAMEMODE.ConVars.timelimit.client
    if  (maxrounds > 0 && GAMEMODE.ConVars.maxrounds.played >= maxrounds) ||
        (timelimit > 0 && CurTime() >= GAMEMODE.ConVars.timelimit.start + timelimit) then
        local nextMap
        if GAMEMODE.NextMap == nil then
            nextMap = SanitizeMapName(game.GetMap())
        else
            nextMap = SanitizeMapName(GAMEMODE.NextMap)
        end
        nextMap = "Changing map to: " .. nextMap

        surface.SetFont("Overwatch.VerdanaBold")
        local width = math.max(surface.GetTextSize(text), surface.GetTextSize(nextMap)) + (20 * hudScale)
        local height = 32 + (20 * hudScale)
        local offsetX = width / 2
        local offsetY = 30 / 2
        draw.RoundedBox(8, (ScrW() / 2) - offsetX, (ScrH() / 2) - offsetY, width, height, Color(0, 0, 0, 75))
        draw.SimpleText(text, "Overwatch.VerdanaBold", ScrW() / 2, ScrH() / 2, team.GetColor(TEAM_REBELS), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(nextMap, "Overwatch.VerdanaBold", ScrW() / 2, (ScrH() / 2) + 10, team.GetColor(TEAM_REBELS), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    else
        surface.SetFont("Overwatch.VerdanaBold")
        local width = surface.GetTextSize(text) + (20 * hudScale)
        local height = 12 + (20 * hudScale)
        local offsetX = width / 2
        local offsetY = height / 2
        draw.RoundedBox(8, (ScrW() / 2) - offsetX, (ScrH() / 2) - offsetY, width, height, Color(0, 0, 0, 75))
        draw.SimpleText(text, "Overwatch.VerdanaBold", ScrW() / 2, ScrH() / 2, team.GetColor(TEAM_REBELS), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function DrawMisc()
    if LocalPlayer().menuOpen then
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, ScrW(), 100)
        surface.DrawRect(0, ScrH() - 100, ScrW(), 100)
    elseif LocalPlayer():Team() != TEAM_OVERWATCH && LocalPlayer():Alive() then
        hook.Run("HUDDrawTargetID")
    end

    if GetRoundState() == ROUND_PREPARING && #player.GetAll() > 1 && GAMEMODE.countDown != nil then
        draw.SimpleText("Selecting Overwatch in ".. GAMEMODE.countDown .. " seconds", "Overwatch.Menu", ScrW() / 2, ScrH() - 52, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif GetRoundState() == ROUND_SETUP && #player.GetAll() > 1 && GAMEMODE.countDown != nil then
        draw.SimpleText("Round starting in ".. GAMEMODE.countDown .. " seconds", "Overwatch.Menu", ScrW() / 2, ScrH() - 52, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif #player.GetAll() == 1 then
        draw.SimpleText("Waiting for someone to join a team", "Overwatch.Menu", ScrW() / 2, ScrH() - 52, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function DrawCrosshairMessage(text, color)
    color = color || team.GetColor(TEAM_REBELS)

    surface.SetFont("Overwatch.VerdanaBold")
    local width = surface.GetTextSize(text) + (20 * hudScale)
    local height = 12 + (20 * hudScale)
    local offsetX = width / 2
    local offsetY = (height / 2) - 40
    draw.RoundedBox(8, (ScrW() / 2) - offsetX, (ScrH() / 2) - offsetY, width, height, Color(0, 0, 0, 75))
    draw.SimpleText(text, "Overwatch.VerdanaBold", ScrW() / 2, (ScrH() / 2) + 39, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawSpectator()
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, ScrW(), 100)
    surface.DrawRect(0, ScrH() - 100, ScrW(), 100)

    local target = LocalPlayer():GetObserverTarget()
    if target:IsPlayer() then    
        draw.SimpleText(target:Nick() .. " (" .. math.max(target:Health(), 0) .. ")", "Overwatch.Menu", ScrW() / 2, ScrH() - 52, team.GetColor(TEAM_REBELS), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        --LocalPlayer():GetObserverMode()
    elseif target:IsNPC() then        
        local text = "There are currently too many Combine players"
        if team.NumPlayers(TEAM_COMBINE) < math.max(math.floor(team.NumPlayers(TEAM_REBELS) / 3), 1) then
            text = "Press " .. input.LookupBinding("+jump", true) .. " to control this NPC"

            LocalPlayer().ControlCooldown = LocalPlayer().ControlCooldown || 0
            if LocalPlayer().ControlCooldown > CurTime() then
                text = "You must wait " .. math.Round(LocalPlayer().ControlCooldown - CurTime()) .. " seconds"
            end
        end

        DrawCrosshairMessage(text)
    elseif LocalPlayer():Team() == TEAM_SPECTATOR then
        local text = "You can join a team when the round ends"
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "game_settings_ow" then
                if ent:GetNewSpawn() then
                    text = ""
                end
                break
            end
        end
        draw.SimpleText(text, "Overwatch.Menu", ScrW() / 2, ScrH() - 52, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function DrawDead()
    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "game_respawn_ow" && IsValid(ent) then
            local activeMessage = ent:GetMessage()
            local text = ent:GetNWString("message0" .. activeMessage)
            DrawCrosshairMessage(text)
            return
        end
    end

    LocalPlayer().RespawnTime = LocalPlayer().RespawnTime || 0
    if LocalPlayer().RespawnTime > CurTime() then
        local text = ""
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "game_settings_ow" then
                if ent:GetDeadRespawn() then
                    text = "Respawning in " .. LocalPlayer().RespawnTime - math.Round(CurTime()) .. " seconds."
                end
                break
            end
        end
        DrawCrosshairMessage(text)
        return
    end

    DrawCrosshairMessage("You are dead. Wait to be revived.")
end

local function DrawRevive()
    local ent = LocalPlayer().ReviveEntity
    if IsValid(ent) then
        if ent:GetClass() == "prop_rebel_revive" then
            local percentage = ent:GetProgress()
            if percentage > 0 then
                local text = "You are being revived."
                if LocalPlayer():Alive() then
                    text = "You are reviving " .. ent:GetPlayer():Nick() .. "."
                end

                surface.SetFont("Overwatch.VerdanaBold")
                local width = 600 * hudScale
                local height = 20 + (20 * hudScale) + (30 * hudScale)
                local offsetX = width / 2
                local offsetY = (height / 2) - 40
                draw.RoundedBox(8, (ScrW() / 2) - offsetX, ((ScrH() / 3) * 2) - offsetY, width, height, Color(0, 0, 0, 75))
                draw.RoundedBox(8, (ScrW() / 2) - (offsetX - 10), ((ScrH() / 3) * 2) - (offsetY - 20 - (10 * hudScale)), (width - 20), 30 * hudScale, Color(0, 0, 0, 125))
                draw.RoundedBox(8, (ScrW() / 2) - (offsetX - 10), ((ScrH() / 3) * 2) - (offsetY - 20 - (10 * hudScale)), (width - 20) * percentage, 30 * hudScale, team.GetColor(TEAM_REBELS))
                draw.SimpleText(text, "Overwatch.VerdanaBold", ScrW() / 2 - (offsetX - 10), ((ScrH() / 3) * 2) - (offsetY - 5), team.GetColor(TEAM_REBELS))
            end
        end
    end
end

local function DrawCombineOrder()
    if IsValid(LocalPlayer():GetNWEntity("Target")) && LocalPlayer():GetNWEntity("Target") != LocalPlayer() then
        local point = LocalPlayer():GetNWEntity("Target"):GetPos() + Vector(0, 0, 96)
        local data2D = point:ToScreen()

        if data2D.visible then
            draw.SimpleTextOutlined("Eliminate the target","Overwatch.Menu", data2D.x, data2D.y - 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

            surface.SetMaterial(GAMEMODE.Textures["arrow"])
            surface.DrawTexturedRect(data2D.x - 8, data2D.y, 16, 16)
        end
    elseif LocalPlayer():GetNWVector("MoveTo", Vector(16384, 16384, 16384)) != Vector(16384, 16384, 16384) then
        local point = LocalPlayer():GetNWVector("MoveTo") + Vector(0, 0, 96)
        local data2D = point:ToScreen()

        if data2D.visible then
            local order = "Assault this position"
            if !LocalPlayer():GetNWBool("ChaseTarget") then
                order = "Defend this position"
            end

            draw.SimpleTextOutlined(order,"Overwatch.Menu", data2D.x, data2D.y - 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

            surface.SetMaterial(GAMEMODE.Textures["arrow"])
            surface.DrawTexturedRect(data2D.x - 8, data2D.y, 16, 16)
        end
    end
end


local function DrawCombine()
    DrawCombineOrder()

    if LocalPlayer():Health() != lastHealth then
        lastHealth = LocalPlayer():Health()
        startGlowHealth = CurTime()
    end

    local alpha = math.max(0, (glowLength - (CurTime() - startGlowHealth)) * 200)
    local health = math.Round((LocalPlayer():Health() / LocalPlayer():GetNWInt("MaxHealth") * 100))
    health = math.max(health, 0)

    draw.RoundedBox(8, 37 * hudScale, ScrH() - (108 * hudScale), 229 * hudScale, 81 * hudScale, Color(0, 0, 0, 75))
    draw.SimpleText("#Valve_Hud_HEALTH", "Overwatch.VerdanaBold", 54 * hudScale, ScrH() - (53 * hudScale), ColorAlpha(team.GetColor(TEAM_COMBINE), 200), _, TEXT_ALIGN_CENTER)
    draw.SimpleText(health, "Overwatch.Number", 149 * hudScale, ScrH() - (69 * hudScale), ColorAlpha(team.GetColor(TEAM_COMBINE), 200), _, TEXT_ALIGN_CENTER)
    draw.SimpleText(health, "Overwatch.NumberGlow", 149 * hudScale, ScrH() - (69 * hudScale), ColorAlpha(team.GetColor(TEAM_COMBINE), alpha), _, TEXT_ALIGN_CENTER)
end

local function DrawMiniMap()
    if GAMEMODE.Overview == nil then
        return
    end

    local map = {}
    map.zoom = 2.5
    map.size = ScrH() / 4
    map.offsetX = 37 * hudScale
    map.offsetY = 36 * hudScale

    if LocalPlayer().MiniMapZoom then
        map.size = ScrH() - 200
        map.zoom = 1

        map.offsetX = (ScrW() - map.size) / 2
        map.offsetY = 100

        if map.size < 1024 then
            map.zoom = map.size / 1024
        end
    end

    render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()

	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    
    surface.DrawRect(map.offsetX, map.offsetY, map.size, map.size)

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)
    
    surface.SetDrawColor(0, 0, 0, 75)
    surface.DrawRect(map.offsetX, map.offsetY, map.size, map.size)

    local pos = LocalPlayer():GetPos()
    map.x = pos.x - GAMEMODE.Overview.x
    map.y = GAMEMODE.Overview.y - pos.y

    local scale = GAMEMODE.Overview.scale * (1024 / map.size)
    map.x = (map.x / scale)
    map.y = (map.y / scale)

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(GAMEMODE.Overview.material)

    map.topX = map.offsetX - (map.x * map.zoom) + (map.size / 2)
    map.topY = map.offsetY - (map.y * map.zoom) + (map.size / 2)

    if LocalPlayer().MiniMapZoom then
        map.topX = map.offsetX
        map.topY = map.offsetY

        if map.zoom < 1 then
            map.zoom = 1
        end
    end

    surface.DrawTexturedRect(map.topX, map.topY, map.size * map.zoom, map.size * map.zoom)

    local icons = {
        weapons = {},
        players = {},
        objectives = {}
    }

    for _, ent in pairs(ents.GetAll()) do
        if (ent:GetClass() == "weapon_medpack_ow" || ent:GetClass() == "weapon_riotshield_ow") && !IsValid(ent:GetOwner()) then
            data = {}

            pos = ent:GetPos()
            data.x = pos.x - GAMEMODE.Overview.x
            data.y = GAMEMODE.Overview.y - pos.y

            data.x = (data.x / scale)
            data.y = (data.y / scale)

            data.icon = "medpack"
            if ent:GetClass() == "weapon_riotshield_ow" then
                data.icon = "riotshield"
            end

            table.insert(icons.weapons, data)
        elseif ent:IsPlayer() then
            if ent != LocalPlayer() && ent:Team() == LocalPlayer():Team() then
                data = {}
                pos = ent:GetPos()

                data.icon = "player"
                if !ent:Alive() then
                    data.icon = "revive"
                    revive = ent:GetNWEntity("Revive")
                    if !revive:IsValid() then continue end
                    pos = revive:GetPos()
                elseif IsValid(ent:GetWeapon("weapon_medpack_ow")) then
                    data.icon = "medic"
                elseif IsValid(ent:GetWeapon("weapon_riotshield_ow")) then
                    data.icon = "defender"
                end

                data.x = pos.x - GAMEMODE.Overview.x
                data.y = GAMEMODE.Overview.y - pos.y

                data.x = (data.x / scale)
                data.y = (data.y / scale)

                table.insert(icons.players, data)
            end
        elseif ent:GetClass() == "env_indicator_ow" && IsValid(ent) then
            if ent:GetEnabled() then
                if (ent:GetTeam() == 1 && LocalPlayer():Team() != TEAM_REBELS) || (ent:GetTeam() == 2 && LocalPlayer():Team() != TEAM_OVERWATCH && LocalPlayer():Team() != TEAM_COMBINE) then
                    continue
                end

                data = {}

                pos = ent:GetPos()
                data.x = pos.x - GAMEMODE.Overview.x
                data.y = GAMEMODE.Overview.y - pos.y

                data.x = (data.x / scale)
                data.y = (data.y / scale)

                data.icon = ent:GetOverwatchIcon()
                if LocalPlayer():Team() == TEAM_REBELS then
                    data.icon = ent:GetRebelIcon()
                end

                table.insert(icons.objectives, data)
            end
        end
    end

    for _, data in ipairs(icons.weapons) do
        surface.SetMaterial(GAMEMODE.Textures[data.icon])
        surface.DrawTexturedRect(map.topX + (data.x * map.zoom) - 10, map.topY + (data.y * map.zoom) - 10, 20, 20)
    end

    for _, data in ipairs(icons.players) do
        surface.SetMaterial(GAMEMODE.Textures[data.icon])
        surface.DrawTexturedRect(map.topX + (data.x * map.zoom) - 10, map.topY + (data.y * map.zoom) - 10, 20, 20)
    end

    for _, data in ipairs(icons.objectives) do
        surface.SetMaterial(Material(data.icon))
        surface.DrawTexturedRect(map.topX + (data.x * map.zoom) - 10, map.topY + (data.y * map.zoom) - 10, 20, 20)
    end

    surface.SetDrawColor(255, 0, 0)
    if LocalPlayer().MiniMapZoom then
        data = {}

        pos = LocalPlayer():GetPos()
        data.x = pos.x - GAMEMODE.Overview.x
        data.y = GAMEMODE.Overview.y - pos.y

        data.x = (data.x / scale)
        data.y = (data.y / scale)

        surface.DrawRect(map.topX + (data.x * map.zoom) - 3, map.topY + (data.y * map.zoom) - 3, 6, 6)
    else
        surface.DrawRect(map.offsetX + (map.size / 2) - 3, map.offsetY + (map.size / 2) - 3, 6, 6)
    end

    render.SetStencilEnable(false)
end

function DrawHL2Hud()
    if !LocalPlayer().menuOpen then
        if GetRoundState() == ROUND_ENDED then
            DrawRoundEnd()
        else
            if LocalPlayer():Team() == TEAM_REBELS then
                if LocalPlayer():Alive() then
                    DrawHealth()
                    DrawRole()
                    DrawAmmo()
                    DrawMiniMap()

                    if LocalPlayer().VoiceMenu then
                        local items = {}
                        table.insert(items, "Help")
                        table.insert(items, "Medic")
                        table.insert(items, "Cheer")
                        table.insert(items, "Lead the way")
                        table.insert(items, "Let's Go")
                        table.insert(items, "Ready")
                        table.insert(items, "Warn")
                        table.insert(items, "Question")
                        table.insert(items, "Answer")
                        table.insert(items, "Close")
                        DrawRadioMenu(items)
                    end

                    if LocalPlayer().VoteMenu then
                        local items = {}
                        for i = 1, #GAMEMODE.Nominated do
                            table.insert(items, SanitizeMapName(GAMEMODE.Nominated[i]))
                        end
                        DrawRadioMenu(items, "Vote for the next map")
                    end
                else
                    DrawSpectator()
                    DrawDead()
                end
                DrawRevive()
            elseif LocalPlayer():Team() == TEAM_SPECTATOR then
                DrawSpectator()
            elseif LocalPlayer():Team() == TEAM_COMBINE then
                DrawCombine()
            end

            DrawObjectives()
            DrawTimer()
        end
    end
    DrawMisc()
end

local function DrawIndicator(ent)
    if ent:GetEnabled() then
        if (ent:GetTeam() == 1 && LocalPlayer():Team() != TEAM_REBELS) || (ent:GetTeam() == 2 && LocalPlayer():Team() != TEAM_OVERWATCH && LocalPlayer():Team() != TEAM_COMBINE) then
            return
        end

        local entMaterial = ent:GetOverwatchIcon()
        local indicatorLabel = ent:GetOverwatchText()
        if LocalPlayer():Team() == TEAM_REBELS then
            entMaterial = ent:GetRebelIcon()
            indicatorLabel = ent:GetRebelText()
        end

        if #entMaterial >= 1 then
            local point = ent:GetPos()
            local data2D = point:ToScreen()
            local size = 64

            local entData = {}
            entData["texture"] = entMaterial
            entData["position"] = point
            table.insert(objectiveData, entData)

            local x = data2D.x
            local y = data2D.y
            
            if LocalPlayer():Team() == TEAM_OVERWATCH then
                if data2D.x < 60 then
                    x = 60
                elseif data2D.x > ScrW() - 60 then
                    x = ScrW() - 60
                end

                if data2D.y < 36 then
                    y = 36
                elseif data2D.y > ScrH() - 70 - 178 then
                    y = ScrH() - 70 - 178
                end
            end

            surface.SetDrawColor(255, 255, 255, 200)
            surface.SetMaterial(Material(entMaterial))
            surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)

            if ent:GetShowProgress() then
                surface.SetDrawColor(75, 75, 75, 200)
                surface.DrawRect(x - 40, y + 54, 80, 10)

                local r = 255
                local g = 255
                local progress = ent:GetProgress()
                if progress <= 0.5 then
                    g = 255 * (progress * 2)
                else
                    r = 255 * ((progress - 1) * -2)
                end

                local progressColor = Color(r, g, 0, 200)

                surface.SetDrawColor(progressColor)
                surface.DrawRect(x - 40, y + 54, 80 * progress, 10)
                draw.DrawText(indicatorLabel, "Overwatch.Indicator", x, y + 36, progressColor, TEXT_ALIGN_CENTER)
            else
                draw.DrawText(indicatorLabel, "Overwatch.Indicator", x, y + 36, Color(255, 0, 0, 200), TEXT_ALIGN_CENTER)
            end
        end
    end
end

local function DrawHint(ent, prop)
    local origin = ent
    if IsValid(prop) then
        origin = prop
    end
    local entMaterial = ent:GetIcon()
    if ent:GetEnabled() && (!ent:GetTemplate() || (ent:GetTemplate() && IsValid(prop))) then
        if ent:GetTeam() == 1 || LocalPlayer():Team() == ent:GetTeam() then
            if LocalPlayer():IsLineOfSightClear(origin) || !ent:GetRequireLOS() then
                if (LocalPlayer():GetPos():DistToSqr(origin:GetPos()) <= math.pow(ent:GetRange(), 2) && LocalPlayer():Team() == TEAM_REBELS) || LocalPlayer():Team() == TEAM_OVERWATCH then
                    local data2D = origin:GetPos():ToScreen()
                    local size = 64
                    if !IsIconOnScreen(data2D, size) then return end
                    if !data2D.visible then return end

                    local color = string.ToColor(ent:GetColors())
                    if #entMaterial >= 1 then
                        surface.SetDrawColor(color)
                        surface.SetMaterial(Material(entMaterial))
                        surface.DrawTexturedRect(data2D.x - size / 2, data2D.y - 64 - size / 2, size, size)
                    end

                    draw.DrawText(ent:GetText(), "Overwatch.Indicator", data2D.x, data2D.y - 36, color, TEXT_ALIGN_CENTER)

                    if ent:GetArrow() then
                        surface.SetMaterial(GAMEMODE.Textures["arrow"])
                        surface.DrawTexturedRect(data2D.x - 8, data2D.y - 22, 16, 16)
                    end
                end
            end
        end
    end
end

local function DrawPropHint(ent)
    if string.len(ent:GetHint()) != 0 then
        local hintEnt
        for _, hint in pairs(ents.GetAll()) do
            if hint:GetClass() == "env_hint_ow" && hint:GetTargetName() == ent:GetHint() then
                hintEnt = hint
                break
            end
        end

        if hintEnt != nil && IsValid(hintEnt) then
            DrawHint(hintEnt, ent)
        end
    end
end

function DrawWorldIcons()
    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "env_indicator_ow" && IsValid(ent) then
            DrawIndicator(ent)
        elseif ent:GetClass() == "env_hint_ow" && IsValid(ent) then
            DrawHint(ent)
        elseif ent:GetClass() == "prop_physics_multiplayer_ow" && IsValid(ent) then
            DrawPropHint(ent)
        end
    end
end

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
	
	local text = "ERROR"
	
	if trace.Entity:IsPlayer() && LocalPlayer():Team() == trace.Entity:Team() then
		text = trace.Entity:Nick()
	else
		return
    end
        
    DrawCrosshairMessage(text, team.GetColor(LocalPlayer():Team()))
end