GM.Name 	= "Overwatch"
GM.Author 	= "Lazyneer"
GM.Email 	= "N/A"
GM.Website 	= "lazyneer.com"

team.SetUp(TEAM_SPECTATOR, "Spectators", Color(205, 205, 205))
team.SetUp(TEAM_OVERWATCH, "Overwatch", Color(0, 160, 240))
team.SetUp(TEAM_REBELS, "Rebels", Color(240, 160, 0))
team.SetUp(TEAM_COMBINE, "Combine", Color(0, 160, 240))

GM.Version = "1.2.3"
GM.FriendlyFire = false  

buttonMaterials = {}

function GM:ShouldCollide(ent1, ent2)
    if ent1:IsPlayer() && ent2:GetClass() == "func_brush" then
        if ent1:Team() == TEAM_COMBINE && ent2:GetNWBool("Barrier") then
            return false
        end
    elseif ent1:IsPlayer() && ent2:IsPlayer() then
        if ent1:Team() == ent2:Team() then
            return GAMEMODE.FriendlyFire
        end
    elseif ent1:IsPlayer() && ent2:IsVehicle() then
        if ent2:GetDriver():IsValid() then
            return false
        end
    end
    return true
end

function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
    if GAMEMODE.DisableWeaponSwitch == nil then
        GAMEMODE.DisableWeaponSwitch = {}
        GAMEMODE.DisableWeaponSwitch[ply:EntIndex()] = false
    end
    return GAMEMODE.DisableWeaponSwitch[ply:EntIndex()]
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
    if(IsValid(ply) && !ply:Alive()) then
		return true
    end
    
    if ply:Team() == TEAM_COMBINE then
        if foot == 0 then
            ply:EmitSound("NPC_MetroPolice.RunFootstepLeft")
        else
            ply:EmitSound("NPC_MetroPolice.RunFootstepRight")
        end
        return true
    end
end

function GetUnitCount()
    countNPCs = 0
    for _, ent in pairs(ents.GetAll()) do
        if ent:IsNPC() && IsValid(ent) && !ent:GetNWBool("FreeUnit") && !ent:IsDormant() && !GAMEMODE.OverwatchNPCBlacklist[ent:GetClass()] && !GAMEMODE.OverwatchNPCNoUnitCap[ent:GetClass()] && ent:Health() > 0 then
            countNPCs = countNPCs + 1
        end
    end
    return countNPCs
end

function SanitizeMapName(map)
    local exploded = string.Explode("_", map)
    local mapName = ""
    if #exploded > 2 then
        for k, v in pairs(exploded) do
            if k > 1 then
                mapName = mapName .. " " .. v:gsub("^%l", string.upper)
            end
        end
    else
        if #exploded > 1 then
            mapName = exploded[2]:gsub("^%l", string.upper)
        else
            mapName = exploded[1]:gsub("^%l", string.upper)
        end
    end
    return mapName
end

function StrEqual(a, b)
    return string.lower(a) == string.lower(b)
end