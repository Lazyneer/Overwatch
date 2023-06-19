--Add here all the maps you wish to play Overwatch on.
--By default, this list contains all the maps the Overwatch Addon has.
GM.MapCycle = {
    "ow_breach",
    "ow_breached",
    "ow_canals",
    "ow_citadel",
    "ow_crossroads",
    "owc_outbreak",
    "owc_superfortress",
    "owc_traverse"
}

--These maps require Episode 2.
if(IsMounted("ep2")) then
    table.insert(GM.MapCycle, "ow_assaulted")
    table.insert(GM.MapCycle, "ow_tunnels")
    table.insert(GM.MapCycle, "ow_whiteforest")
end

--These are the ammo limits.
--The default values are the same as HL2's values.
GM.AmmoLimits = {
    --AR2
    {60, "weapon_ar2"},
    --AR2AltFire
    {3, "weapon_ar2", true},
    --Pistol
    {150, "weapon_pistol"},
    --SMG1
    {225, "weapon_smg1"},
    --357
    {12, "weapon_357"},
    --XBowBolt
    {10, "weapon_crossbow"},
    --Buckshot
    {30, "weapon_shotgun"},
    --RPG_Round
    {3, "weapon_rpg"},
    --SMG1_Grenade
    {3, "weapon_smg1", true},
    --Grenade
    {5, "weapon_frag"}
}

--This determines how much to scale the damage from a certain weapon and group.
GM.WeaponDamageScale = {
    player = {
        weapon_smg1 = 1.5,
        weapon_rpg = 0.75
    },
    npc = {
        weapon_smg1 = 1.75
    },
    combine = {
        weapon_smg1 = 0.5,
        weapon_shotgun = 0.75,
        weapon_ar2 = 0.33
    }
}