function PickTeam()
    if LocalPlayer().menuFrame == nil then
        LocalPlayer().menuOpen = true
        local margin = 100
        if ScrH() <= 768 then
            margin = 50
        end

        local widescreen = 0
        if (16 / 9) < (ScrW() / ScrH()) then
            widescreen = (ScrW() / 2) - (ScrH() / 1.125)
        end

        local blockHeight = ScrH() - 200 - margin * 2

        local frame = vgui.Create("DFrame")
        frame:SetPos(0, 0)
        frame:SetSize(ScrW(), ScrH())
        frame:SetTitle("")
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
        end

        local wrapper = vgui.Create("DPanel", frame)
        wrapper:SetPos(100 + widescreen, 100 + margin)
        wrapper:SetSize(ScrW() - 200 - (widescreen * 2), blockHeight)
        wrapper:SetPaintBackground(false)

        overwatch = vgui.Create("DButton", wrapper)
        overwatch:SetPos(0, 0)
        overwatch:SetSize(250, 50)
        overwatch:SetText("Opt in for Overwatch")
        overwatch:SetTextColor(Color(255, 255, 255))
        overwatch:SetFont("Overwatch.Menu")
        overwatch.DoClick = function()
            RunConsoleCommand("ow_jointeam_overwatch")
            frame:Close()
            LocalPlayer().menuOpen = false
            LocalPlayer().menuFrame = nil
        end
        overwatch.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()

            surface.SetTextColor(255, 255, 255)
            surface.SetFont("Overwatch.Menu")
            surface.SetTextPos(13, 15)
            surface.DrawText("1.")
        end
        
        rebels = vgui.Create("DButton", wrapper)
        rebels:SetPos(0, 60)
        rebels:SetSize(250, 50)
        rebels:SetText("Join the Resistance")
        rebels:SetTextColor(Color(255, 255, 255))
        rebels:SetFont("Overwatch.Menu")
        rebels.DoClick = function()
            RunConsoleCommand("ow_jointeam_rebels")
            frame:Close()
            LocalPlayer().menuOpen = false
            LocalPlayer().menuFrame = nil
        end
        rebels.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()

            surface.SetTextColor(255, 255, 255)
            surface.SetFont("Overwatch.Menu")
            surface.SetTextPos(13, 15)
            surface.DrawText("2.")
        end
    
        spectator = vgui.Create("DButton", wrapper)
        spectator:SetPos(0, 180)
        spectator:SetSize(250, 50)
        spectator:SetText("Spectate")
        spectator:SetTextColor(Color(255, 255, 255))
        spectator:SetFont("Overwatch.Menu")
        spectator.DoClick = function()
            RunConsoleCommand("ow_jointeam_spectator")
            frame:Close()
            LocalPlayer().menuOpen = false
            LocalPlayer().menuFrame = nil
        end
        spectator.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()

            surface.SetTextColor(255, 255, 255)
            surface.SetFont("Overwatch.Menu")
            surface.SetTextPos(13, 15)
            surface.DrawText("3.")
        end

        local HTMLwrapper = vgui.Create("DPanel", wrapper)
        HTMLwrapper:SetPos(300, 0)
        HTMLwrapper:SetSize(blockHeight, blockHeight)
        HTMLwrapper:SetPaintBackground(false)

        HTML = vgui.Create("HTML", HTMLwrapper)
        HTML:SetPos(0, 0)
        HTML:SetSize(blockHeight, blockHeight)
        --HTML files not allowed in addons, redirecting to my website
        local page = game.GetMap()
        if !mapSummaryAvailable[page] then
            page = "default"
        end
        HTML:OpenURL("http://lazyneer.com/gmod/maphtml/" .. page .. "_english.html")

        --At first I had the HTML 2px smaller. That created an unnecessary scrollbar when the screen was 768px high on the map Breach.
        --When the HTML was 1px taller, the scrollbar was gone. But it would hide the outline.
        --I tried a DPanel with the outline overlapping the HTML, but that removed the ability to scroll.
        --Making 4 DPanels that act like an outline is the only thing that works.
        local outlineLeft = vgui.Create("DPanel", HTMLwrapper)
        outlineLeft:SetPos(0, 0)
        outlineLeft:SetSize(1, blockHeight)
        outlineLeft:SetPaintBackground(false)
        outlineLeft.Paint = function(self, w, h)
            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        local outlineRight = vgui.Create("DPanel", HTMLwrapper)
        outlineRight:SetPos(blockHeight - 1, 0)
        outlineRight:SetSize(1, blockHeight)
        outlineRight:SetPaintBackground(false)
        outlineRight.Paint = function(self, w, h)
            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        local outlineTop = vgui.Create("DPanel", HTMLwrapper)
        outlineTop:SetPos(0, 0)
        outlineTop:SetSize(blockHeight, 1)
        outlineTop:SetPaintBackground(false)
        outlineTop.Paint = function(self, w, h)
            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        local outlineBottom = vgui.Create("DPanel", HTMLwrapper)
        outlineBottom:SetPos(0, blockHeight - 1)
        outlineBottom:SetSize(blockHeight, 1)
        outlineBottom:SetPaintBackground(false)
        outlineBottom.Paint = function(self, w, h)
            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        local helpPanel = vgui.Create("DScrollPanel", wrapper)
        helpPanel:SetPos(300, 0)
        helpPanel:SetSize(blockHeight, blockHeight)
        helpPanel:SetPaintBackground(false)
        helpPanel:Hide()
        helpPanel.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material("vgui/menu/background.png"))
            surface.DrawTexturedRect(0 - (w * 0.25), 3, w * 1.5, h * 1.5)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        local helpTitle = vgui.Create("DLabel", helpPanel)
        helpTitle:Dock(TOP)
        helpTitle:SetWrap(true)
        helpTitle:SetAutoStretchVertical(true)
        helpTitle:SetTextColor(Color(255, 255, 255))
        helpTitle:SetFont("Overwatch.MenuTitle")
        helpTitle:SetText("What is Overwatch?")

        local helpDescription = vgui.Create("DLabel", helpPanel)
        helpDescription:Dock(TOP)
        helpDescription:SetWrap(true)
        helpDescription:SetAutoStretchVertical(true)
        helpDescription:SetTextColor(Color(255, 255, 255))
        helpDescription:SetFont("Overwatch.MenuHelp")
        helpDescription:SetText("\nOverwatch is a cooperative asymmetric multiplayer Real-Time Strategy Shooter (FPS/RTS hybrid). It pits a team of rebels playing cooperatively in first-person (the Resistance) against one player who assumes the role of commander to the Combine forces (the Overwatch), controlling units and the environment around them from a bird's-eye view.\n")

        local helpSubTitle = vgui.Create("DLabel", helpPanel)
        helpSubTitle:Dock(TOP)
        helpSubTitle:SetWrap(true)
        helpSubTitle:SetAutoStretchVertical(true)
        helpSubTitle:SetTextColor(Color(255, 255, 255))
        helpSubTitle:SetFont("Overwatch.MenuSubTitle")
        helpSubTitle:SetText("Controls")

        local helpOverwatch = vgui.Create("DLabel", helpPanel)
        helpOverwatch:Dock(TOP)
        helpOverwatch:SetWrap(true)
        helpOverwatch:SetAutoStretchVertical(true)
        helpOverwatch:SetTextColor(Color(255, 255, 255))
        helpOverwatch:SetFont("Overwatch.MenuBold")
        helpOverwatch:SetText(" ⚫ Overwatch")

        local helpOverwatchControls = vgui.Create("DLabel", helpPanel)
        helpOverwatchControls:Dock(TOP)
        helpOverwatchControls:SetWrap(true)
        helpOverwatchControls:SetAutoStretchVertical(true)
        helpOverwatchControls:SetTextColor(Color(255, 255, 255))
        helpOverwatchControls:SetFont("Overwatch.MenuHelp")
        helpOverwatchControls:SetText("Use WASD to move around. Holding down shift will increase the speed. If you click on the minimap, it will move you there. To select units, click and drag them, and then right click to give them an order. You can give more advanced orders or use special abilities by pressing the buttons in the bottom right.\n")

        local helpRebels = vgui.Create("DLabel", helpPanel)
        helpRebels:Dock(TOP)
        helpRebels:SetWrap(true)
        helpRebels:SetAutoStretchVertical(true)
        helpRebels:SetTextColor(Color(255, 255, 255))
        helpRebels:SetFont("Overwatch.MenuBold")
        helpRebels:SetText(" ⚫ Resistance")

        local helpRebelsControls = vgui.Create("DLabel", helpPanel)
        helpRebelsControls:Dock(TOP)
        helpRebelsControls:SetWrap(true)
        helpRebelsControls:SetAutoStretchVertical(true)
        helpRebelsControls:SetTextColor(Color(255, 255, 255))
        helpRebelsControls:SetFont("Overwatch.MenuHelp")
        helpRebelsControls:SetText("To revive someone, hold E on the revive hologram until they are alive again. If you have picked up a medpack or a riot shield, you can throw them away by equiping them and pressing R. You can use voice commands by pressing Z to open the menu.\n")

        local helpKeybinds = vgui.Create("DLabel", helpPanel)
        helpKeybinds:Dock(TOP)
        helpKeybinds:SetWrap(true)
        helpKeybinds:SetAutoStretchVertical(true)
        helpKeybinds:SetTextColor(Color(255, 255, 255))
        helpKeybinds:SetFont("Overwatch.MenuBold")
        helpKeybinds:SetText(" ⚫ Keybinds")

        local helpBindsPanel = vgui.Create("DPanel", helpPanel)
        helpBindsPanel:Dock(TOP)
        helpBindsPanel:SetSize(blockHeight, 80)
        helpBindsPanel:SetPaintBackground(false)
        helpBindsPanel.Paint = function(self, w, h) end

        local helpBindsCommands = vgui.Create("DLabel", helpBindsPanel)
        helpBindsCommands:Dock(LEFT)
        helpBindsCommands:SetAutoStretchVertical(true)
        helpBindsCommands:SetTextColor(Color(255, 255, 255))
        helpBindsCommands:SetFont("Overwatch.MenuHelp")
        helpBindsCommands:SetText("ow_jointeam\now_voicemenu\now_order_attack\now_order_attackmove\now_order_move")
        helpBindsCommands:SizeToContentsX()

        local helpBindsDefaults = vgui.Create("DLabel", helpBindsPanel)
        helpBindsDefaults:Dock(LEFT)
        helpBindsDefaults:SetAutoStretchVertical(true)
        helpBindsDefaults:SetTextColor(Color(255, 255, 255))
        helpBindsDefaults:SetFont("Overwatch.MenuHelp")
        helpBindsDefaults:SetText("Key: .\nKey: Z\nKey: 1\nKey: 2\nKey: 3\n")
        helpBindsDefaults:SizeToContentsX()

        local helpBindsDescription = vgui.Create("DLabel", helpBindsPanel)
        helpBindsDescription:Dock(LEFT)
        helpBindsDescription:SetAutoStretchVertical(true)
        helpBindsDescription:SetTextColor(Color(255, 255, 255))
        helpBindsDescription:SetFont("Overwatch.MenuHelp")
        helpBindsDescription:SetText("Opens this menu\nOpens the voice menu\nSelects the Attack order\nSelects the Attack\\Move order\nSelects the Move order")
        helpBindsDescription:SizeToContentsX()

        local canvas = helpPanel:GetCanvas()
        canvas:DockPadding(blockHeight / 17, 30, blockHeight / 17, 15)

        help = vgui.Create("DButton", wrapper)
        help:SetPos(0, 240)
        help:SetSize(250, 50)
        help:SetText("Help")
        help:SetTextColor(Color(255, 255, 255))
        help:SetFont("Overwatch.Menu")
        help.DoClick = function()
            helpPanel:ToggleVisible()
            HTMLwrapper:ToggleVisible()
        end
        help.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()

            surface.SetTextColor(255, 255, 255)
            surface.SetFont("Overwatch.Menu")
            surface.SetTextPos(13, 15)
            surface.DrawText("4.")
        end

        if LocalPlayer():Team() != TEAM_CONNECTING then
            close = vgui.Create("DButton", wrapper)
            close:SetPos(0, 300)
            close:SetSize(250, 50)
            close:SetText("Close")
            close:SetTextColor(Color(255, 255, 255))
            close:SetFont("Overwatch.Menu")
            close.DoClick = function()
                frame:Close()
                LocalPlayer().menuOpen = false
                LocalPlayer().menuFrame = nil
            end
            close.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(0, 0, w, h)

                surface.SetDrawColor(team.GetColor(TEAM_REBELS))
                self:DrawOutlinedRect()

                surface.SetTextColor(255, 255, 255)
                surface.SetFont("Overwatch.Menu")
                surface.SetTextPos(13, 15)
                surface.DrawText("5.")
            end
        end

        exit = vgui.Create("DButton", wrapper)
        exit:SetPos(0, ScrH() - 250 - margin * 2)
        exit:SetSize(250, 50)
        exit:SetText("Disconnect")
        exit:SetTextColor(Color(255, 255, 255))
        exit:SetFont("Overwatch.Menu")
        exit.DoClick = function()
            RunConsoleCommand("disconnect")
            frame:Close()
            LocalPlayer().menuOpen = false
            LocalPlayer().menuFrame = nil
        end
        exit.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(team.GetColor(TEAM_REBELS))
            self:DrawOutlinedRect()
        end

        LocalPlayer().menuFrame = frame
    end
end

function MiniMapZoom()
    if LocalPlayer():Team() == TEAM_REBELS && !LocalPlayer().menuOpen then
        LocalPlayer().MiniMapZoom = !LocalPlayer().MiniMapZoom
    end
end

function OrderAttack()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        orderType = ORDER_ATTACK
    end
end

function OrderAttackMove()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        orderType = ORDER_ATTACKMOVE
        showAttackMove = true
    end
end

function OrderMove()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        orderType = ORDER_MOVE
    end
end

function OrderStop()
    if LocalPlayer():Team() == TEAM_OVERWATCH then
        orderType = ORDER_STOP
    end
end

function VoiceMenu()
    if LocalPlayer():Team() == TEAM_REBELS && !LocalPlayer().menuOpen then
        LocalPlayer().VoiceMenu = true
    end
end

concommand.Add("ow_jointeam", PickTeam)
concommand.Add("ow_minimap", MiniMapZoom)
concommand.Add("ow_order_attack", OrderAttack)
concommand.Add("ow_order_attackmove", OrderAttackMove)
concommand.Add("ow_order_move", OrderMove)
concommand.Add("ow_order_stop", OrderStop)
concommand.Add("ow_voicemenu", VoiceMenu)