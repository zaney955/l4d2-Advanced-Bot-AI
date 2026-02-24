::MoreBotCmd <- function ( player, args , args1) {
	BotAI.EasyPrint("botai_no_more_bot");
}

::BotStopCmd <- function ( speaker, args , args1) {
	local notBotPlayer = null;
	while(notBotPlayer = Entities.FindByClassname(notBotPlayer, "player")) {
		if(BotAI.IsPlayerEntityValid(notBotPlayer) && notBotPlayer.IsSurvivor() && !IsPlayerABot(notBotPlayer) && NetProps.GetPropInt(notBotPlayer, "m_iTeamNum") != 1 && !notBotPlayer.IsDead()) {
			return;
		}
	}

	local player = null;
	while(player = Entities.FindByClassname(player, "player")) {
		if(BotAI.IsPlayerEntityValid(player) && player.IsSurvivor() && IsPlayerABot(player)) {
			BotAI.setLastStrike(player);
			player.SetHealth(-100);
			player.TakeDamage(100, 0, player);
			VSLib.Entity(player).Ignite(100);
		}
	}
}

::BotAISkillCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(args.len() >= 1 && args[0] != null && args[0] != "") {
		local arg = args[0].tointeger();

		if(arg > 99) {
			arg = 99;
		}

		if(arg < 1) {
			arg = 1;
		}

		BotAI.BotCombatSkill = arg - 1;
		BotAI.SendPlayer(player, "botai_bot_combat_skill", 0.2, arg);
	} else {
		if(BotAI.BotCombatSkill > 0) {
			BotAI.BotCombatSkill = 0;
			BotAI.SendPlayer(player, "botai_bot_combat_skill", 0.2, 0);
		} else {
			BotAI.BotCombatSkill = 2;
			BotAI.SendPlayer(player, "botai_bot_combat_skill", 0.2, 2);
		}
	}

	BotExitMenuCmd(speaker, args, args1);
	BotAI.SaveSetting();
}

::BotFollowDistanceCmd <- function (speaker, args, args1) {
    local player = speaker;
    if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
    local input = "";
    foreach (idx, val in args) {
        input += val + " ";
    }

    input = strip(input);

    local distance = null;
    try {
        distance = input.tointeger();
    } catch (ex) {
        distance = 1500;
    }

    if (distance < 100) distance = 100;
    if (distance > 999999) distance = 999999;

    BotAI.FollowRange = distance;

	BotAI.resetFollowRange();

	BotAI.SendPlayer(player, "botai_bot_follow_distance", 0.2, distance);

    BotExitMenuCmd(speaker, args, args1);
    BotAI.SaveSetting();
}

::BotTeleportDistanceCmd <- function (speaker, args, args1) {
    local player = speaker;
    if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
    local input = "";
    foreach (idx, val in args) {
        input += val + " ";
    }

    input = strip(input);

    local distance = null;
    try {
        distance = input.tointeger();
    } catch (ex) {
        distance = 1500;
    }

    if (distance < 100) distance = 100;
    if (distance > 999999) distance = 999999;

	Convars.SetValue( "sb_enforce_proximity_range", distance );
    BotAI.TeleportDistance = distance;

	if (distance > 999990) {
		BotAI.SendPlayer(player, "botai_bot_teleport_distance_off", 0.2);
	} else {
		BotAI.SendPlayer(player, "botai_bot_teleport_distance", 0.2, distance);
	}

    BotExitMenuCmd(speaker, args, args1);
    BotAI.SaveSetting();
}

::BotSaveTeleportCmd <- function (speaker, args, args1) {
    local player = speaker;
    if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
    local input = "";
    foreach (idx, val in args) {
        input += val + " ";
    }

    input = strip(input);

    local time = null;
    try {
        time = input.tointeger();
    } catch (ex) {
        time = 9;
    }

    if (time < 0) time = 0;
    if (time > 999) time = 999;

    BotAI.SaveTeleport = time;
	if (time > 99) {
		BotAI.SendPlayer(player, "botai_bot_save_teleport_off", 0.2);
	} else {
		BotAI.SendPlayer(player, "botai_bot_save_teleport", 0.2, time);
	}

    BotExitMenuCmd(speaker, args, args1);
    BotAI.SaveSetting();
}

::BotGascanFindCmd <- function ( speaker, args  , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if(BotAI.NeedGasFinding) {
		BotAI.NeedGasFinding = false;
		BotAI.SendPlayer(player, "botai_gascan_finding_off");
	} else {
		BotAI.NeedGasFinding = true;
		BotAI.SendPlayer(player, "botai_gascan_finding_on");
	}
	BotAI.SaveSetting();
	BotExitMenuCmd(speaker, args, args1);
}

::BotThrowFireCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if(BotAI.NeedThrowMolotov) {
		BotAI.NeedThrowMolotov = false;
		BotAI.SendPlayer(player, "botai_throw_fire_off");
	} else {
		BotAI.NeedThrowMolotov = true;
		BotAI.SendPlayer(player, "botai_throw_fire_on");
	}

	BotAI.SaveSetting();
	BotExitMenuCmd(speaker, args, args1);
}

::BotThrowPipeBombCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if(BotAI.NeedThrowPipeBomb) {
		BotAI.NeedThrowPipeBomb = false;
		BotAI.SendPlayer(player, "botai_throw_pipe_off");
	} else {
		BotAI.NeedThrowPipeBomb = true;
		BotAI.SendPlayer(player, "botai_throw_pipe_on");
	}

	BotAI.SaveSetting();
	BotExitMenuCmd(speaker, args, args1);
}

::BotUseUpgradesCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if (BotAI.UseUpgrades) {
		BotAI.UseUpgrades = false;
		BotAI.SendPlayer(player, "botai_use_upgrades_off");
	} else {
		BotAI.UseUpgrades = true;
		BotAI.SendPlayer(player, "botai_use_upgrades_on");
	}

	BotAI.SaveSetting();
	BotExitMenuCmd(speaker, args, args1);
}

::BotImmunityCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.Immunity) {
		BotAI.Immunity = false;
		BotAI.SendPlayer(player, "botai_immunity_off");
	} else {
		BotAI.Immunity = true;
		BotAI.SendPlayer(player, "botai_immunity_on");
	}
	BotAI.SaveSetting();
}

::BotDefibrillatorCmd <- function ( speaker, args, args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if(BotAI.Defibrillator) {
		BotAI.Defibrillator = false;
		BotAI.SendPlayer(player, "botai_defibrillator_off");
	} else {
		BotAI.Defibrillator = true;
		BotAI.SendPlayer(player, "botai_defibrillator_on");
	}
	BotAI.SaveSetting();
}

::BotPassingItemsCmd <- function ( speaker, args, args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.PassingItems) {
		BotAI.PassingItems = false;
		BotAI.SendPlayer(player, "botai_passing_item_off");
	} else {
		BotAI.PassingItems = true;
		BotAI.SendPlayer(player, "botai_passing_item_on");
	}

	BotAI.SaveSetting();
}

::BotCloseSaferoomDoorCmd <- function ( speaker, args, args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}
	if(BotAI.CloseSaferoomDoor) {
		BotAI.CloseSaferoomDoor = false;
		Convars.SetValue( "sb_close_checkpoint_door_interval", 999 );
		BotAI.SendPlayer(player, "botai_close_door_off");
	} else {
		BotAI.CloseSaferoomDoor = true;
		Convars.SetValue( "sb_close_checkpoint_door_interval", 0.15 );
		BotAI.SendPlayer(player, "botai_close_door_on");
	}

	BotAI.SaveSetting();
}

::BotBackPackCmd <- function ( speaker, args  , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.BackPack) {
		BotAI.BackPack = false;
		BotAI.SendPlayer(player, "botai_bot_carry_off");
	} else {
		BotAI.BackPack = true;
		BotAI.SendPlayer(player, "botai_bot_carry_on");
	}
	BotAI.SaveSetting();
}

::BotAliveCmd <- function ( speaker, args  , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.NeedBotAlive) {
		BotAI.NeedBotAlive = false;
		Convars.SetValue( "sb_all_bot_game", 0);
		Convars.SetValue( "allow_all_bot_survivor_team", 0 );
		BotStopCmd(speaker, args, args1);
		BotAI.SendPlayer(player, "botai_bot_alive_off");
	} else {
		BotAI.NeedBotAlive = true;
		Convars.SetValue( "sb_all_bot_game", 1);
		Convars.SetValue( "allow_all_bot_survivor_team", 1 );
		BotAI.SendPlayer(player, "botai_bot_alive_on");
	}
	BotAI.SaveSetting();
}

::BotTeleportToSaferoomCmd <- function ( speaker, args  , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.TeleportToSaferoom) {
		BotAI.TeleportToSaferoom = false;
		BotAI.SendPlayer(player, "botai_bot_teleport_to_saferoom_off");
	} else {
		BotAI.TeleportToSaferoom = true;
		BotAI.SendPlayer(player, "botai_bot_teleport_to_saferoom_on");
	}

	BotAI.SaveSetting();
}

::BotSpreadCompensationCmd <- function ( speaker, args  , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.SpreadCompensation) {
		BotAI.SpreadCompensation = false;
		BotAI.SendPlayer(player, "botai_spread_compensation_off");
	} else {
		BotAI.SpreadCompensation = true;
		BotAI.SendPlayer(player, "botai_spread_compensation_on");
	}

	BotAI.SaveSetting();
}

::BotOverpoweredCombatBoostCmd <- function ( speaker, args  , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER") {
		player = player.GetBaseEntity();
	}

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	local enableBoost = !BotAI.IsOverpoweredCombatBoostEnabled();
	BotAI.SetOverpoweredCombatBoostEnabled(enableBoost);
	BotAI.SendPlayer(player, enableBoost ? "botai_overpowered_combat_boost_on" : "botai_overpowered_combat_boost_off");

	BotAI.SaveSetting();
}

::BotPathFindingCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.PathFinding) {
		BotAI.PathFinding = false;
		Convars.SetValue( "sb_allow_leading", 0 );
		BotAI.SendPlayer(player, "botai_path_finding_off");
	} else {
		BotAI.PathFinding = true;
		Convars.SetValue( "sb_allow_leading", 1 );
		BotAI.SendPlayer(player, "botai_path_finding_on");
		if(BotAI.PathFinding) {
			BotAI.SendPlayer(player, "botai_unstick_pathfinding");
		}
	}

	BotAI.resetFollowRange();
	BotAI.SaveSetting();
}

::BotUnstickCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.UnStick) {
		BotAI.UnStick = false;
		Convars.SetValue( "sb_unstick", 0 );
		BotAI.SendPlayer(player, "botai_unstick_off");
	} else {
		BotAI.UnStick = true;
		Convars.SetValue( "sb_unstick", 1 );
		BotAI.SendPlayer(player, "botai_unstick_on");
		if(BotAI.PathFinding) {
			BotAI.SendPlayer(player, "botai_unstick_pathfinding");
		}
	}

	BotAI.SaveSetting();
}

::BotFireProtectCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.FireProtect) {
		BotAI.FireProtect = false;
		BotAI.SendPlayer(player, "botai_fire_protect_off");
	} else {
		BotAI.FireProtect = true;
		BotAI.SendPlayer(player, "botai_fire_protect_on");
	}

	BotAI.SaveSetting();
}

::BotAcidProtectCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.AcidProtect) {
		BotAI.AcidProtect = false;
		BotAI.SendPlayer(player, "botai_acid_protect_off");
	} else {
		BotAI.AcidProtect = true;
		BotAI.SendPlayer(player, "botai_acid_protect_on");
	}

	BotAI.SaveSetting();
}

::BotNonAliveProtectCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.NonAliveProtect) {
		BotAI.NonAliveProtect = false;
		BotAI.SendPlayer(player, "botai_non_alive_protect_off");
	} else {
		BotAI.NonAliveProtect = true;
		BotAI.SendPlayer(player, "botai_non_alive_protect_on");
	}

	BotAI.SaveSetting();
}

::BotFallProtectCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.FallProtect) {
		BotAI.FallProtect = false;
		BotAI.SendPlayer(player, "botai_fall_protect_off");
	} else {
		BotAI.FallProtect = true;
		BotAI.SendPlayer(player, "botai_fall_protect_on");
	}

	BotAI.SaveSetting();
}

function BotAI::getDamageMultiplier(args, minValue = -16.0, maxValue = 999.0) {
	local defaultMultiplier = 1.0;

    local input = "";
    foreach (idx, val in args) {
        input += val + " ";
    }
    input = strip(input);

    local multiplier = null;
    try {
        multiplier = input.tofloat();
    } catch (ex) {
        multiplier = defaultMultiplier;
    }

    if (multiplier < minValue) multiplier = minValue;
    if (multiplier > maxValue) multiplier = maxValue;

	return multiplier;
}

::BotWitchDamageCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
    if (typeof player == "VSLIB_PLAYER")
        player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

    BotAI.WitchDamageMultiplier = BotAI.getDamageMultiplier(args);

    BotAI.SaveSetting();
    BotAI.SendPlayer(player, "botai_witch_damage", 0.2, BotAI.WitchDamageMultiplier);
}

::BotSpecialDamageCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
    if (typeof player == "VSLIB_PLAYER")
        player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

    BotAI.SpecialDamageMultiplier = BotAI.getDamageMultiplier(args);

    BotAI.SaveSetting();
    BotAI.SendPlayer(player, "botai_special_damage", 0.2, BotAI.SpecialDamageMultiplier);
}

::BotTankDamageCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
    if (typeof player == "VSLIB_PLAYER")
        player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

    BotAI.TankDamageMultiplier = BotAI.getDamageMultiplier(args);

    BotAI.SaveSetting();
    BotAI.SendPlayer(player, "botai_tank_damage", 0.2, BotAI.TankDamageMultiplier);
}

::BotCommonDamageCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
    if (typeof player == "VSLIB_PLAYER")
        player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

    BotAI.CommonDamageMultiplier = BotAI.getDamageMultiplier(args);

    BotAI.SaveSetting();
    BotAI.SendPlayer(player, "botai_common_damage", 0.2, BotAI.CommonDamageMultiplier);
}

::BotNonAliveDamageCmd <- function ( speaker, args , args1) {
	BotExitMenuCmd(speaker, args, args1);
	local player = speaker;
    if (typeof player == "VSLIB_PLAYER")
        player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

    BotAI.NonAliveDamageMultiplier = BotAI.getDamageMultiplier(args);

    BotAI.SaveSetting();
    BotAI.SendPlayer(player, "botai_non_alive_damage", 0.2, BotAI.NonAliveDamageMultiplier);
}

::BotBannedWeaponCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	BotExitMenuCmd(speaker, args, args1);

	if(!BotAI.BannedWeapons)
		BotAI.BannedWeapons = {};

	local weapon = args[0];
	if(weapon in BotAI.BannedWeapons) {
		delete BotAI.BannedWeapons[weapon];
		BotAI.SaveSetting();
		BotAI.SendPlayer(player, "botai_unbanned_weapon", 0.2, weapon);
	} else {
		BotAI.BannedWeapons[weapon] <- true;
		BotAI.SaveSetting();
		BotAI.SendPlayer(player, "botai_banned_weapon", 0.2, weapon);
	}
}

::BotMeleeCmd <- function ( speaker, args , args1) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.Melee) {
		BotAI.Melee = false;
		Convars.SetValue( "sb_max_team_melee_weapons", 0 );
		BotAI.SendPlayer(player, "botai_melee_off");
	} else {
		BotAI.Melee = true;
		BotAI.resetBotMeleeAction();
		BotAI.SendPlayer(player, "botai_melee_on");
	}

	BotAI.SaveSetting();
	BotExitMenuCmd(speaker, args, args1);
}

function BotAI::joinStringArray(values, delimiter = ", ") {
	local output = "";
	foreach(index, value in values) {
		if(index > 0) {
			output += delimiter;
		}
		output += value.tostring();
	}
	return output;
}

function BotAI::getDefaultMainMenuOptionOrder() {
	return [
		"bot_skill",
		"follow_range",
		"teleport_range",
		"allow_melee",
		"immunity",
		"pathfinding",
		"unstick",
		"damage_settings",
		"banned_weapons",
		"find_gas",
		"bot_alive",
		"defibrillator",
		"use_upgrades",
		"backpack",
		"non_alive_damage",
		"save_teleport",
		"fall_protect",
		"fire_protect",
		"acid_protect",
		"non_alive_protect",
		"passing_item",
		"close_door",
		"throw_pipe",
		"throw_fire",
		"teleport_to_saferoom",
		"spread_compensation",
		"overpowered_combat_boost"
	];
}

function BotAI::normalizeMainMenuOrder(orderList) {
	local validIds = {};
	foreach(id in BotAI.getDefaultMainMenuOptionOrder()) {
		validIds[id] <- true;
	}

	local normalized = [];
	local exists = {};
	if(typeof orderList != "array") {
		return normalized;
	}

	foreach(item in orderList) {
		if(typeof item != "string") {
			continue;
		}
		local id = strip(item.tolower());
		if(id == "" || !(id in validIds) || id in exists) {
			continue;
		}
		exists[id] <- true;
		normalized.append(id);
	}

	return normalized;
}

::BotMenuSortCmd <- function ( speaker, args, args1 ) {
	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	local input = "";
	foreach(idx, value in args) {
		input += value + " ";
	}
	input = strip(input.tolower());

	local allIds = BotAI.getDefaultMainMenuOptionOrder();
	local appliedIds = BotAI.normalizeMainMenuOrder(BotAI.MenuOptionOrder);
	if(input == "" || input == "show") {
		BotAI.SendPlayerNoPrefix(player, "[BotAI] !botmenusort reset");
		BotAI.SendPlayerNoPrefix(player, "[BotAI] !botmenusort id1,id2,id3");
		BotAI.SendPlayerNoPrefix(player, "[BotAI] IDs: " + BotAI.joinStringArray(allIds));
		if(appliedIds.len() > 0) {
			BotAI.SendPlayerNoPrefix(player, "[BotAI] current order: " + BotAI.joinStringArray(appliedIds));
		} else {
			BotAI.SendPlayerNoPrefix(player, "[BotAI] current order: default");
		}
		return;
	}

	if(input == "reset") {
		BotAI.MenuOptionOrder = [];
		BotAI.SaveSetting();
		BotAI.SendPlayerNoPrefix(player, "[BotAI] menu order reset to default.");
		return;
	}

	local normalizedInput = BotAI.StringReplace(input, "，", ",");
	normalizedInput = BotAI.StringReplace(normalizedInput, " ", ",");
	local splitIds = split(normalizedInput, ",");
	local validIds = {};
	foreach(id in allIds) {
		validIds[id] <- true;
	}

	local customOrder = [];
	local invalidIds = [];
	local exists = {};
	foreach(rawId in splitIds) {
		local id = strip(rawId);
		if(id == "") {
			continue;
		}
		if(!(id in validIds)) {
			invalidIds.append(id);
			continue;
		}
		if(id in exists) {
			continue;
		}
		exists[id] <- true;
		customOrder.append(id);
	}

	if(customOrder.len() == 0) {
		BotAI.SendPlayerNoPrefix(player, "[BotAI] no valid menu id found.");
		BotAI.SendPlayerNoPrefix(player, "[BotAI] IDs: " + BotAI.joinStringArray(allIds));
		return;
	}

	BotAI.MenuOptionOrder = customOrder;
	BotAI.SaveSetting();
	BotAI.SendPlayerNoPrefix(player, "[BotAI] menu order updated: " + BotAI.joinStringArray(customOrder));
	if(invalidIds.len() > 0) {
		BotAI.SendPlayerNoPrefix(player, "[BotAI] ignored ids: " + BotAI.joinStringArray(invalidIds));
	}
}

function BotAI::registerMenu() {
	local botMenu = ::HoloMenu.Menu("menu_title", BUTTON_GRENADE1);
	local function showMenu(player) {
		BotMenuCmd(player, "", "");
	}
	botMenu.registerPressEvent(showMenu);

	local pingMenu = ::HoloMenu.Menu("ping_menu", BUTTON_ALT2);
	local function openMenu(player) {
		if(BotAI.MainMenu.len() > 0)
			BotExitMenuCmd(player, "", "");
		if(!(player in BotAI.pingPoint) || !BotAI.IsAlive(BotAI.pingPoint[player])) return;
		if(!ABA_IsAdmin(player)) {
			BotAI.SendPlayer(player, "botai_admin_only");
			return;
		}
		local traceTable = {
			start = player.EyePosition()
			end =  player.EyePosition() + player.EyeAngles().Forward().Scale(9999)
			ignore = player
			mask = g_MapScript.TRACE_MASK_ALL
		}
		TraceLine(traceTable);

		if(traceTable.hit) {
			if(traceTable.enthit != null && traceTable.enthit.GetClassname() != "worldspawn" && traceTable.enthit.IsValid())
				BotAI.pingEntity[player] <- traceTable.enthit;
			else
				BotAI.pingEntity[player] <- traceTable.pos;
		}
		local lang = BotAI.language;
		local functions = pingMenu.getFilteredFunction(player);
		local function top(menu) {
			foreach(idx, func in functions) {
				menu.AddOption(I18n.getTranslationKeyByLang(lang, idx), func);
			}
		}

		local function bot(menu) {
			menu.AddOption("emp_3", BotEmptyCmd);
			menu.AddOption("emp_2", BotEmptyCmd);
			menu.AddOption("emp_0", BotEmptyCmd);
			menu.AddOption("emp_1", BotEmptyCmd);
			menu.AddOption(I18n.getTranslationKeyByLang(lang, "menu_exit"), BotExitMenuCmd);
		}

		BotAI.buildMenu(player, top, bot);
	}

	local function ping(player) {
		if(!ABA_IsAdmin(player)) {
			BotAI.SendPlayer(player, "botai_admin_only");
			return;
		}
		local point = BotAI.CanSeeOtherEntityPrintName(player, 2000, 0, g_MapScript.TRACE_MASK_ALL);
		if(!BotAI.IsEntitySurvivorBot(point)) {
			local dot = 0.98;
			foreach(bot in BotAI.SurvivorBotList) {
				local dirction = BotAI.normalize(bot.GetCenter() - player.EyePosition());
				local dotValue = dirction.Dot(player.EyeAngles().Forward());
				if(dotValue >= dot) {
					point = bot;
					dot = dotValue;
				}
			}
		}

		if(BotAI.IsEntitySurvivorBot(point)) {
			if(player in BotAI.pingPoint && BotAI.pingPoint[player] == point)
				delete BotAI.pingPoint[player];
			else
				BotAI.pingPoint[player] <- point;
			return;
		}

		if(!(player in BotAI.pingPoint) || !BotAI.IsEntityValid(BotAI.pingPoint[player])) return;

		openMenu(player);
	}
	local function filterIcon(player, functionsIn) {
		local entity = BotAI.pingEntity[player];
		local functions = {}

		if(typeof entity == "Vector") {
			foreach(idx, func in functionsIn) {
				if(idx == "ping_move" || idx == "ping_stay" || idx == "ping_follow_me" || idx == "ping_teleport")
					functions[idx] <- func;
			}
		} else if(BotAI.IsEntityValid(entity)) {
			local name = entity.GetClassname();
			if(name == "player" || name == "infected" || name == "witch") {
				foreach(idx, func in functionsIn) {
					if(idx == "ping_move" || idx == "ping_attack" || idx == "ping_follow")
						functions[idx] <- func;
				}
			} else {
				foreach(idx, func in functionsIn) {
					if(idx == "ping_move" || idx == "ping_use" || idx == "ping_stay" || idx == "ping_attack")
						functions[idx] <- func;
				}
			}
		}
		//functions["menu_exit"] <- functionsIn["menu_exit"]

		return functions;
	}
	pingMenu.registerTickEvent(30, openMenu);
	pingMenu.registerPressEvent(ping);
	HoloMenu.IconHook("ping_menu", filterIcon);
	local function convertPlayer(p) {
		if (!("VSLib" in getroottable() && "HUD" in ::VSLib)) {
			BotAI.EasyPrint("botai_no_hud");
		}

		if (typeof p == "VSLIB_PLAYER") {
			p = p.GetBaseEntity();
		}
		return p;
	}

	local function move(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		local entity  = BotAI.pingEntity[player];
		if(player in BotAI.pingPoint && BotAI.botStayPos(BotAI.pingPoint[player], entity, "ping", 4, 3))
			delete BotAI.pingPoint[player];
	}

	local function use(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		local entity  = BotAI.pingEntity[player];
		local bot = BotAI.pingPoint[player];
		local function changeAndUse() {
			if(!BotAI.IsAlive(bot)) {
				return true;
			}

			if(!BotAI.IsEntityValid(entity) || entity.GetOwnerEntity() != null) {
				return true;
			}

			if(BotAI.distanceof(entity.GetOrigin(), bot.GetOrigin()) <= 100) {
				DoEntFire("!self", "Use", "", 0, bot, entity);
				return true;
			}

			return false;
		}

		if(player in BotAI.pingPoint && BotAI.botRunPos(BotAI.pingPoint[player], entity, "ping", 4, changeAndUse))
			delete BotAI.pingPoint[player];
	}

	local function attack(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		local entity = BotAI.pingEntity[player];
		local old = null;
		if(BotAI.pingPoint[player] in BotAI.targetLocked)
			old = BotAI.targetLocked[BotAI.pingPoint[player]];
		if(old == entity)
			delete BotAI.targetLocked[BotAI.pingPoint[player]];
		else
			BotAI.targetLocked[BotAI.pingPoint[player]] <- entity;
		delete BotAI.pingPoint[player];
	}

	local function stay(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		local entity  = BotAI.pingEntity[player];
		if(player in BotAI.pingPoint && BotAI.botStayPos(BotAI.pingPoint[player], entity, "ping", 4, 9999))
			delete BotAI.pingPoint[player];
	}

	local function follow(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		if(player in BotAI.pingPoint && BotAI.botStayPos(BotAI.pingPoint[player], player, "ping", 4, 9999))
			delete BotAI.pingPoint[player];
	}

	local function teleport(player, args = "", args1 = "") {
		BotExitMenuCmd(player, args, args1);
		player = convertPlayer(player);
		local pos = BotAI.pingEntity[player];
		if(player in BotAI.pingPoint && typeof pos == "Vector") {
			BotAI.pingPoint[player].SetOrigin(pos);
			delete BotAI.pingPoint[player];
		}
	}

	//pingMenu.registerFunction("menu_exit", exit);
	pingMenu.registerFunction("ping_move", move);
	pingMenu.registerFunction("ping_use", use);
	pingMenu.registerFunction("ping_attack", attack);
	pingMenu.registerFunction("ping_stay", stay);
	pingMenu.registerFunction("ping_teleport", teleport);
	pingMenu.registerFunction("ping_follow", stay);
	pingMenu.registerFunction("ping_follow_me", follow);
	//pingMenu.registerFunction("ping_exchange", exchange);

	local testMenu = ::HoloMenu.Menu("menu_test", BUTTON_GRENADE2);
	local function test(player) {
		local navigator = BotAI.getNavigator(player);
		if(navigator.isMoving("buildTest")) {
			navigator.stop();
			return;
		}
		local traceTable = {
			start = player.EyePosition()
			end =  player.EyePosition() + player.EyeAngles().Forward().Scale(9999)
			ignore = player
			mask = g_MapScript.TRACE_MASK_SHOT
		}
		TraceLine(traceTable);

		if(traceTable.hit) {
			local function build() {
				return false;
			}

			if(BotAI.botRunPos(player, traceTable.pos, "buildTest", 0, build, 9999, true)) {
				DebugDrawCircle(traceTable.pos, Vector(0, 255, 0), 1.0, 50, true, 5);
			}
		}
	}
	testMenu.registerPressEvent(test);
}

::BotMenuCmd <- function ( speaker, args  , args1) {
	if (!("VSLib" in getroottable() && "HUD" in ::VSLib)) {
		BotAI.EasyPrint("botai_no_hud");
		return;
	}

	local player = speaker;
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!ABA_IsAdmin(speaker)) {
		BotAI.SendPlayer(player, "botai_admin_only");
		return;
	}

	if(BotAI.MainMenu.len()>0)
		BotExitMenuCmd(player, "", "");
	else
		BotAI.displayOptionMenu(player, args, args1);
}

::BotEmptyCmd <- function ( speaker, args  , args1) {}

function BotAI::setMenuNavigation(player, preCallback = null, nextCallback = null) {
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(!("MenuNavigation" in BotAI))
		BotAI.MenuNavigation <- {};

	BotAI.MenuNavigation[player.GetEntityIndex()] <- {
		pre = preCallback,
		next = nextCallback
	};
}

function BotAI::buildMenu(player, topOptions, bottomOptions) {
	// 为什么在这里要再SetLayout一次呢? 因为旧时代遗老mod Vscript Loader已经没有存在的必要了, 它的加载顺序滞后导致其他依赖Vslib的模组无法正常加载HUD, 需要有人来制裁
	HUDSetLayout( ::VSLib.HUD._hud );
	SendToConsole("bind \"1\" \"slot1; scripted_user_func slot1\"");
	SendToConsole("bind \"2\" \"slot2; scripted_user_func slot2\"");
	SendToConsole("bind \"3\" \"slot3; scripted_user_func slot3\"");
	SendToConsole("bind \"4\" \"slot4; scripted_user_func slot4\"");
	SendToConsole("bind \"5\" \"slot5; scripted_user_func slot5\"");
	SendToConsole("bind \"6\" \"slot6; scripted_user_func slot6\"");
	SendToConsole("bind \"7\" \"slot7; scripted_user_func slot7\"");
	SendToConsole("bind \"8\" \"slot8; scripted_user_func slot8\"");
	SendToConsole("bind \"9\" \"slot9; scripted_user_func slot9\"");
	SendToConsole("bind \"0\" \"slot10; scripted_user_func menu_back\"");
	SendToConsole("bind \"-\" \"scripted_user_func menu_pre\"");
	SendToConsole("bind \"=\" \"scripted_user_func menu_next\"");
	BotAI.setMenuNavigation(player, null, null);

	BotAI.playSound(player, "buttons/button14.wav");
	BotExitMenuCmd(player, "", "");
	local menu = ::HoloMenu.KeyBindMenu();
	menu.DisplayMenu(VSLib.Player(player), g_ModeScript.HUD_MID_BOX);
	menu.SetHeight(0.33);
	local lang = BotAI.language;
	if(lang == "schinese" || lang == "tchinese")
		menu.SetWidth(0.16);
	menu.SetWidth(0.24);
	menu.SetPositionY(0.36);
	BotAI.MainMenu[BotAI.MainMenu.len()] <- menu;

	menu = ::HoloMenu.KeyBindMenu("{options}");
	topOptions(menu);
	menu.AddFlag(HUD_FLAG_NOBG);
	menu.DisplayMenu(VSLib.Player(player), g_ModeScript.HUD_LEFT_TOP);
	BotAI.MainMenu[BotAI.MainMenu.len()] <- menu;

	menu = ::HoloMenu.KeyBindMenu("\n\n\n[ {name} ]\n\n{options}", 5);
	bottomOptions(menu);
	menu.AddFlag(HUD_FLAG_NOBG);
	menu.DisplayMenu(VSLib.Player(player), g_ModeScript.HUD_LEFT_BOT);
	BotAI.MainMenu[BotAI.MainMenu.len()] <- menu;
}

function BotAI::fromParams(params, lang) {
	if(params) {
		return I18n.getTranslationKeyByLang(lang, "menu_enable");
	} else
		return I18n.getTranslationKeyByLang(lang, "menu_disable");
}

function BotAI::setMenuReturnPage(player, pageIndex) {
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(player == null || !BotAI.IsPlayerEntityValid(player))
		return;

	if(!("MenuReturnPage" in BotAI))
		BotAI.MenuReturnPage <- {};

	BotAI.MenuReturnPage[player.GetEntityIndex()] <- pageIndex;
}

function BotAI::getMenuReturnPage(player) {
	if (typeof player == "VSLIB_PLAYER")
		player = player.GetBaseEntity();

	if(player == null)
		return 0;

	if(!("MenuReturnPage" in BotAI))
		return 0;

	local key = player.GetEntityIndex();
	if(!(key in BotAI.MenuReturnPage))
		return 0;

	return BotAI.MenuReturnPage[key];
}

function BotAI::displayOptionMenuReturn(player, args = "", args1 = "") {
	BotAI.displayOptionMenuPage(player, BotAI.getMenuReturnPage(player), args, args1);
}

function BotAI::getMainMenuOptionDefs(lang) {
	return [
		{ id = "bot_skill", text = I18n.getTranslationKeyByLang(lang, "menu_bot_skill") + ": " + (1 + BotAI.BotCombatSkill).tostring(), callback = BotAI.displayOptionMenuBotCombat },
		{ id = "follow_range", text = I18n.getTranslationKeyByLang(lang, "menu_follow") + ": " + (BotAI.FollowRange).tostring(), callback = BotAI.displayOptionMenuBotDistance },
		{ id = "teleport_range", text = I18n.getTranslationKeyByLang(lang, "menu_teleport") + ": " + (BotAI.TeleportDistance).tostring(), callback = BotAI.displayOptionMenuBotFollowTeleport },
		{ id = "allow_melee", text = BotAI.fromParams(BotAI.Melee, lang)+I18n.getTranslationKeyByLang(lang, "menu_take_melee"), callback = BotMeleeCmd },
		{ id = "immunity", text = BotAI.fromParams(BotAI.Immunity, lang)+I18n.getTranslationKeyByLang(lang, "menu_immunity"), callback = BotImmunityCmd },
		{ id = "pathfinding", text = BotAI.fromParams(BotAI.PathFinding, lang)+I18n.getTranslationKeyByLang(lang, "menu_pathfinding"), callback = BotPathFindingCmd },
		{ id = "unstick", text = BotAI.fromParams(BotAI.UnStick, lang)+I18n.getTranslationKeyByLang(lang, "menu_unstick"), callback = BotUnstickCmd },
		{ id = "damage_settings", text = I18n.getTranslationKeyByLang(lang, "menu_damage_settings"), callback = BotAI.displayOptionMenuDamageSettings },
		{ id = "banned_weapons", text = I18n.getTranslationKeyByLang(lang, "menu_banned_weapons"), callback = BotAI.displayOptionMenuBannedWeapons },
		{ id = "find_gas", text = BotAI.fromParams(BotAI.NeedGasFinding, lang)+I18n.getTranslationKeyByLang(lang, "menu_find_gas"), callback = BotGascanFindCmd },
		{ id = "bot_alive", text = BotAI.fromParams(BotAI.NeedBotAlive, lang)+I18n.getTranslationKeyByLang(lang, "menu_alive"), callback = BotAliveCmd },
		{ id = "defibrillator", text = BotAI.fromParams(BotAI.Defibrillator, lang)+I18n.getTranslationKeyByLang(lang, "menu_defibrillator"), callback = BotDefibrillatorCmd },
		{ id = "use_upgrades", text = BotAI.fromParams(BotAI.UseUpgrades, lang)+I18n.getTranslationKeyByLang(lang, "menu_upgrads"), callback = BotUseUpgradesCmd },
		{ id = "backpack", text = BotAI.fromParams(BotAI.BackPack, lang)+I18n.getTranslationKeyByLang(lang, "menu_carry"), callback = BotBackPackCmd },
		{ id = "non_alive_damage", text = I18n.getTranslationKeyByLang(lang, "menu_non_alive_damage") + ": " + (BotAI.NonAliveDamageMultiplier).tostring(), callback = BotAI.displayOptionMenuBotNonAliveDamage },
		{ id = "save_teleport", text = I18n.getTranslationKeyByLang(lang, "menu_save_teleport") + ": " + (BotAI.SaveTeleport).tostring(), callback = BotAI.displayOptionMenuBotTeleport },
		{ id = "fall_protect", text = BotAI.fromParams(BotAI.FallProtect, lang)+I18n.getTranslationKeyByLang(lang, "menu_fall_protect"), callback = BotFallProtectCmd },
		{ id = "fire_protect", text = BotAI.fromParams(BotAI.FireProtect, lang)+I18n.getTranslationKeyByLang(lang, "menu_fire_protect"), callback = BotFireProtectCmd },
		{ id = "acid_protect", text = BotAI.fromParams(BotAI.AcidProtect, lang)+I18n.getTranslationKeyByLang(lang, "menu_acid_protect"), callback = BotAcidProtectCmd },
		{ id = "non_alive_protect", text = BotAI.fromParams(BotAI.NonAliveProtect, lang)+I18n.getTranslationKeyByLang(lang, "menu_non_alive_protect"), callback = BotNonAliveProtectCmd },
		{ id = "passing_item", text = BotAI.fromParams(BotAI.PassingItems, lang)+I18n.getTranslationKeyByLang(lang, "menu_passing_item"), callback = BotPassingItemsCmd },
		{ id = "close_door", text = BotAI.fromParams(BotAI.CloseSaferoomDoor, lang)+I18n.getTranslationKeyByLang(lang, "menu_close_door"), callback = BotCloseSaferoomDoorCmd },
		{ id = "throw_pipe", text = BotAI.fromParams(BotAI.NeedThrowPipeBomb, lang)+I18n.getTranslationKeyByLang(lang, "menu_throw_pipe"), callback = BotThrowPipeBombCmd },
		{ id = "throw_fire", text = BotAI.fromParams(BotAI.NeedThrowMolotov, lang)+I18n.getTranslationKeyByLang(lang, "menu_throw_fire"), callback = BotThrowFireCmd },
		{ id = "teleport_to_saferoom", text = BotAI.fromParams(BotAI.TeleportToSaferoom, lang)+I18n.getTranslationKeyByLang(lang, "menu_teleport_to_saferoom"), callback = BotTeleportToSaferoomCmd },
		{ id = "spread_compensation", text = BotAI.fromParams(BotAI.SpreadCompensation, lang)+I18n.getTranslationKeyByLang(lang, "menu_spread_compensation"), callback = BotSpreadCompensationCmd },
		{ id = "overpowered_combat_boost", text = BotAI.fromParams(BotAI.OverpoweredCombatBoost, lang)+I18n.getTranslationKeyByLang(lang, "menu_overpowered_combat_boost"), callback = BotOverpoweredCombatBoostCmd }
	];
}

function BotAI::getSortedMainMenuOptions(lang) {
	local defs = BotAI.getMainMenuOptionDefs(lang);
	local sortedDefs = [];
	local used = {};
	local idMap = {};

	foreach(def in defs) {
		idMap[def.id] <- def;
	}

	local configuredOrder = BotAI.normalizeMainMenuOrder(BotAI.MenuOptionOrder);
	foreach(id in configuredOrder) {
		if(id in idMap && !(id in used)) {
			used[id] <- true;
			sortedDefs.append(idMap[id]);
		}
	}

	foreach(def in defs) {
		if(!(def.id in used)) {
			sortedDefs.append(def);
		}
	}

	return sortedDefs;
}

function BotAI::displayOptionMenuPage(player, pageIndex = 0, args = "", args1 = "") {
	local lang = BotAI.language;
	local pageSize = 9;

	local menuOptions = BotAI.getSortedMainMenuOptions(lang);
	local totalPages = (menuOptions.len() + pageSize - 1) / pageSize;
	if(totalPages < 1) {
		totalPages = 1;
	}

	if(pageIndex < 0) {
		pageIndex = 0;
	} else if(pageIndex >= totalPages) {
		pageIndex = totalPages - 1;
	}

	BotAI.setMenuReturnPage(player, pageIndex);

	local startIndex = pageIndex * pageSize;
	local endIndex = startIndex + pageSize;
	if(endIndex > menuOptions.len()) {
		endIndex = menuOptions.len();
	}

	local currentPageOptions = [];
	for(local i = startIndex; i < endIndex; i++) {
		currentPageOptions.append(menuOptions[i]);
	}

	local function makePageCallback(baseCallback, selectedPage) {
		local callback = baseCallback;
		local page = selectedPage;
		return function(p, a, a1) {
			BotAI.setMenuReturnPage(p, page);
			callback(p, a, a1);
		}
	}

	local function top(menu) {
		for(local i = 0; i < 5; i++) {
			if(i < currentPageOptions.len()) {
				local option = currentPageOptions[i];
				menu.AddOption(option.text, makePageCallback(option.callback, pageIndex));
			} else {
				menu.AddOption("emp_0", BotEmptyCmd);
			}
		}
	}

	local function bot(menu) {
		for(local i = 5; i < pageSize; i++) {
			if(i < currentPageOptions.len()) {
				local option = currentPageOptions[i];
				menu.AddOption(option.text, makePageCallback(option.callback, pageIndex));
			} else {
				menu.AddOption("emp_0", BotEmptyCmd);
			}
		}
	}

	BotAI.buildMenu(player, top, bot);

	local preCallback = null;
	local nextCallback = null;
	if(pageIndex > 0) {
		local prePage = pageIndex - 1;
		preCallback = function(p, a, a1) {
			BotAI.displayOptionMenuPage(p, prePage, a, a1);
		}
	}
	if(pageIndex < totalPages - 1) {
		local nextPage = pageIndex + 1;
		nextCallback = function(p, a, a1) {
			BotAI.displayOptionMenuPage(p, nextPage, a, a1);
		}
	}

	BotAI.setMenuNavigation(player, preCallback, nextCallback);
}

function BotAI::displayOptionMenu(player, args, args1) {
	BotAI.displayOptionMenuPage(player, 0, args, args1);
}

function BotAI::displayOptionMenuNext(player, args, args1) {
	BotAI.displayOptionMenuPage(player, 1, args, args1);
}

function BotAI::displayOptionMenuNextNext(player, args, args1) {
	BotAI.displayOptionMenuPage(player, 2, args, args1);
}

function BotAI::displayOptionMenuDamageSettings(player, args, args1) {
	local lang = BotAI.language;
	local function top(menu) {
		menu.AddOption(I18n.getTranslationKeyByLang(lang, "menu_witch_damage") + ": " + (BotAI.WitchDamageMultiplier).tostring(), BotAI.displayOptionMenuBotWitchDamage);
		menu.AddOption(I18n.getTranslationKeyByLang(lang, "menu_special_damage") + ": " + (BotAI.SpecialDamageMultiplier).tostring(), BotAI.displayOptionMenuBotSpecialDamage);
		menu.AddOption(I18n.getTranslationKeyByLang(lang, "menu_tank_damage") + ": " + (BotAI.TankDamageMultiplier).tostring(), BotAI.displayOptionMenuBotTankDamage);
		menu.AddOption(I18n.getTranslationKeyByLang(lang, "menu_common_damage") + ": " + (BotAI.CommonDamageMultiplier).tostring(), BotAI.displayOptionMenuBotCommonDamage);
		menu.AddOption("emp_0", BotEmptyCmd);
	}

	local function bot(menu) {
		menu.AddOption("emp_0", BotEmptyCmd);
		menu.AddOption("emp_0", BotEmptyCmd);
		menu.AddOption("emp_0", BotEmptyCmd);
		menu.AddOption("emp_0", BotEmptyCmd);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

function BotAI::displayOptionMenuBotCombat(player, args, args1) {
	local lang = BotAI.language;
	local function combatSkill(value) {
		local ability = [];
		ability.append(value.tostring());
		BotAISkillCmd(player, ability, "");
	}
	local function normal(player, args, args1) {
		combatSkill(1);
	}
	local function high(player, args, args1) {
		combatSkill(2);
	}
	local function ultra(player, args, args1) {
		combatSkill(3);
	}
	local function extreme(player, args, args1) {
		combatSkill(4);
	}
	local function pro(player, args, args1) {
		combatSkill(5);
	}
	local function proplus(player, args, args1) {
		combatSkill(6);
	}
	local function promax(player, args, args1) {
		combatSkill(7);
	}
	local function promax_(player, args, args1) {
		combatSkill(8);
	}
	local function promaxplus(player, args, args1) {
		combatSkill(10);
	}

	local function top(menu) {
		menu.AddOption("1", normal);
		menu.AddOption("2", high);
		menu.AddOption("3", ultra);
		menu.AddOption("4", extreme);
		menu.AddOption("5", pro);
	}

	local function bot(menu) {
		menu.AddOption("6", proplus);
		menu.AddOption("7", promax);
		menu.AddOption("8", promax_);
		menu.AddOption("10", promaxplus);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

function BotAI::displayOptionMenuBotDistance(player, args, args1) {
	local lang = BotAI.language;
	local function followDistance(value) {
		local ability = [];
		ability.append(value.tostring());
		BotFollowDistanceCmd(player, ability, "");
	}
	local function normal(player, args, args1) {
		followDistance(100);
	}
	local function high(player, args, args1) {
		followDistance(200);
	}
	local function ultra(player, args, args1) {
		followDistance(350);
	}
	local function extreme(player, args, args1) {
		followDistance(500);
	}
	local function pro(player, args, args1) {
		followDistance(700);
	}
	local function pro_(player, args, args1) {
		followDistance(850);
	}
	local function pro__(player, args, args1) {
		followDistance(1000);
	}
	local function pro___(player, args, args1) {
		followDistance(1250);
	}
	local function pro____(player, args, args1) {
		followDistance(999999);
	}

	local function top(menu) {
		menu.AddOption("100hu(1.9m)", normal);
		menu.AddOption("200hu(3.8m)", high);
		menu.AddOption("350hu(6.7m)", ultra);
		menu.AddOption("500hu(9.5m)", extreme);
		menu.AddOption("700hu(13.3m)", pro);
	}

	local function bot(menu) {
		menu.AddOption("850hu(16.2m)", pro_);
		menu.AddOption("1000hu(19.1m)", pro__);
		menu.AddOption("1250hu(23.8m)", pro___);
		menu.AddOption("999999hu(~19050m)", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

function BotAI::displayOptionMenuBotFollowTeleport(player, args, args1) {
	local lang = BotAI.language;
	local function followDistance(value) {
		local ability = [];
		ability.append(value.tostring());
		BotTeleportDistanceCmd(player, ability, "");
	}
	local function normal(player, args, args1) {
		followDistance(100);
	}
	local function high(player, args, args1) {
		followDistance(350);
	}
	local function ultra(player, args, args1) {
		followDistance(500);
	}
	local function extreme(player, args, args1) {
		followDistance(700);
	}
	local function pro(player, args, args1) {
		followDistance(1000);
	}
	local function pro_(player, args, args1) {
		followDistance(850);
	}
	local function pro__(player, args, args1) {
		followDistance(1250);
	}
	local function pro___(player, args, args1) {
		followDistance(1500);
	}
	local function pro____(player, args, args1) {
		followDistance(999999);
	}

	local function top(menu) {
		menu.AddOption("100hu(1.9m)", normal);
		menu.AddOption("350hu(6.7m)", high);
		menu.AddOption("500hu(9.5m)", ultra);
		menu.AddOption("700hu(13.3m)", extreme);
		menu.AddOption("1000hu(19.1m)", pro);
	}

	local function bot(menu) {
		menu.AddOption("850hu(16.2m)", pro_);
		menu.AddOption("1250hu(23.8m)", pro__);
		menu.AddOption("1500hu(28.6m)", pro___);
		menu.AddOption("999999hu(~19050m)", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

function BotAI::displayOptionMenuBotTeleport(player, args, args1) {
	local lang = BotAI.language;
	local function teleportDistance(value) {
		local ability = [];
		ability.append(value.tostring());
		BotSaveTeleportCmd(player, ability, "");
	}
	local function normal(player, args, args1) {
		teleportDistance(0);
	}
	local function high(player, args, args1) {
		teleportDistance(5);
	}
	local function ultra(player, args, args1) {
		teleportDistance(9);
	}
	local function extreme(player, args, args1) {
		teleportDistance(12);
	}
	local function pro(player, args, args1) {
		teleportDistance(17);
	}
	local function pro_(player, args, args1) {
		teleportDistance(25);
	}
	local function pro__(player, args, args1) {
		teleportDistance(35);
	}
	local function pro___(player, args, args1) {
		teleportDistance(50);
	}
	local function pro____(player, args, args1) {
		teleportDistance(999);
	}

	local function top(menu) {
		menu.AddOption("0(s)", normal);
		menu.AddOption("5(s)", high);
		menu.AddOption("9(s)", ultra);
		menu.AddOption("12(s)", extreme);
		menu.AddOption("17(s)", pro);
	}

	local function bot(menu) {
		menu.AddOption("25(s)", pro_);
		menu.AddOption("35(s)", pro__);
		menu.AddOption("50(s)", pro___);
		menu.AddOption("999(s)", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

function BotAI::displayOptionMenuBotWitchDamage(player, args, args1) {
	local lang = BotAI.language;
	local function damageMultiplier(value) {
		local ability = [];
		ability.append(value.tostring());
		BotWitchDamageCmd(player, ability, "");
	}

	local function normal(player, args, args1) {
		damageMultiplier(0.2);
	}
	local function high(player, args, args1) {
		damageMultiplier(0.4);
	}
	local function ultra(player, args, args1) {
		damageMultiplier(0.6);
	}
	local function extreme(player, args, args1) {
		damageMultiplier(0.8);
	}
	local function pro(player, args, args1) {
		damageMultiplier(1.0);
	}
	local function pro_(player, args, args1) {
		damageMultiplier(1.5);
	}
	local function pro__(player, args, args1) {
		damageMultiplier(2.0);
	}
	local function pro___(player, args, args1) {
		damageMultiplier(2.5);
	}
	local function pro____(player, args, args1) {
		damageMultiplier(3.0);
	}

	local function top(menu) {
		menu.AddOption("0.2", normal);
		menu.AddOption("0.4", high);
		menu.AddOption("0.6", ultra);
		menu.AddOption("0.8", extreme);
		menu.AddOption("1.0", pro);
	}

	local function bot(menu) {
		menu.AddOption("1.5", pro_);
		menu.AddOption("2.0", pro__);
		menu.AddOption("2.5", pro___);
		menu.AddOption("3.0", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuDamageSettings, null);
}

function BotAI::displayOptionMenuBotSpecialDamage(player, args, args1) {
	local lang = BotAI.language;
	local function damageMultiplier(value) {
		local ability = [];
		ability.append(value.tostring());
		BotSpecialDamageCmd(player, ability, "");
	}

	local function normal(player, args, args1) {
		damageMultiplier(0.2);
	}
	local function high(player, args, args1) {
		damageMultiplier(0.4);
	}
	local function ultra(player, args, args1) {
		damageMultiplier(0.6);
	}
	local function extreme(player, args, args1) {
		damageMultiplier(0.8);
	}
	local function pro(player, args, args1) {
		damageMultiplier(1.0);
	}
	local function pro_(player, args, args1) {
		damageMultiplier(1.5);
	}
	local function pro__(player, args, args1) {
		damageMultiplier(2.0);
	}
	local function pro___(player, args, args1) {
		damageMultiplier(2.5);
	}
	local function pro____(player, args, args1) {
		damageMultiplier(3.0);
	}

	local function top(menu) {
		menu.AddOption("0.2", normal);
		menu.AddOption("0.4", high);
		menu.AddOption("0.6", ultra);
		menu.AddOption("0.8", extreme);
		menu.AddOption("1.0", pro);
	}

	local function bot(menu) {
		menu.AddOption("1.5", pro_);
		menu.AddOption("2.0", pro__);
		menu.AddOption("2.5", pro___);
		menu.AddOption("3.0", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuDamageSettings, null);
}

function BotAI::displayOptionMenuBotTankDamage(player, args, args1) {
	local lang = BotAI.language;
	local function damageMultiplier(value) {
		local ability = [];
		ability.append(value.tostring());
		BotTankDamageCmd(player, ability, "");
	}

	local function normal(player, args, args1) {
		damageMultiplier(0.2);
	}
	local function high(player, args, args1) {
		damageMultiplier(0.4);
	}
	local function ultra(player, args, args1) {
		damageMultiplier(0.6);
	}
	local function extreme(player, args, args1) {
		damageMultiplier(0.8);
	}
	local function pro(player, args, args1) {
		damageMultiplier(1.0);
	}
	local function pro_(player, args, args1) {
		damageMultiplier(1.5);
	}
	local function pro__(player, args, args1) {
		damageMultiplier(2.0);
	}
	local function pro___(player, args, args1) {
		damageMultiplier(2.5);
	}
	local function pro____(player, args, args1) {
		damageMultiplier(3.0);
	}

	local function top(menu) {
		menu.AddOption("0.2", normal);
		menu.AddOption("0.4", high);
		menu.AddOption("0.6", ultra);
		menu.AddOption("0.8", extreme);
		menu.AddOption("1.0", pro);
	}

	local function bot(menu) {
		menu.AddOption("1.5", pro_);
		menu.AddOption("2.0", pro__);
		menu.AddOption("2.5", pro___);
		menu.AddOption("3.0", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuDamageSettings, null);
}

function BotAI::displayOptionMenuBotCommonDamage(player, args, args1) {
	local lang = BotAI.language;
	local function damageMultiplier(value) {
		local ability = [];
		ability.append(value.tostring());
		BotCommonDamageCmd(player, ability, "");
	}

	local function normal(player, args, args1) {
		damageMultiplier(0.2);
	}
	local function high(player, args, args1) {
		damageMultiplier(0.4);
	}
	local function ultra(player, args, args1) {
		damageMultiplier(0.6);
	}
	local function extreme(player, args, args1) {
		damageMultiplier(0.8);
	}
	local function pro(player, args, args1) {
		damageMultiplier(1.0);
	}
	local function pro_(player, args, args1) {
		damageMultiplier(1.5);
	}
	local function pro__(player, args, args1) {
		damageMultiplier(2.0);
	}
	local function pro___(player, args, args1) {
		damageMultiplier(2.5);
	}
	local function pro____(player, args, args1) {
		damageMultiplier(3.0);
	}

	local function top(menu) {
		menu.AddOption("0.2", normal);
		menu.AddOption("0.4", high);
		menu.AddOption("0.6", ultra);
		menu.AddOption("0.8", extreme);
		menu.AddOption("1.0", pro);
	}

	local function bot(menu) {
		menu.AddOption("1.5", pro_);
		menu.AddOption("2.0", pro__);
		menu.AddOption("2.5", pro___);
		menu.AddOption("3.0", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuDamageSettings, null);
}

function BotAI::displayOptionMenuBotNonAliveDamage(player, args, args1) {
	local lang = BotAI.language;
	local function damageMultiplier(value) {
		local ability = [];
		ability.append(value.tostring());
		BotNonAliveDamageCmd(player, ability, "");
	}

	local function normal(player, args, args1) {
		damageMultiplier(0.2);
	}
	local function high(player, args, args1) {
		damageMultiplier(0.4);
	}
	local function ultra(player, args, args1) {
		damageMultiplier(0.6);
	}
	local function extreme(player, args, args1) {
		damageMultiplier(0.8);
	}
	local function pro(player, args, args1) {
		damageMultiplier(1.0);
	}
	local function pro_(player, args, args1) {
		damageMultiplier(1.5);
	}
	local function pro__(player, args, args1) {
		damageMultiplier(2.0);
	}
	local function pro___(player, args, args1) {
		damageMultiplier(2.5);
	}
	local function pro____(player, args, args1) {
		damageMultiplier(3.0);
	}

	local function top(menu) {
		menu.AddOption("0.2", normal);
		menu.AddOption("0.4", high);
		menu.AddOption("0.6", ultra);
		menu.AddOption("0.8", extreme);
		menu.AddOption("1.0", pro);
	}

	local function bot(menu) {
		menu.AddOption("1.5", pro_);
		menu.AddOption("2.0", pro__);
		menu.AddOption("2.5", pro___);
		menu.AddOption("3.0", pro____);
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuDamageSettings, null);
}

function BotAI::displayOptionMenuBannedWeapons(player, args, args1) {
	local lang = BotAI.language;
	if(!BotAI.BannedWeapons)
		BotAI.BannedWeapons = {};

	local function addWeaponToggle(menu, weaponName, displayName) {
		local status = weaponName in BotAI.BannedWeapons;
		menu.AddOption((status ? "[x] " : "[  ] ") + displayName, function(p, a, a1) {
			local args = [weaponName];
			BotBannedWeaponCmd(p, args, "");
		});
	}
	local function top(menu) {
		addWeaponToggle(menu, "sniper_scout", I18n.getTranslationKeyByLang(lang, "weapon_scout"));
		addWeaponToggle(menu, "sniper_awp", I18n.getTranslationKeyByLang(lang, "weapon_awp"));
		addWeaponToggle(menu, "sniper_military", "Military Sniper");
		addWeaponToggle(menu, "hunting_rifle", "Hunting Rifle");
		addWeaponToggle(menu, "grenade_launcher", "Grenade Launcher");
	}

	local function bot(menu) {
		addWeaponToggle(menu, "rifle_m60", "M60");
		addWeaponToggle(menu, "autoshotgun", "Auto Shotgun");
		addWeaponToggle(menu, "shotgun_spas", "SPAS Shotgun");
		addWeaponToggle(menu, "chainsaw", "Chainsaw");
	}

	BotAI.buildMenu(player, top, bot);
	BotAI.setMenuNavigation(player, BotAI.displayOptionMenuReturn, null);
}

::BotExitMenuCmd <- function(speaker, args, args1) {
	foreach(menu in BotAI.MainMenu) {
		menu.CloseMenu();
		if (menu._autoDetach)
				menu.Detach();
	}
	BotAI.MainMenu = {};
	if("MenuNavigation" in BotAI)
		BotAI.MenuNavigation = {};
}
