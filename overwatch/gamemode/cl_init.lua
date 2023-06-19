LocalPlayer().menuOpen = LocalPlayer().menuOpen || false
LocalPlayer().menuFrame = LocalPlayer().menuFrame || nil
LocalPlayer().suppressNumberKey = false
LocalPlayer().ControlCooldown = 0
LocalPlayer().RespawnTime = 0
hudScale = math.Clamp(ScrW() / 1920, 0.676, 1.33)
orderType = ORDER_ATTACKMOVE
showAttackMove = false
handCursor = false
selectedNPCs = {}
highlightedNPCs = highlightedNPCs || {}
OverwatchPos = OverwatchPos || Vector()

traces = {}
objectiveData = {}
previousKeyState = {}

cursor = "cursor_normal"

include('sh_enum.lua')
include('sh_gamemode.lua')
include('sh_relationships.lua')
include('sh_voicelines.lua')
include('shared.lua')
include('cl_commands.lua')
include('cl_fonts.lua')
include('cl_gamemode.lua')
include('cl_hud.lua')
include('cl_move.lua')
include('cl_net.lua')
include('cl_overwatch.lua')
include('cl_render.lua')
include('cl_scoreboard.lua')

mapSummaryAvailable = {
    ow_breach = true,
    ow_breached = true,
    ow_canals = true,
    ow_citadel = true,
    ow_crossroads = true,
    ow_assaulted = true,
    ow_tunnels = true,
    ow_whiteforest = true,
    owc_outbreak = true,
    owc_superfortress = true,
    owc_traverse = true,
}

toolTips = {
    {
        title = "Attack",
        description = "Order selected units to attack and pursue the target.",
        command = "ow_order_attack",
        keybind = "1"
    },
    {
        title = "Attack/Move",
        description = "Order selected units to move to the target area and attack enemies along the way.",
        command = "ow_order_attackmove",
        keybind = "2"
    },
    {
        title = "Move",
        description = "Order selected units to move to the target area.",
        command = "ow_order_move",
        keybind = "3"
    },
    {
        title = "Stop",
        description = "Order selected units to cancel all orders and stop moving.",
        command = "ow_order_stop",
        keybind = "4"
    }
}

abilityToolTips = {
    grenade = {
        title = "Throw Grenade",
        description = "Throw a grenade at the enemy. Soldier must be in combat."
    },
    strider = {
        title = "Fire Cannon",
        description = "Fire the Warpspace Cannon at the enemy. Strider must be in combat.",
        charges = true
    },
    hoppermine = {
        title = "Drop Hopper Mine",
        description = "Order the selected Scanner to deploy the carried hopper mine."
    },
    chopperbomb  = {
        title = "Carpet Bomb",
        description = "Order the selected Hunter Chopper to start carpet bombing.",
        charges = true
    },
}

local files = file.Find("overwatch/gamemode/overviews/" .. game.GetMap() .. ".lua", "LUA")
if(#files > 0) then
	for _, v in pairs(files) do
        include("overviews/" .. v)
	end
end

function GM:DoAnimationEvent(ply, event, data)
    if ply == LocalPlayer() then
        if LocalPlayer():Team() == TEAM_REBELS && event == PLAYERANIMEVENT_RELOAD then
            net.Start("EmitNetworkedVoiceLine")
            net.WriteUInt(VOICE_RELOAD, 4)
            net.WriteBool(false)
            net.SendToServer()
        end
    end
end

function GM:SetupWorldFog()
    if LocalPlayer():Team() == TEAM_OVERWATCH then return true end
    return false
end

function GM:StartChat(isTeamChat)
    if LocalPlayer().menuOpen then
        timer.Create("CloseChat", 0, 1, function() chat.Close() end)
        return true
    end
    return false
end

local ragdollCount = 0
function GM:CreateClientsideRagdoll(entity, ragdoll)
    ragdollCount = ragdollCount + 1
    timer.Create("FadeRagdollTimer" .. ragdollCount, 10, 1, function()
        if IsValid(ragdoll) then
            ragdoll:SetSaveValue("m_bFadingOut", true)
        end
    end)
end

function SetRoundState(state)
    GAMEMODE.RoundState = state

    if(state == ROUND_STARTED) then
        LocalPlayer().VoteMenu = false
    end
end

function GetRoundState()
    return GAMEMODE.RoundState
end

function SetUnitCap(unitCap)
    GAMEMODE.UnitCap = unitCap
end

function GetUnitCap()
    return GAMEMODE.UnitCap
end

function BlockSwitch()
    if GAMEMODE.DisableWeaponSwitch == nil then
        GAMEMODE.DisableWeaponSwitch = {}
        GAMEMODE.DisableWeaponSwitch[LocalPlayer():EntIndex()] = false
    end

    GAMEMODE.DisableWeaponSwitch[LocalPlayer():EntIndex()] = true
    net.Start("DisableWeaponSwitch")
    net.WriteBool(true)
    net.SendToServer()

    timer.Create("EnableVoiceMenu", 0.5, 1, function()
        GAMEMODE.DisableWeaponSwitch[LocalPlayer():EntIndex()] = false
        net.Start("DisableWeaponSwitch")
        net.WriteBool(false)
        net.SendToServer()
    end)
end

function SecondsToTimer(time)
    local timeMinutes = math.Clamp(math.floor(time / 60), 0, math.pow(2, 16) - 1)
    local timeSeconds = math.Clamp(math.fmod(time, 60), 0, 60)
    if timeSeconds < 10 then
        timeSeconds = "0" .. timeSeconds
    end

    return timeMinutes .. ":" .. timeSeconds
end

function MouseOnObject(objectX, objectY, objectSize, mouseX, mouseY)
    if mouseX == nil || mouseY == nil then
        mouseX, mouseY = input.GetCursorPos()
    end

    return  (objectX - (objectSize / 2) <= mouseX && mouseX <= objectX + (objectSize / 2)) &&
            (objectY - (objectSize / 2) <= mouseY && mouseY <= objectY + (objectSize / 2))
end

function IsIconOnScreen(data2D, size)
    if data2D.x + size / 2 < 0 then return false end
    if data2D.x - size / 2 > ScrW() then return false end
    if data2D.y + size / 2 < 0 then return false end
    if data2D.y - size / 2 > ScrW() then return false end
    return true
end

function SetKeyState(keycode, bool)
    previousKeyState[keycode] = bool
end

function IsKeyClicked(bool, keycode)
    if !bool then return false end
    if !previousKeyState[keycode] then return true end
    return false
end

function IsKeyHeld(bool, keycode)
    if !bool then return false end
    if previousKeyState[keycode] then return true end
    return false
end

function IsKeyReleased(bool, keycode)
    if bool then return false end
    if previousKeyState[keycode] then return true end
    return false
end