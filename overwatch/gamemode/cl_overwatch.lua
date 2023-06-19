local mouse = {
    top = {
        x = 0,
        y = 0
    },
    bottom = {
        x = 0,
        y = 0
    }
}

local selectionArea = {
    top = {
        x = 0,
        y = 0
    },
    bottom = {
        x = 0,
        y = 0
    }
}

local singleUnit

local allNPCs = {}

local onClickData = {}
onClickData.scale = 0

local mapSize = ScrH() / 3
local offsetBar
local xTop
local yTop
local tooltip

local abilityCount
local abilityEnts = {}
local abilityButtons = {}
local buttonInfo = {}

local barHeight = 178

local function IsIconClickable(data2D, size)
    if !MouseOnObject(data2D.x, data2D.y, size) then return false end
    local x, y = input.GetCursorPos()
    if x <= mapSize && y >= ScrH() - mapSize then return false end
    if y >= ScrH() - barHeight then return false end
    return true
end

local function DrawWorldButton(ent)
    local entMaterial = ent:GetIcon()
    if #entMaterial == 0 then return end

    local data2D = ent:GetPos():ToScreen()
    local size = ent:GetButtonSize()
    if !IsIconOnScreen(data2D, size) then return end

    local colors = string.Explode("-", ent:GetColors())
    colors.cooldown = string.ToColor(colors[1])
    colors.disabled = string.ToColor(colors[2])
    colors.enabled = string.ToColor(colors[3])
    colors.mouseOver = string.ToColor(colors[4])

    surface.SetDrawColor(colors.enabled)
    if ent:GetEnabled() && GetUnitCount() < GetUnitCap() then
        if ent:GetCooldownEnd() <= CurTime() then
            if IsIconClickable(data2D, size) then
                surface.SetDrawColor(colors.mouseOver)
                handCursor = true
                if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                    net.Start("ClickGuiButton")
                    net.WriteEntity(ent)
                    net.SendToServer()
                    surface.PlaySound("ui/buttonclickrelease.wav")
                end
            end
        else
            surface.SetDrawColor(colors.cooldown)
            if IsIconClickable(data2D, size) && IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                surface.PlaySound("player/suit_denydevice.wav")
            end
        end
    else
        surface.SetDrawColor(colors.disabled)
        if IsIconClickable(data2D, size) && IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
            surface.PlaySound("player/suit_denydevice.wav")
        end
    end

    if IsIconClickable(data2D, size) then
        buttonInfo.Enabled = ent:GetEnabled()
        buttonInfo.Cooldown = ent:GetCooldownEnd()
        buttonInfo.Charges = ent:GetCharges()
        buttonInfo.Title = ent:GetTitle()
        buttonInfo.Text = ent:GetToolTip()
        if !MouseOnObject(data2D.x, data2D.y, size, previousKeyState.mouseX, previousKeyState.mouseY) then
            surface.PlaySound("ui/buttonrollover.wav")
        end
    end

    surface.SetMaterial(Material(entMaterial))
    surface.DrawTexturedRect(data2D.x - (size / 2), data2D.y - (size / 2), size, size)
end

local function DrawNPCMarker(ent)
    table.insert(allNPCs, ent)
    ent.Highlighted = false

    if orderType == ORDER_ATTACKMOVE && !showAttackMove then
        local point = ent:GetPos()
        local data2D = point:ToScreen()
        local size = 24

        if ent:GetClass() == "npc_strider" || ent:GetClass() == "npc_helicopter" then
            point:Add(Vector(0, 0, -64))
            data2D = point:ToScreen()
            size = 96
        end

        if selectionArea.top.x <= data2D.x && data2D.x <= selectionArea.bottom.x && selectionArea.top.y <= data2D.y && data2D.y <= selectionArea.bottom.y then
            if IsKeyReleased(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                ent.Selected = true
            elseif IsKeyHeld(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                ent.Highlighted = true
            end
        end

        local x, y = input.GetCursorPos()
        if !(x <= mapSize && y >= ScrH() - mapSize) && y < ScrH() - barHeight then
            if(MouseOnObject(data2D.x, data2D.y, size)) && !singleUnit then
                cursor = "cursor_select"
                singleUnit = true
                ent.Highlighted = true
                if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                    if LocalPlayer():KeyDown(IN_SPEED) then
                        ent.Selected = !ent.Selected
                    else
                        ent.Selected = true
                    end
                end
            elseif IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) && !LocalPlayer():KeyDown(IN_SPEED) then
                ent.Selected = false
            end
        end
    end

    if ent.Selected then
        table.insert(selectedNPCs, ent)
    end
end

local function LoopThroughEntities()
    singleUnit = false

    allNPCs = {}
    selectedNPCs = {}

    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "env_gmbutton_ow" && IsValid(ent) then
            DrawWorldButton(ent)
        elseif  (ent:IsNPC() && IsValid(ent) && !GAMEMODE.OverwatchNPCBlacklist[ent:GetClass()]) ||
                (ent:IsPlayer() && ent:Team() == TEAM_COMBINE) then
            DrawNPCMarker(ent)
        end
    end
end

local function TraceMouse()
    local ang = util.AimVector(LocalPlayer():EyeAngles(), LocalPlayer().fov, gui.MouseX(), gui.MouseY(), ScrW(), ScrH())
    local startPos = Vector()
    startPos:Set(OverwatchPos)
    local endPos = startPos + ang * 32768
    local tries = 1

    local td = {}
    td.start = startPos
    td.endpos = endPos
    td.mask = MASK_SOLID
    td.filter = function(ent)
        return !ent:GetNWBool("HideOverwatch")
    end

    table.Empty(traces)
    repeat
        tries = tries + 1

        local tr = util.TraceLine(td)
        table.insert(traces, {startPos = td.start, endPos = tr.HitPos})
        if tr.HitPos == endPos then break end
        if tr.HitPos.z < -16384 then break end
        td.start = tr.HitPos + ang * 1
    until tries >= 8
    if #traces > 1 then
        table.remove(traces, #traces)
    end
end

local function GetClosestNode(location)
    local closestDistance = 0
    local closestNode = 0
    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_GROUND] do
        local node = Vector()
        node:Set(GAMEMODE.Nodes[NODE_TYPE_GROUND][i])
        node.z = 0

        local pos = Vector()
        pos:Set(location)
        pos.z = 0

        local distance = node:DistToSqr(pos)
        if closestDistance == 0 || distance < closestDistance then
            closestDistance = distance
            closestNode = i
        end
    end

    if closestNode == 0 then return 0, 0, 0 end
    return closestNode, math.sqrt(closestDistance), math.abs(GAMEMODE.Nodes[NODE_TYPE_GROUND][closestNode].z - location.z)
end

local function GetOptimalOrderVector()
    TraceMouse()
    local target = Vector()
    local counter = 0
    local node, distance, height
    repeat
        local pos = traces[#traces - counter].endPos || Vector()
        node, distance, height = GetClosestNode(pos)
        if height < 384 then
            if distance < 128 && height > 32 && node > 0 then
                pos = GAMEMODE.Nodes[NODE_TYPE_GROUND][node]
            end
            target = pos
            break
        end
        target = Vector()
        counter = counter + 1
    until counter == #traces
    return target
end

local function GetClosestAirNode()
    local closestNode = 0
    local closestDistance = 0

    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_AIR] do
        local data2D = GAMEMODE.Nodes[NODE_TYPE_AIR][i]:ToScreen()

        local x, y = input.GetCursorPos()
        local vector = Vector(data2D.x, data2D.y, 0)
        local distance = vector:DistToSqr(Vector(x, y, 0))

        if distance < closestDistance || closestNode == 0 then
            closestNode = i
            closestDistance = distance
        end
    end

    return closestNode
end

local function GiveOrder(ply)
    if #selectedNPCs == 0 then return end

    local pos = GetOptimalOrderVector()
    local airNode = GAMEMODE.Nodes[NODE_TYPE_AIR][GetClosestAirNode()] || pos

    net.Start("MoveNPC")
    net.WriteInt(orderType, 3)
    net.WriteTable(selectedNPCs)
    net.WriteVector(pos)
    net.WriteVector(airNode)
    if ply != nil then
        net.WriteEntity(ply)
    end
    net.SendToServer()

    onClickData.x, onClickData.y = input.GetCursorPos()
    onClickData.scale = 48
    onClickData.texture = "onclick_attackmove"

    if orderType == ORDER_ATTACK then
        onClickData.texture = "onclick_attack"
    elseif orderType == ORDER_MOVE then
        onClickData.texture = "onclick_move"
    end

    orderType = ORDER_ATTACKMOVE
    showAttackMove = false
end

local function DrawOrder()
    if onClickData.scale > 0 then
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(GAMEMODE.Textures[onClickData.texture])
        surface.DrawTexturedRect(onClickData.x - (onClickData.scale / 2), onClickData.y - (onClickData.scale / 2), onClickData.scale, onClickData.scale)
        onClickData.scale = onClickData.scale - 3
    end
end

local function OrderUnits()
    local x, y = input.GetCursorPos()
    if x <= mapSize && y >= ScrH() - mapSize then return end
    if y >= ScrH() - barHeight then return end

    if IsKeyClicked(input.IsMouseDown(MOUSE_RIGHT), MOUSE_RIGHT) && (orderType == ORDER_ATTACKMOVE && !showAttackMove) then
        GiveOrder()
    elseif IsKeyClicked(input.IsMouseDown(MOUSE_RIGHT), MOUSE_RIGHT) then
        orderType = ORDER_ATTACKMOVE
        showAttackMove = false
    elseif orderType == ORDER_ATTACK then
        local target
        for _, ply in ipairs(player.GetAll()) do
            if (ply:Alive() && ply:Team() == TEAM_REBELS) then
                ply.Highlighted = false
                local data2D = ply:GetPos():ToScreen()
                local size = 64
                
                if !IsIconOnScreen(data2D, size) then return end

                if IsIconClickable(data2D, size) then
                    target = ply
                    if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
                        GiveOrder(ply)
                    elseif !input.IsMouseDown(MOUSE_LEFT) then
                        ply.Highlighted = true
                    end
                end
            end
        end

        if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
            if !IsValid(target) then
                surface.PlaySound("player/suit_denydevice.wav")
            end
        end
    elseif orderType == ORDER_STOP then
        net.Start("StopNPC")
        net.WriteTable(selectedNPCs)
        net.SendToServer()

        orderType = ORDER_ATTACKMOVE
        showAttackMove = false
    elseif IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
        if orderType == ORDER_ATTACKMOVE && showAttackMove then
            GiveOrder()
        elseif orderType == ORDER_MOVE then
            GiveOrder()
        end
    end
end

local function DrawSelectionBox()
    if !(orderType == ORDER_ATTACKMOVE && !showAttackMove) then return end

    if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
        mouse.top.x, mouse.top.y = input.GetCursorPos()
    elseif IsKeyHeld(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
        mouse.bottom.x, mouse.bottom.y = input.GetCursorPos()

        if mouse.top.x <= mouse.bottom.x then
            selectionArea.top.x = mouse.top.x
            selectionArea.bottom.x = mouse.bottom.x
        else
            selectionArea.top.x = mouse.bottom.x
            selectionArea.bottom.x = mouse.top.x
        end

        if mouse.top.y <= mouse.bottom.y then
            selectionArea.top.y = mouse.top.y
            selectionArea.bottom.y = mouse.bottom.y
        else
            selectionArea.top.y = mouse.bottom.y
            selectionArea.bottom.y = mouse.top.y
        end

        local x = selectionArea.top.x
        local y = selectionArea.top.y
        local width = selectionArea.bottom.x - selectionArea.top.x
        local height = selectionArea.bottom.y - selectionArea.top.y

        --2px thick
        surface.SetDrawColor(0, 255, 0, 255)
        surface.DrawOutlinedRect(x, y, width, height)
        surface.DrawOutlinedRect(x + 1, y + 1, width - 2, height - 2)
    else
        selectionArea.top.x = 0
        selectionArea.top.y = 0
        selectionArea.bottom.x = 0
        selectionArea.bottom.y = 0
    end
end

local function TranslatePosition(map, pos)
    pos.x = pos.x - GAMEMODE.Overview.x
    pos.y = GAMEMODE.Overview.y - pos.y

    pos.x = (pos.x / map.scale)
    pos.y = (pos.y / map.scale) + map.top
end

local function DrawMiniMap()
    local map = {
        size = mapSize,
        top = ScrH() - mapSize,
    }

    if GAMEMODE.Overview != nil then
        map.scale = GAMEMODE.Overview.scale * (1024 / mapSize)

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
        
        surface.DrawRect(0, map.top, map.size, map.size)

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)

        surface.SetDrawColor(12, 12, 14)
        surface.DrawRect(0, map.top, map.size, map.size)

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(GAMEMODE.Overview.material)
        surface.DrawTexturedRect(0, map.top, map.size, map.size)

        surface.SetDrawColor(255, 255, 255)
        for _, v in pairs(objectiveData) do
            local texture = v.texture
            local pos = v.position
            TranslatePosition(map, pos)

            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material(texture))
            surface.DrawTexturedRect(pos.x - 10, pos.y - 10, 20, 20)
        end

        for _, ent in pairs(allNPCs) do
            if IsValid(ent) && ent:Health() > 0 && !ent:IsDormant() then
                local pos = ent:GetPos()
                TranslatePosition(map, pos)

                surface.SetDrawColor(0, 0, 255)
                surface.DrawRect(pos.x, pos.y, 4, 4)
            end
        end

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() && ply:Team() == TEAM_REBELS then
                local pos = ply:GetPos()
                TranslatePosition(map, pos)

                surface.SetDrawColor(255, 0, 0)
                surface.DrawRect(pos.x, pos.y, 4, 4)
            elseif ply:Team() == TEAM_OVERWATCH && LocalPlayer() != ply then
                local pos = ply:GetPos()
                TranslatePosition(map, pos)

                surface.SetDrawColor(team.GetColor(TEAM_OVERWATCH):Unpack())
                surface.DrawRect(pos.x, pos.y, 4, 4)

                ply.OrderSize = ply.OrderSize || 0
                if ply.OrderSize > 0 then
                    local texture = "onclick_attackmove"
                    if ply.OrderType == ORDER_ATTACK then
                        texture = "onclick_attack"
                    elseif ply.OrderType == ORDER_MOVE then
                        texture = "onclick_move"
                    end

                    pos:Set(ply.OrderTarget)
                    TranslatePosition(map, pos)

                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(GAMEMODE.Textures[texture])
                    surface.DrawTexturedRect(pos.x - (ply.OrderSize / 2), pos.y - (ply.OrderSize / 2), ply.OrderSize, ply.OrderSize)
                    ply.OrderSize = ply.OrderSize - 0.5
                end
            end
        end

        local myPos = Vector()
        myPos:Set(OverwatchPos)
        TranslatePosition(map, myPos)

        surface.SetDrawColor(0, 255, 0)
        surface.DrawRect(myPos.x, myPos.y, 4, 4)

        if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) then
            local x, y = input.GetCursorPos()
            if (x >= 0 && x < map.size - 2) && (y >= map.top && y < ScrH()) then
                OverwatchPos.x = (x * map.scale) + GAMEMODE.Overview.x
                OverwatchPos.y = ((map.top - y) * map.scale) + GAMEMODE.Overview.y
            end
        end
        render.SetStencilEnable(false)
    end
end

local function DrawButtons()
    --Order Buttons
    local alpha = 255
    if #selectedNPCs == 0 then
        alpha = 100
    end

    --Top row, left to right
    surface.SetDrawColor(139, 82, 7)
    surface.DrawOutlinedRect(xTop + 22, yTop + 22, 56, 56)
    surface.DrawOutlinedRect(xTop + 100, yTop + 22, 56, 56)
    surface.DrawOutlinedRect(xTop + 178, yTop + 22, 56, 56)
    surface.DrawOutlinedRect(xTop + 256, yTop + 22, 56, 56)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(GAMEMODE.Textures["attack"])
    surface.DrawTexturedRect(xTop + 22, yTop + 22, 56, 56)

    surface.SetMaterial(GAMEMODE.Textures["attackmove"])
    surface.DrawTexturedRect(xTop + 100, yTop + 22, 56, 56)

    surface.SetMaterial(GAMEMODE.Textures["move"])
    surface.DrawTexturedRect(xTop + 178, yTop + 22, 56, 56)

    surface.SetMaterial(GAMEMODE.Textures["stop"])
    surface.DrawTexturedRect(xTop + 256, yTop + 22, 56, 56)

    surface.SetMaterial(GAMEMODE.Textures["kill"])
    surface.DrawTexturedRect(xTop + 256, yTop + 100, 56, 56)

    --Abilities
    local abilityTypes = {}
    for _, ent in pairs(selectedNPCs) do
        if ent:IsNPC() && IsValid(ent) && !GAMEMODE.OverwatchNPCBlacklist[ent:GetClass()] && ent:Health() > 0 && !ent:IsDormant() then
            if ent:GetClass() == "npc_combine_s" then
                if ent:GetNWInt("NumGrenades") > 0 then
                    abilityEnts["grenade"] = abilityEnts["grenade"] || {}
                    table.insert(abilityEnts["grenade"], ent)
                    abilityTypes["grenade"] = true
                end
            elseif ent:GetClass() == "npc_strider" then
                if ent:GetNWInt("Charges") > 0 then
                    abilityEnts["strider"] = abilityEnts["strider"] || {}
                    table.insert(abilityEnts["strider"], ent)
                    abilityTypes["strider"] = true
                end
            elseif ent:GetClass() == "npc_clawscanner" then
                if ent:GetNWBool("CarryingMine") then
                    abilityEnts["hoppermine"] = abilityEnts["hoppermine"] || {}
                    table.insert(abilityEnts["hoppermine"], ent)
                    abilityTypes["hoppermine"] = true
                end
            elseif ent:GetClass() == "npc_helicopter" then
                if ent:GetNWInt("Charges") > 0 then
                    abilityEnts["chopperbomb"] = abilityEnts["chopperbomb"] || {}
                    table.insert(abilityEnts["chopperbomb"], ent)
                    abilityTypes["chopperbomb"] = true
                end
            end
        end
    end

    abilityButtons = {}
    for k, v in pairs(abilityTypes) do
        if abilityCount > 3 then break end

        table.insert(abilityButtons, k)
        surface.SetDrawColor(255, 255, 255)

        local ent = abilityEnts[k][1]
        if ent:IsValid() then
            local cooldown = ent:GetNWInt("Cooldown", -1)
            if cooldown > -1 && CurTime() < cooldown then
                surface.SetDrawColor(255, 0, 0)
            end
        end

        surface.SetMaterial(GAMEMODE.Textures["ability_" .. k])
        surface.DrawTexturedRect(xTop + 22 + (78 * abilityCount), yTop + 100, 56, 56)

        abilityCount = abilityCount + 1
    end
    
    for i = abilityCount, 3 do
        surface.SetMaterial(GAMEMODE.Textures["ability_empty"])
        surface.DrawTexturedRect(xTop + 22 + (78 * i), yTop + 100, 56, 56)
    end

    --Bottom row, left to right
    surface.SetDrawColor(139, 82, 7)
    surface.DrawOutlinedRect(xTop + 22, yTop + 100, 56, 56)
    surface.DrawOutlinedRect(xTop + 100, yTop + 100, 56, 56)
    surface.DrawOutlinedRect(xTop + 178, yTop + 100, 56, 56)
    surface.DrawOutlinedRect(xTop + 256, yTop + 100, 56, 56)
end

local function CheckButtonClick()
    --Order buttons
    if IsKeyClicked(input.IsMouseDown(MOUSE_LEFT), MOUSE_LEFT) && #selectedNPCs > 0 then
        --Top Left
        if MouseOnObject(xTop + 50, yTop + 50, 56) then
            orderType = ORDER_ATTACK
        --Top Middle Left
        elseif MouseOnObject(xTop + 128, yTop + 50, 56) then
            orderType = ORDER_ATTACKMOVE
            showAttackMove = true
        --Top Middle Right
        elseif MouseOnObject(xTop + 206, yTop + 50, 56) then
            orderType = ORDER_MOVE
        --Top Right
        elseif MouseOnObject(xTop + 284, yTop + 50, 56) then
            net.Start("StopNPC")
            net.WriteTable(selectedNPCs)
            net.SendToServer()

        --Bottom Left
        elseif MouseOnObject(xTop + 50, yTop + 128, 56) && abilityCount >= 1 then
            local ent = abilityEnts[abilityButtons[1]][1]
            if IsValid(ent) then
                net.Start("UseAbility")
                net.WriteEntity(ent)
                net.SendToServer()
            end
        --Bottom Middle Left
        elseif MouseOnObject(xTop + 128, yTop + 128, 56) && abilityCount >= 2 then
            local ent = abilityEnts[abilityButtons[2]][1]
            if IsValid(ent) then
                net.Start("UseAbility")
                net.WriteEntity(ent)
                net.SendToServer()
            end
        --Bottom Middle Right
        elseif MouseOnObject(xTop + 206, yTop + 128, 56) && abilityCount >= 3 then
            local ent = abilityEnts[abilityButtons[3]][1]
            if IsValid(ent) then
                net.Start("UseAbility")
                net.WriteEntity(ent)
                net.SendToServer()
            end
        --Bottom Right
        elseif MouseOnObject(xTop + 284, yTop + 128, 56) then
            net.Start("KillNPC")
            net.WriteTable(selectedNPCs)
            net.SendToServer()
        end
    end
    --Top Left
    if MouseOnObject(xTop + 50, yTop + 50, 56) then
        tooltip = ORDER_ATTACK
    --Top Middle Left
    elseif MouseOnObject(xTop + 128, yTop + 50, 56) then
        tooltip = ORDER_ATTACKMOVE
    --Top Middle Right
    elseif MouseOnObject(xTop + 206, yTop + 50, 56) then
        tooltip = ORDER_MOVE
    --Top Right
    elseif MouseOnObject(xTop + 284, yTop + 50, 56) then
        tooltip = ORDER_STOP

    --Bottom Left
    elseif MouseOnObject(xTop + 50, yTop + 128, 56) then
        tooltip = -1
    --Bottom Middle Left
    elseif MouseOnObject(xTop + 128, yTop + 128, 56) then
        tooltip = -2
    --Bottom Middle Right
    elseif MouseOnObject(xTop + 206, yTop + 128, 56) then
        tooltip = -3
    --Bottom Right
    elseif MouseOnObject(xTop + 284, yTop + 128, 56) then
        tooltip = -4
    end

    --F1 keys
    --Bottom Left
    if IsKeyClicked(input.IsKeyDown(KEY_F1), KEY_F1) && abilityCount >= 1 then
        local ent = abilityEnts[abilityButtons[1]][1]
        if IsValid(ent) then
            net.Start("UseAbility")
            net.WriteEntity(ent)
            net.SendToServer()
        end
    --Bottom Middle Left
    elseif IsKeyClicked(input.IsKeyDown(KEY_F2), KEY_F2) && abilityCount >= 2 then
        local ent = abilityEnts[abilityButtons[2]][1]
        if IsValid(ent) then
            net.Start("UseAbility")
            net.WriteEntity(ent)
            net.SendToServer()
        end
    --Bottom Middle Right
    elseif IsKeyClicked(input.IsKeyDown(KEY_F3), KEY_F3) && abilityCount >= 3 then
        local ent = abilityEnts[abilityButtons[3]][1]
        if IsValid(ent) then
            net.Start("UseAbility")
            net.WriteEntity(ent)
            net.SendToServer()
        end
    end
end

local function DrawToolTips()
    CheckButtonClick()

    if tooltip != 0 then
        surface.SetTextColor(255, 255, 255)
        surface.SetFont("Overwatch.Objective")

        local text = {"", "", "", ""}

        if tooltip > 0 then
            text[1] = toolTips[tooltip].title
            text[2] = toolTips[tooltip].description
            local keybind = input.LookupBinding(toolTips[tooltip].command, true) || toolTips[tooltip].keybind
            text[4] = string.upper(keybind)
        elseif tooltip == -4 then
            text[1] = "Kill Units"
            text[2] = "Kill the selected units to free up the unit cap."
        else
            tooltip = math.abs(tooltip)
            if abilityToolTips[abilityButtons[tooltip]] != nil then
                text[1] = abilityToolTips[abilityButtons[tooltip]]["title"]
                text[2] = abilityToolTips[abilityButtons[tooltip]]["description"]
                text[4] = "F" .. tooltip

                if abilityToolTips[abilityButtons[tooltip]]["charges"] then
                    text[3] = "Charges left: " .. abilityEnts[abilityButtons[tooltip]][1]:GetNWInt("Charges")
                end
            end
        end

        if #text[4] > 0 then
            text[4] = "Bound to key: " .. text[4]
        end

        for k, v in ipairs(text) do
            surface.SetTextPos(offsetBar + 12, yTop + 10 + 25 * (k - 1))
            surface.DrawText(v)
        end
    else
        if next(buttonInfo) != nil then
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(offsetBar + 12, yTop + 10) 
            surface.SetFont("Overwatch.Objective")
            surface.DrawText(buttonInfo.Title)
    
    
            surface.SetTextPos(offsetBar + 12, yTop + 35)
            surface.DrawText(buttonInfo.Text)
    
            local status
            if buttonInfo.Enabled then
                local cooldown = buttonInfo.Cooldown
                if cooldown <= CurTime() then
                    status = "Ready"
                else
                    status = "Ready in " .. math.Round(cooldown - CurTime()) .. " seconds"
                end
    
                local charges = tonumber(buttonInfo.Charges)
                if charges >= 0 then
                    surface.SetTextPos(offsetBar + 12, yTop + 85)
                    surface.DrawText("Charges left: " .. charges)
                end
            else
                status = "Disabled"
            end
    
            surface.SetTextPos(offsetBar + 12, yTop + 60)
            surface.DrawText("Status: " .. status)
        end
    end
end

local function DrawUnitCap()
    surface.SetTextColor(255, 255, 255)
    local unitPercentage = GetUnitCount() / GetUnitCap()
    if unitPercentage >= 1 then
        surface.SetTextColor(255, 0, 0)
    elseif unitPercentage >= 0.9 then
        surface.SetTextColor(255, 100, 0)
    elseif unitPercentage >= 0.75 then
        surface.SetTextColor(255, 255, 0)
    end

    surface.SetFont("Overwatch.Objective")
    surface.SetTextPos(offsetBar + 12, yTop + 150)
    surface.DrawText("Units: " .. GetUnitCount() .. "/" .. GetUnitCap())
end

local function DrawBottomBar()
    surface.SetDrawColor(18, 18, 21)
    surface.DrawRect(offsetBar, yTop, ScrW(), barHeight)

    surface.SetMaterial(GAMEMODE.Textures["icon"])
    surface.SetDrawColor(255, 255, 255)
    surface.DrawTexturedRect(xTop - 128, ScrH() - 153, 128, 128)

    DrawButtons()
    DrawToolTips()
    DrawUnitCap()
end

local function DrawCursor()
    if orderType == ORDER_ATTACK then
        cursor = "cursor_attack"
    elseif orderType == ORDER_ATTACKMOVE && showAttackMove then
        cursor = "cursor_attackmove"
    elseif orderType == ORDER_MOVE then
        cursor = "cursor_move"
    end

    local x, y = input.GetCursorPos()
    if system.HasFocus() then
        if 0 <= y && y <= ScrH() then
            if y < 12 then
                cursor = "cursor_top"
                OverwatchPos:Add(Vector(0, 17, 0))
            elseif y > ScrH() - 12 then
                cursor = "cursor_bottom"
                OverwatchPos:Add(Vector(0, -17, 0))
            end
        end

        if 0 <= x && x <= ScrW() then
            if x < 12 then
                cursor = "cursor_left"
                OverwatchPos:Add(Vector(-17, 0, 0))
            elseif x > ScrW() - 12 then
                cursor = "cursor_right"
                OverwatchPos:Add(Vector(17, 0, 0))
            end
        end
    end

    if !handCursor then
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(GAMEMODE.Textures[cursor])
        surface.DrawTexturedRect(x - 24, y - 24 , 48, 48)
    end
end

local function DrawGroundNodes()
    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_GROUND] do
        local data2D = GAMEMODE.Nodes[NODE_TYPE_GROUND][i]:ToScreen()
        local size = 32
        if !IsIconOnScreen(data2D, size) then continue end

        surface.SetDrawColor(255, 255, 0)
        surface.SetMaterial(GAMEMODE.Textures["selected"])
        surface.DrawTexturedRect(data2D.x - 16, data2D.y - 16, 32, 32)
    end
end

local function DrawAirNodes()
    for i = 1, #GAMEMODE.Nodes[NODE_TYPE_AIR] do
        local data2D = GAMEMODE.Nodes[NODE_TYPE_AIR][i]:ToScreen()
        local size = 32
        if !IsIconOnScreen(data2D, size) then continue end

        surface.SetDrawColor(255, 125, 0)
        surface.SetMaterial(GAMEMODE.Textures["selected"])
        surface.DrawTexturedRect(data2D.x - 16, data2D.y - 16, 32, 32)
    end
end

function DrawOverwatchHUD()
    mapSize = ScrH() / 3
    offsetBar = math.max(ScrW() - 1520, 0) + mapSize
    xTop = ScrW() - 334
    yTop = ScrH() - 178
    tooltip = 0

    abilityCount = 0
    abilityEnts = {}
    buttonInfo = {}

    LoopThroughEntities()
    OrderUnits()

    if #team.GetPlayers(TEAM_OVERWATCH) > 1 then
        net.Start("HighlightNPC")
        net.WriteUInt(#selectedNPCs, 8)
        for _, ent in pairs(selectedNPCs) do
            net.WriteEntity(ent)
        end
        net.SendToServer()
    end

    --DrawGroundNodes()
    --DrawAirNodes()

    DrawSelectionBox()
    DrawOrder()
    DrawMiniMap()
    DrawBottomBar()
    DrawCursor()
end