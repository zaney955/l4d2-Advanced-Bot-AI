# Ban Bot From Using Sniper Scout and AWP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Prevent survivor bots from picking up or using sniper_scout and sniper_awp weapons due to their slow fire rate being inefficient for bot combat behavior.

**Architecture:** Dual-interception approach - (1) Filter during active weapon search in AI tasks, (2) Intercept and remove via item_pickup event handler when bots acquire weapons through other means (map spawn, player transfer, etc).

**Tech Stack:** Squirrel (VScript for Source Engine), VSLib event system, L4D2 NetProps API

---

### Task 1: Add Banned Weapons Configuration Table

**Files:**
- Modify: `scripts/vscripts/AIUpdateHandler.nut` (around line 75-88, in BotAI table initialization)

**Step 1: Read the target section to find exact insertion point**

Read lines 70-95 of AIUpdateHandler.nut to locate the end of the configuration tables section (after `modelMap` definition around line 88).

**Step 2: Add BannedWeapons table**

Insert after line 88 (after `modelMap` table, before `enumGround`):

```squirrel
	BannedWeapons = {
		sniper_scout = true
		sniper_awp = true
	}
```

This table will serve as the central blacklist for weapons bots should not use. Using key-value pairs (rather than an array) allows O(1) lookup performance and makes future additions straightforward.

**Step 3: Verify syntax**

Check that the comma placement is correct and the table structure matches surrounding tables like `modelMap` and `enumGround`.

**Step 4: Test in-game**

1. Start L4D2 and load any map
2. Open console and run: `script BotAI.BannedWeapons`
3. Expected output: Table containing `sniper_scout: true, sniper_awp: true`
4. If table displays correctly, proceed. If syntax error, check for missing braces or commas.

**Step 5: Commit**

```bash
git add scripts/vscripts/AIUpdateHandler.nut
git commit -m "feat: add BannedWeapons configuration table for sniper scout and awp"
```

---

### Task 2: Add Weapon Ban Check Utility Function

**Files:**
- Modify: `scripts/vscripts/ai_lib/ai_utils.nut` (after line 1357, after HasItem function)

**Step 1: Read insertion context**

Read lines 1338-1375 to see the `HasItem` function and understand the pattern. Insert the new function after `HasItem` ends (after line 1357).

**Step 2: Write IsWeaponBanned utility function**

Insert after line 1357:

```squirrel
function BotAI::IsWeaponBanned(className) {
	if(!BotAI.BannedWeapons || BotAI.BannedWeapons.len() == 0) {
		return false;
	}

	local weaponName = className;
	if (weaponName.find("weapon_") == 0) {
		weaponName = weaponName.slice(7);
	}

	return weaponName in BotAI.BannedWeapons;
}
```

This function:
- Normalizes weapon classnames by stripping "weapon_" prefix
- Checks against BannedWeapons table
- Returns boolean for easy use in conditionals
- Safely handles empty/disabled BannedWeapons table

**Step 3: Test function in console**

1. Load map with script: `map c1m1_hotel`
2. In console:
```
script BotAI.IsWeaponBanned("sniper_scout")
script BotAI.IsWeaponBanned("weapon_sniper_scout")
script BotAI.IsWeaponBanned("rifle_ak47")
```
3. Expected: First two return `true`, third returns `false`
4. If all outputs correct, proceed

**Step 4: Commit**

```bash
git add scripts/vscripts/ai_lib/ai_utils.nut
git commit -m "feat: add IsWeaponBanned utility function for weapon blacklist checking"
```

---

### Task 3: Intercept Weapon Pickup via Event Handler

**Files:**
- Modify: `scripts/vscripts/ai_lib/ai_events.nut` (lines 1-6, in OnGameEvent_item_pickup function)

**Step 1: Read current event handler**

Read lines 1-10 to see the existing `OnGameEvent_item_pickup` implementation and understand its structure.

**Step 2: Extend event handler with ban logic**

Replace lines 1-6 with:

```squirrel
::BotAI.Events.OnGameEvent_item_pickup <- function(event) {
	local p = GetPlayerFromUserID(event.userid);
	local item = event.item;

	if((item == "first_aid_kit_spawn" || item == "first_aid_kit" || item == "weapon_first_aid_kit_spawn" || item == "weapon_first_aid_kit" )&& p.IsSurvivor() && IsPlayerABot(p))
		BotAI.doAmmoUpgrades(p);

	if(BotAI.IsPlayerEntityValid(p) && IsPlayerABot(p)) {
		if(BotAI.IsWeaponBanned(item)) {
			BotAI.removeItem(p, item);

			if(BotAI.BotDebugMode) {
				printl("[Bot AI] Prevented bot from picking up banned weapon: " + item);
			}
		}
	}
}
```

Key changes:
- Added player validity check with `IsPlayerEntityValid`
- Calls `IsWeaponBanned` to check weapon
- Calls `removeItem` to delete the weapon entity
- Adds debug logging when `BotDebugMode` is enabled
- Checks both with and without "weapon_" prefix (handled by IsWeaponBanned)

**Step 3: Test pickup interception**

1. Enable debug mode: In console `script BotAI.BotDebugMode = true`
2. Start map with scout/awp spawns: `map c2m1_highway`
3. Spawn a bot: `sb_add`
4. Use ent_fire to spawn banned weapon:
```
ent_fire weapon_scout_spawn
```
5. Make bot walk over and use the weapon spawn
6. Check console for: `[Bot AI] Prevented bot from picking up banned weapon: sniper_scout`
7. Verify bot's primary weapon slot is empty (not holding scout)

**Step 4: Test player transfer scenario**

1. Load map with console command: `map c2m1_highway`
2. Add bot: `sb_add`
3. Give yourself scout: `give sniper_scout`
4. Stand directly in front of bot
5. Press +use key (default E) to attempt weapon transfer
6. Expected: Bot does not accept weapon, or immediately drops it
7. Check bot's inventory: `script BotAI.GetHeldItems(Entities.FindByClassname(null, "player"))`

**Step 5: Commit**

```bash
git add scripts/vscripts/ai_lib/ai_events.nut
git commit -m "feat: intercept and remove banned sniper weapons from bot inventory"
```

---

### Task 4: Enable Debug Mode Testing

**Files:**
- Modify: None (testing only)

**Step 1: Create debug test scenario**

In game console:
```
script BotAI.BotDebugMode = true
script BotAI.BannedWeapons.len()
```

Expected output shows table size (should be 2).

**Step 2: Test all banned weapon variations**

Test each banned weapon with both naming conventions:
```
script BotAI.IsWeaponBanned("sniper_scout")
script BotAI.IsWeaponBanned("weapon_sniper_scout")
script BotAI.IsWeaponBanned("sniper_awp")
script BotAI.IsWeaponBanned("weapon_sniper_awp")
```

All should return `true`.

**Step 3: Test non-banned weapons**

Verify normal weapons still work:
```
script BotAI.IsWeaponBanned("rifle")
script BotAI.IsWeaponBanned("weapon_hunting_rifle")
script BotAI.IsWeaponBanned("sniper_military")
```

All should return `false`.

**Step 4: Commit**

If no code changes needed, no commit required. Document test results in comments.

---

### Task 5: Final Integration Testing

**Files:**
- No file modifications (comprehensive testing)

**Step 1: Test map start weapon assignment**

1. Load campaign: `map c1m1_hotel`
2. Add 3 bots: `sb_add` (run 3 times)
3. Use all cheats: `sv_cheats 1`
4. Give bots scout weapons: `give sniper_scout` (while aiming at each bot)
5. Watch console for debug messages
6. Expected: All bots immediately drop the scout weapons

**Step 2: Test normal sniper rifle still works**

1. Give bot military sniper: `give sniper_military`
2. Verify bot keeps and can fire the weapon
3. Expected: Bot retains military sniper, functions normally

**Step 3: Test corpse looting scenario**

1. Start map: `map c2m1_highway`
2. Give yourself scout: `give sniper_scout`
3. Kill yourself: `kill`
4. Wait for bot to approach your corpse
5. Expected: Bot loots other items but ignores sniper_scout

**Step 4: Verify performance impact is minimal**

1. Monitor console for SCRIPT PERF warnings
2. Run through a full chapter with bots
3. Expected: No increase in script perf warnings compared to baseline

**Step 5: Document feature**

Add comment in AIUpdateHandler.nut near BannedWeapons table:
```squirrel
	// Weapons banned from bot use due to inefficiency
	// Add weapons here to prevent bots from picking them up
```

**Step 6: Final commit**

```bash
git add scripts/vscripts/AIUpdateHandler.nut
git commit -m "docs: add comments for BannedWeapons configuration table"
```

---

### Additional Notes

**Dependencies:**
- VSLib must be loaded (rayman1103_vslib)
- BotAI core system must be initialized
- `removeItem` function must exist in ai_utils.nut (already implemented at line 961)

**Common Issues:**
- If bots still pick up weapons: Check that item_pickup event is properly registered in VSLib
- If `removeItem` fails: Verify entity is valid before calling .Kill()
- If performance drops: Add cache layer for IsWeaponBanned calls

**Future Extensions:**
- Add convar to toggle bans: `aba_ban_scout 0/1`
- Add menu option in !botmenu for weapon preferences
- Extend to other slow-firing weapons if needed

**Testing Checklist:**
- [ ] BannedWeapons table initialized correctly
- [ ] IsWeaponBanned returns correct boolean values
- [ ] Bots ignore scout/awp on ground
- [ ] Bots drop scout/awp if given by player
- [ ] Bots drop scout/awp if spawned directly
- [ ] Normal weapons (rifle, military_sniper) still work
- [ ] No script performance degradation
- [ ] Debug mode shows helpful messages
