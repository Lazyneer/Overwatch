function GM:HUDShouldDraw(element)
    if IsValid(LocalPlayer()) then
        if element == "CHudHealth" || element == "CHudAmmo" || element == "CHudSecondaryAmmo" then
            return false
        end

        if LocalPlayer():Team() == TEAM_OVERWATCH || LocalPlayer().menuOpen || GetRoundState() == ROUND_ENDED then
            if element == "CHudCrosshair" then
                return false 
            end

        end
    end
    return true
end

function GM:RenderScreenspaceEffects()
    if LocalPlayer():Team() == TEAM_COMBINE then
        DrawMaterialOverlay("effects/combine_binocoverlay", 0)
    end
end

local mouseWheel = 0
function GM:RenderScene()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        local worldPanel = vgui.GetWorldPanel()
        function worldPanel.OnMouseWheeled(self, scrollDelta)
            mouseWheel = mouseWheel + scrollDelta * 8
            if mouseWheel < 0 then
                mouseWheel = 0
            elseif mouseWheel > 64 then
                mouseWheel = 64
            end
        end

        local ren = {}
        ren.x = 0
        ren.y = 0
        ren.w = ScrW()
        ren.h = ScrH()
        ren.drawhud = true
        ren.fov = 106 - mouseWheel -- My original FOV seemed to be 106
        LocalPlayer().fov = ren.fov

        --ren.angles = GAMEMODE.Cameras.overwatch.ang
        ren.angles = Angle(80, 90, 0)
        ren.origin = OverwatchPos

        render.RenderView(ren)
        return true
    end
    return false
end

local function DrawTracers()
    for k, v in ipairs(traces) do
        local colors = {
            Color(255, 255, 255),
            Color(255, 0, 0),
            Color(0, 255, 0),
            Color(0, 0, 255)
        }
        local color = math.fmod(k, 4)
        if color == 0 then color = 4 end
        render.DrawLine(v["startPos"], v["endPos"], colors[color])
    end
end

local function Draw2DCircle(texture, size)
    surface.SetMaterial(texture)
    surface.DrawTexturedRect(size / -2, size / -2, size, size)
end

local rotation = Angle()
local function DrawUnitCircle(ent, offset, scale, size)
    local pos = ent:GetPos()
    pos:Add(Vector(0, 0, offset))
    cam.Start3D2D(pos, Angle(), 1 / scale)
        if highlightedNPCs[ent] && !ent.Selected then
            surface.SetDrawColor(team.GetColor(TEAM_OVERWATCH):Unpack())
        else
            local r = 255
            local g = 255
            local health = ent:Health() / ent:GetMaxHealth()
            if health <= 0.5 then
                g = 255 * (health * 2)
            else
                r = 255 * ((health - 1) * -2)
            end

            surface.SetDrawColor(r, g, 0, 255)
        end

        if ent.Selected then
            Draw2DCircle(GAMEMODE.Textures.selected, size * 7)
        else
            Draw2DCircle(GAMEMODE.Textures.allied, size * 6)
        end
    cam.End3D2D()

    if ent.Highlighted then
        cam.Start3D2D(pos, rotation, 1 / scale)
            surface.SetDrawColor(0, 255, 0)
            Draw2DCircle(GAMEMODE.Textures.highlighted, size * 8)
        cam.End3D2D()
    end
end

local function DrawPlayerCircle(ply, offset, scale, size)
    local pos = ply:GetPos()
    pos:Add(Vector(0, 0, offset))
    cam.Start3D2D(pos, Angle(), 1 / scale)

        surface.SetDrawColor(255, 0, 0, 255)
        if ply:Team() == TEAM_COMBINE then
            surface.SetDrawColor(0, 255, 0, 255)
        end

        if ply.Selected then
            Draw2DCircle(GAMEMODE.Textures.selected, size * 7)
        else
            Draw2DCircle(GAMEMODE.Textures.enemy, size * 6)
        end
    cam.End3D2D()

    if ply.Highlighted then
        cam.Start3D2D(pos, rotation, 0.5)
            Draw2DCircle(GAMEMODE.Textures.highlighted, size * 8)
        cam.End3D2D()
    end
end

function GM:PostDrawOpaqueRenderables(bDrawingDepth, bDrawingSkybox)
    --DrawTracers()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        rotation:Add(Angle(0, 0.75, 0))
        for _, ent in pairs(ents.GetAll()) do
            if IsValid(ent) && ent:Health() > 0 && !ent:IsDormant() then
                if ent:IsNPC() && !GAMEMODE.OverwatchNPCBlacklist[ent:GetClass()] then
                    if ent:GetClass() == "npc_strider" || ent:GetClass() == "npc_helicopter" then
                        DrawUnitCircle(ent, -64, 64, 2048)
                    elseif ent:GetClass() == "npc_hunter" then
                        DrawUnitCircle(ent, 16, 2, 16)
                    else
                        DrawUnitCircle(ent, 8, 2, 16)
                    end
                elseif ent:IsNPC() && GAMEMODE.OverwatchNPCEnemy[ent:GetClass()]then
                    local pos = ent:GetPos()
                    pos:Add(Vector(0, 0, 8))
                    cam.Start3D2D(pos, Angle(), 0.5)
                        surface.SetDrawColor(255, 0, 0)
                        Draw2DCircle(GAMEMODE.Textures.enemy, 96)
                    cam.End3D2D()
                elseif ent:IsPlayer() then
                    DrawPlayerCircle(ent, 8, 2, 16)
                end
            end
        end
    elseif LocalPlayer():Team() == TEAM_REBELS && LocalPlayer():Alive() then
        local ang = LocalPlayer():LocalEyeAngles()
        ang.y = ang.y - 90
        ang.z = 0 - ang.x + 90
        ang.x = 0

        if GetRoundState() == ROUND_SETUP || GetRoundState() == ROUND_STARTED then
            for _, ply in ipairs(player.GetAll()) do
                if ply == LocalPlayer() then continue end
                if ply:Team() == TEAM_REBELS then
                    local pos = ply:GetPos()
                    
                    local icon = "player"
                    if !ply:Alive() then
                        icon = "revive"
                        ent = ply:GetNWEntity("Revive")
                        if !ent:IsValid() then continue end
                        pos = ent:GetPos()
                    elseif IsValid(ply:GetWeapon("weapon_medpack_ow")) then
                        icon = "medic"
                    elseif IsValid(ply:GetWeapon("weapon_riotshield_ow")) then
                        icon = "defender"
                    end

                    local distance = pos:Distance(LocalPlayer():GetPos())
                    local scale = math.Clamp(1 / (125 / distance), 1, 5)
                    local scaleIcon = math.Clamp(250 / distance, 0.5, 1)

                    local health = ply:Health()
                    local healthMsg = health .. " HP"
                    if health <= 0 then
                        health = 0
                        healthMsg = "DEAD"
                    end
                    
                    local percentage = 1
                    local color = Color(255, 255, 0)

                    if health <= 0 then
                        color.r = 255
                        color.g = 0
                        percentage = 0

                        percentage = ply:GetNWFloat("ReviveProgress")
                    else
                        percentage = math.Clamp(health / ply:GetMaxHealth(), 0, 1)
                        color.r = math.Clamp((-6.8 * (percentage - 1)) * 100, 0, 255)
                        color.g = math.Clamp((6.8 * (percentage - 0.25)) * 100, 0, 255)
                    end
                    
                    ply.offset = ply.offset || 72
                    if ply:Crouching() && ply:Alive() then
                        ply.offset = math.Clamp(ply.offset - 1.5, 56, 72)
                    else
                        ply.offset = math.Clamp(ply.offset + 1.5, 56, 72)
                    end
                    pos:Add(Vector(0, 0, ply.offset))
                    cam.Start3D2D(pos, ang, 0.03125 * scale / 2)
                        cam.IgnoreZ(true)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(GAMEMODE.Textures[icon])
                        surface.DrawTexturedRect(-384 * scaleIcon, (-800 * scaleIcon) - 200, 768 * scaleIcon, 768 * scaleIcon)

                        surface.SetDrawColor(0, 0, 0, 200)
                        surface.DrawRect(-320, -200, 640, 160)

                        surface.SetDrawColor(color.r, color.g, 0, 200)
                        surface.DrawRect(-320, -200, 640 * percentage, 160)

                        if ply:Alive() && health <= 35 then
                            surface.SetDrawColor(math.sin(CurTime() * 7) * (255/2) + (255/2), 0, 0, 255)
                            surface.DrawOutlinedRect(-320, -200, 640, 160, 8)
                        end

                        if !ply:Alive() && ply:GetNWBool("Reviving") then
                            surface.SetDrawColor(255, 255, 255, math.sin(CurTime() * 7) * (255/2) + (255/2))
                        else
                            surface.SetDrawColor(0, 0, 0, 200)
                        end
                        surface.DrawOutlinedRect(-320, -200, 640, 160, 8)

                        local alpha = math.Clamp((255 - distance) + 500, 0, 255)
                        draw.SimpleTextOutlined(healthMsg, "Overwatch.Health", 0, -202, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 8, Color(0, 0, 0, alpha))
                        cam.IgnoreZ(false)
                    cam.End3D2D()
                end
            end
        end

        for _, ent in pairs(ents.GetAll()) do
            if (ent:GetClass() == "weapon_medpack_ow" || ent:GetClass() == "weapon_riotshield_ow") && IsValid(ent) then
                if IsValid(ent:GetOwner()) then continue end
                local pos = ent:GetPos()
                pos:Add(Vector(0, 0, 24))

                local icon = "medpack"
                if ent:GetClass() == "weapon_riotshield_ow" then
                    icon = "riotshield"
                end

                cam.Start3D2D(pos, ang, 0.5)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(GAMEMODE.Textures[icon])
                    surface.DrawTexturedRect(-24, -24, 48, 48)
                cam.End3D2D()
            end
        end
    end
end