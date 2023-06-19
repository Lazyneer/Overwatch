net.Receive("AnnounceOverwatch", function()
    local ply = net.ReadEntity()
    chat.AddText(team.GetColor(TEAM_REBELS), ply:GetName() .. " has been selected as Overwatch.")
end)

net.Receive("BroadcastConVarMaxRounds", function()
    local played = net.ReadUInt(8)
    GAMEMODE.ConVars.maxrounds.played = played
end)

net.Receive("BroadcastConVarTimeLimit", function()
    local start = net.ReadUInt(16)
    GAMEMODE.ConVars.timelimit.start = start
end)

net.Receive("BroadcastHighlightedNPCs", function()
    highlightedNPCs = {}
    local size = net.ReadUInt(8)
    for i = 1, size do
        highlightedNPCs[net.ReadEntity()] = true
    end
end)

net.Receive("BroadcastNextMap", function()
    local map = net.ReadString()
    local msg = ""
    GAMEMODE.NextMap = map
    if net.ReadBool() then
        local votes = net.ReadUInt(8)
        local total = net.ReadUInt(8)
        local plural = " votes"
        if total == 1 then
            plural = " vote"
        end
        msg = " (Received " .. math.Round(votes / total * 100) .. "% of " .. total .. plural .. ")"
    end
    chat.AddText(team.GetColor(TEAM_REBELS), "The next map is: " .. SanitizeMapName(map) .. msg)
end)

net.Receive("BroadcastRoundState", function()
    local state = net.ReadInt(4)
    SetRoundState(state)
end)

net.Receive("BroadcastUnitCap", function()
    local unitCap = net.ReadUInt(6)
    SetUnitCap(unitCap)
end)

net.Receive("ControlCooldown", function()
    LocalPlayer().ControlCooldown = net.ReadUInt(16)
end)

net.Receive("CloseMenu", function()
    if LocalPlayer().menuFrame != nil then
        LocalPlayer().menuFrame:Close()
        LocalPlayer().menuOpen = false
        LocalPlayer().menuFrame = nil
    end
end)

net.Receive("NetworkNodes", function()
    GAMEMODE.Nodes[NODE_TYPE_GROUND] = {}
    GAMEMODE.Nodes[NODE_TYPE_AIR] = {}

    local totalGround = net.ReadUInt(12)
    for i = 1, totalGround do
        GAMEMODE.Nodes[NODE_TYPE_GROUND][i] = net.ReadVector()
    end

    local totalAir = net.ReadUInt(12)
    for i = 1, totalAir do
        GAMEMODE.Nodes[NODE_TYPE_AIR][i] = net.ReadVector()
    end
end)

net.Receive("PlayOverwatchSound", function()
    surface.PlaySound(net.ReadString())
end)

net.Receive("PrintVoiceLine", function()
    if LocalPlayer():Team() != TEAM_OVERWATCH && LocalPlayer():Team() != TEAM_COMBINE then
        local ply = net.ReadEntity()
        local msg = net.ReadString()
        chat.AddText(team.GetColor(TEAM_REBELS), "(Voice) ", ply, Color(255, 255, 255),": ", msg)
    end
end)

net.Receive("RespawnTime", function()
    LocalPlayer().RespawnTime = net.ReadUInt(16)
end)

net.Receive("SetCameras", function()
    GAMEMODE.Cameras.overwatch.pos = net.ReadVector()
    GAMEMODE.Cameras.overwatch.ang = net.ReadAngle()
    OverwatchPos = GAMEMODE.Cameras.overwatch.pos

    GAMEMODE.Cameras.spectator.ang = net.ReadAngle()
end)

net.Receive("SetReviveEntity", function()
    LocalPlayer().ReviveEntity = net.ReadEntity()
end)

net.Receive("ShowOrderTarget", function()
    local ply = net.ReadEntity()
    ply.OrderType = net.ReadUInt(2)
    ply.OrderTarget = net.ReadVector()
    ply.OrderSize = 32
end)

net.Receive("ShowRoundWinner", function()
    GAMEMODE.winner = net.ReadInt(3)
end)

net.Receive("ShowSetupTimer", function()
    local countDown = net.ReadInt(5)
    GAMEMODE.countDown = countDown
end)

net.Receive("SpectatorMessage", function()
    local ply = net.ReadEntity()
    local msg = net.ReadString()
    local teamOnly = net.ReadBool()
    local prefix = "*SPEC* "
    if teamOnly then prefix = "(Spectator) " end

    if !teamOnly || (teamOnly && LocalPlayer():Team() == TEAM_SPECTATOR) then
        chat.AddText(Color(255, 255, 255),prefix, ply, ": " .. msg)
    end
end)

net.Receive("UpdateConvar", function()
    local convar = net.ReadString()
    local bits = 8
    if convar == "timelimit" then
        bits = 16
    end
    GAMEMODE.ConVars[convar].client = net.ReadUInt(bits)
end)

net.Receive("UpdateOverwatchPosition", function()
    local ply = net.ReadEntity()
    local position = net.ReadVector()
    ply:SetPos(position)
end)

net.Receive("VoteMenu", function()
    if GetRoundState() < ROUND_STARTED then
        LocalPlayer().VoteMenu = true
        LocalPlayer().VoiceMenu = false
        local count = net.ReadUInt(3)
        GAMEMODE.Nominated = {}
        for i = 1, count do
            table.insert(GAMEMODE.Nominated, net.ReadString())
        end
    end
end)