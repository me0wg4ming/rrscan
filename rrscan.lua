local FireElName       = "Red Affinity"
local FrostElName      = "Blue Affinity"
local ArcaneElName     = "Mana Affinity"
local NatureElName     = "Green Affinity"
local ShadowElName     = "Black Affinity"
local PhysicalElName   = "Crystal Affinity"
local playerclass        

local affinityMessages = {
	[FireElName]     = "CAST FIRE SPELLS!",
	[FrostElName]    = "CAST FROST SPELLS!",
	[ArcaneElName]   = "CAST ARCANE SPELLS!",
	[NatureElName]   = "CAST NATURE SPELLS!",
	[ShadowElName]   = "CAST SHADOW SPELLS!",
	[PhysicalElName] = "SMASH IT WITH PHYSICAL DAMAGE!",
}

local EleTargets = {
	FireElName, FrostElName, ArcaneElName,
	NatureElName, ShadowElName, PhysicalElName
}

local mageSpells = {
	[FireElName]       = "Fireball",
	[FrostElName]      = "Frostbolt",
	[ArcaneElName]     = "Arcane Rupture",
	[NatureElName]     = "shoot",
	[PhysicalElName]   = "cantattack",
	[ShadowElName]     = "cantattack",
}

local warlockSpells = {
	[FireElName]       = "Immolate",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "cantattack",
	[NatureElName]     = "shoot",
	[PhysicalElName]   = "cantattack",
	[ShadowElName]     = "Shadow Bolt",
}

local priestSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "cantattack",
	[NatureElName]     = "shoot",
	[PhysicalElName]   = "cantattack",
	[ShadowElName]     = "Shadow Word: Pain",
}

local druidSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "Starfire",
	[NatureElName]     = "Wrath",
	[PhysicalElName]   = "physical",
	[ShadowElName]     = "cantattack",
}

local hunterSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "Arcane Shot",
	[NatureElName]     = "Serpent Sting",
	[PhysicalElName]   = "physical",
	[ShadowElName]     = "cantattack",
}

local rogueSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "cantattack",
	[NatureElName]     = "cantattack",
	[PhysicalElName]   = "physical",
	[ShadowElName]     = "cantattack",
}

local warriorSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "cantattack",
	[NatureElName]     = "cantattack",
	[PhysicalElName]   = "physical",
	[ShadowElName]     = "cantattack",
}

local paladinSpells = {
	[FireElName]       = "cantattack",
	[FrostElName]      = "cantattack",
	[ArcaneElName]     = "cantattack",
	[NatureElName]     = "cantattack",
	[PhysicalElName]   = "physical",
	[ShadowElName]     = "cantattack",
}

local pclasses = {
	["mage"]      = mageSpells,
	["warlock"]   = warlockSpells,
	["priest"]    = priestSpells,
	["druid"]     = druidSpells,
	["hunter"]    = hunterSpells,
	["rogue"]     = rogueSpells,
	["warrior"]   = warriorSpells,
	["paladin"]   = paladinSpells,
}

function rrScan(safeDefaultSpell)
	playerclass = string.lower(UnitClass("player"))
	if not pclasses[playerclass] then
		CastSpellByName(safeDefaultSpell)
		return
	end

	local engaging = false
	local unit = "target"

	-- Check if current target is an Affinity
	if UnitExists(unit) then  
		local currentTargetName = string.lower(UnitName(unit))
		for i, v in ipairs(EleTargets) do
			if string.lower(v) == currentTargetName then
				local unNotAttackable = UnitIsFriend("player", unit)
				local unDead = not (UnitHealth(unit) > 0) or UnitIsDeadOrGhost(unit)
				local ability = string.lower(pclasses[playerclass][v] or "")
				if not (unNotAttackable or unDead) and ability ~= "cantattack" then
					engaging = true
					rrEngageElemental(v, true)
					return
				end
			end
		end
	end

	-- Scan for alive Affinity
	for i, v in ipairs(EleTargets) do
		local ability = string.lower(pclasses[playerclass][v] or "")
		if ability ~= "cantattack" then
			if targetAliveElementalByName(v) then
				rrEngageElemental(v, false)
				engaging = true
				break
			end
		end
	end

	-- No Affinity engaged — fallback spell and clear target only if needed
if not engaging then
	if safeDefaultSpell and safeDefaultSpell ~= "" then
		CastSpellByName(safeDefaultSpell)
		return true
	end
	return false
end
	return true
end



function rrEngageElemental(elementalName, continuing)
	if continuing then
		rrCastTheThing(elementalName)
	else
		local ability = string.lower(pclasses[playerclass][elementalName] or "")
		if ability ~= "cantattack" then
			PlaySound("GLUECREATECHARACTERBUTTON")
			local customMsg = affinityMessages[elementalName]
			if customMsg then
				DEFAULT_CHAT_FRAME:AddMessage(elementalName .. " detected, " .. customMsg, 1, 0, 0)
			end
		end
		rrPrepEngagement(elementalName)
		rrCastTheThing(elementalName)
	end
end

function rrPrepEngagement(elementalName)
	SpellStopCasting()
end

function isInCatForm()
	for i = 1, GetNumShapeshiftForms() do
		local name, _, isActive = GetShapeshiftFormInfo(i)
		if isActive and i == 3 then
			return true
		end
	end
	return false
end

function isInMoonkinForm()
	for i = 1, 40 do
		local buff = UnitBuff("player", i)
		if buff and string.find(buff, "Moonkin") then
			return true
		end
	end
	return false
end

function cancelShapeshiftForm()
	for i = 1, 40 do
		local icon = UnitBuff("player", i)
		if icon then
			local _, _, buffTexture = UnitBuff("player", i)
			if buffTexture and string.find(buffTexture, "Ability_") then
				CancelPlayerBuff(i)
				break
			end
		end
	end
end

function rrCastTheThing(elementalName)
	local abilities = pclasses[playerclass]
	if abilities and abilities[elementalName] then
		local ability = string.lower(abilities[elementalName])

		if playerclass == "druid" then
			if elementalName == PhysicalElName then
				if not isInCatForm() then
					cancelShapeshiftForm()
					CastSpellByName("Cat Form")
				else
					CastSpellByName("Claw")
				end
				return
			elseif elementalName == ArcaneElName or elementalName == NatureElName then
				if not isInMoonkinForm() then
					cancelShapeshiftForm()
				end
			end
		end

		if ability ~= "cantattack" then
			if ability == "shoot" then
				for i = 1, 120 do
					if IsAutoRepeatAction(i) then
						return
					end
				end
			end
			CastSpellByName(ability)
		end
	end
end

function targetAliveElementalByName(name)
	ClearTarget()
	for i = 1, 10 do
		TargetNearestEnemy()
		if UnitExists("target") then
			local unitName = string.lower(UnitName("target") or "")
			local isDead = UnitIsDeadOrGhost("target") or UnitHealth("target") <= 0
			local isFriend = UnitIsFriend("player", "target")

			if not isDead and not isFriend and unitName == string.lower(name) then
				return true -- ✅ found the live affinity — stop scanning
			end
		end
	end
	return false
end

SLASH_RRSCAN1 = "/rrscan"
SlashCmdList["RRSCAN"] = function(msg)
	local didSomething = rrScan(msg)
	if not didSomething and (not msg or msg == "") then
	end
end
