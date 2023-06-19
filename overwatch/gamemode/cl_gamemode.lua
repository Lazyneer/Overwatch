local lastWidth = ScrW()

function GM:HUDPaint()
    hudScale = math.Clamp(ScrW() / 1920, 0.676, 1.33)
    if lastWidth != ScrW() then
        LoadFonts()
    end

    if !LocalPlayer().menuOpen then
        if GetRoundState() == ROUND_STARTED || #player.GetAll() == 1 then
            if LocalPlayer():Team() == TEAM_OVERWATCH || LocalPlayer():Team() == TEAM_REBELS || LocalPlayer():Team() == TEAM_COMBINE then
                objectiveData = {}
                DrawWorldIcons()
            end

            if LocalPlayer():Team() == TEAM_OVERWATCH then
                cursor = "cursor_normal"
                handCursor = false
                orderType = orderType || ORDER_ATTACKMOVE

                DrawOverwatchHUD()
            end

            previousKeyState.mouseX, previousKeyState.mouseY = input.GetCursorPos()

            SetKeyState(MOUSE_LEFT, input.IsMouseDown(MOUSE_LEFT))
            SetKeyState(MOUSE_RIGHT, input.IsMouseDown(MOUSE_RIGHT))

            SetKeyState(KEY_F1, input.IsKeyDown(KEY_F1))
            SetKeyState(KEY_F2, input.IsKeyDown(KEY_F2))
            SetKeyState(KEY_F3, input.IsKeyDown(KEY_F3))
        end
    end
    DrawHL2Hud()
end