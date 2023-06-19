GM.AmmoCount = {
    item_ammo_357           = {"357", 6},
    item_ammo_357_large     = {"357", 12},
    item_ammo_ar2           = {"AR2", 20},
    item_ammo_ar2_altfire   = {"AR2AltFire", 1},
    item_ammo_ar2_large     = {"AR2", 60},
    item_ammo_crossbow      = {"XBowBolt", 6},
    item_ammo_pistol        = {"Pistol", 20},
    item_ammo_pistol_large  = {"Pistol", 100},
    item_ammo_smg1          = {"SMG1", 45},
    item_ammo_smg1_grenade  = {"SMG1_Grenade", 1},
    item_ammo_smg1_large    = {"SMG1", 225},
    item_box_buckshot       = {"Buckshot", 20},
    item_rpg_round          = {"RPG_Round", 1}
}

GM.Cameras = {
    overwatch = {},
    spectator = {}
}

GM.ConVars = {
    maxrounds = {
        convar = CreateConVar("ow_maxrounds", 10, FCVAR_REPLICATED, "Maximum number of rounds to play before server changes maps. Set to 0 to disable.", 0, math.pow(2, 8) - 1),
        client = GetConVar("ow_maxrounds"):GetInt(),
        played = 0
    },
    timelimit = {
        convar = CreateConVar("ow_timelimit", 1800, FCVAR_REPLICATED, "Time on each map, in seconds. Map changes after time expired and the round has ended. Set to 0 to disable.", 0, math.pow(2, 16) - 1),
        client = GetConVar("ow_timelimit"):GetInt(),
        start = 0
    },
    damage = {
        players = CreateConVar("ow_damagescale_players", 1, FCVAR_REPLICATED, "Damage scale for damage dealt by players."),
        npcs =    CreateConVar("ow_damagescale_npc", 1,     FCVAR_REPLICATED, "Damage scale for damage dealt by NPCs.")
    },
    spectator = CreateConVar("ow_allow_spectator_control", 1, FCVAR_REPLICATED, "Allow spectators to control NPCs.", 0, 1),
    cooldown = CreateConVar("ow_cooldownscale", 1, FCVAR_REPLICATED, "Cooldown scale."),
    multiple = CreateConVar("ow_multiple_overwatch", 6, FCVAR_REPLICATED, "Select multiple Overwatches at a 1:N ratio. 0 to disable.")
    
}

GM.Nodes = {}
GM.Nominated = {}

GM.OverwatchNPCBlacklist = {
    bullseye_strider_focus  = true,
    npc_advisor             = true,
    npc_alyx                = true,
    npc_antlion             = true,
    npc_antlion_grub        = true,
    npc_antlionguard        = true,
    npc_barnacle            = true,
    npc_barney              = true,
    npc_blob                = true,
    npc_breen               = true,
    npc_bullseye            = true,
    npc_citizen             = true,
    npc_combinedropship     = true,
    npc_combinegunship      = true,
    npc_crow                = true,
    npc_dog                 = true,
    npc_eli                 = true,
    npc_enemyfinder         = true,
    npc_fastzombie          = true,
    npc_fastzombie_torso    = true,
    npc_fisherman           = true,
    npc_furniture           = true,
    npc_gman                = true,
    npc_grenade_frag        = true,
    npc_headcrab            = true,
    npc_headcrab_black      = true,
    npc_headcrab_fast       = true,
    npc_headcrab_poison     = true,
    npc_heli_avoidsphere    = true,
    npc_hunter_maker        = true,
    npc_ichthyosaur         = true,
    npc_kleiner             = true,
    npc_launcher            = true,
    npc_magnusson           = true,
    npc_missiledefense      = true,
    npc_monk                = true,
    npc_mossman             = true,
    npc_pigeon              = true,
    npc_poisonzombie        = true,
    npc_puppet              = true,
    npc_rollermine          = true,
    npc_seagull             = true,
    npc_sniper              = true,
    npc_spotlight           = true,
    npc_turret_ceiling      = true,
    npc_turret_floor        = true,
    npc_turret_ground       = true,
    npc_vortigaunt          = true,
    npc_zombie              = true,
    npc_zombie_torso        = true,
    npc_zombine             = true
}

GM.OverwatchNPCEnemy = {
    npc_antlion             = true,
    npc_antlionguard        = true,
    npc_barnacle            = true,
    npc_fastzombie          = true,
    npc_fastzombie_torso    = true,
    npc_headcrab            = true,
    npc_headcrab_black      = true,
    npc_headcrab_fast       = true,
    npc_headcrab_poison     = true,
    npc_poisonzombie        = true,
    npc_vortigaunt          = true,
    npc_zombie              = true,
    npc_zombie_torso        = true,
    npc_zombine             = true
}

GM.OverwatchNPCNoUnitCap = {
    npc_clawscanner     = true,
    npc_combinegunship  = true,
    npc_cscanner        = true,
    npc_helicopter      = true,
    npc_manhack         = true,
    npc_sniper          = true
}

GM.OverwatchNPCSpectator = {
    npc_combine_s       = true,
    npc_metropolice     = true,
}

GM.OverwatchNPCAir = {
    npc_helicopter      = true,
    npc_strider         = true
}

GM.Textures = {
    ability_chopperbomb =  Material("gm/abilities/ability_chopperbomb.vmt"),
    ability_empty =        Material("gm/abilities/ability_empty.vmt"),
    ability_grenade =      Material("gm/abilities/ability_grenade.vmt"),
    ability_hoppermine =   Material("gm/abilities/ability_hoppermine.vmt"),
    ability_strider =      Material("gm/abilities/ability_stridercannon.vmt"),

    cursor_attack =        Material("gm/cursor/cursor_attack.vmt"),
    cursor_attackmove =    Material("gm/cursor/cursor_attack_move.vmt"),
    cursor_button =        Material("gm/cursor/cursor_button.vmt"),
    cursor_bottom =        Material("gm/cursor/cursor_edge_bottom.vmt"),
    cursor_left =          Material("gm/cursor/cursor_edge_left.vmt"),
    cursor_right =         Material("gm/cursor/cursor_edge_right.vmt"),
    cursor_top =           Material("gm/cursor/cursor_edge_top.vmt"),
    cursor_move =          Material("gm/cursor/cursor_move.vmt"),
    cursor_normal =        Material("gm/cursor/cursor_normal.vmt"),
    cursor_select =        Material("gm/cursor/cursor_select.vmt"),

    hud_defender =         Material("hud/roles/hud_defender.vmt"),
    hud_medic =            Material("hud/roles/hud_medic.vmt"),

    onclick_attack =       Material("gm/effects/onclick_attack.vmt"),
    onclick_attackmove =   Material("gm/effects/onclick_attackmove.vmt"),
    onclick_move =         Material("gm/effects/onclick_move.vmt"),

    attack =       Material("gm/orders/order_attack.vmt"),
    attackmove =   Material("gm/orders/order_attackmove.vmt"),
    kill =         Material("gm/orders/order_kill.vmt"),
    move =         Material("gm/orders/order_move.vmt"),
    stop =         Material("gm/orders/order_stop.vmt"),

    allied =       Material("gm/selection/allied.vmt"),
    enemy =        Material("gm/selection/enemy.vmt"),
    selected =     Material("gm/selection/selected.vmt"),
    highlighted =  Material("gm/selection/highlighted.vmt"),

    arrow =        Material("icons/arrows/hint_arrow.vmt"),
    medpack =      Material("icons/hints/medpack.vmt"),
    riotshield =   Material("icons/hints/riotshield.vmt"),

    defender =     Material("icons/spotting/defender.vmt"),
    medic =        Material("icons/spotting/medic.vmt"),
    player =       Material("icons/spotting/player.vmt"),
    revive =       Material("icons/spotting/reviver.vmt"),

    icon =         Material("vgui/menu/ow_logo.vmt")
}