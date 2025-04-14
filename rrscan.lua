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
    [FireElName]       = "fireball",
    [FrostElName]      = "frostbolt",
    [ArcaneElName]     = "arcane rupture",
    [NatureElName]     = "shoot",
	[PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
}

local warlockSpells = {
    [FireElName]       = "Immolate",
	[FrostElName]      = "Warn",
	[ArcaneElName]     = "Warn",
    [NatureElName]     = "shoot",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Shadow Bolt",
}

local priestSpells = {
	[FireElName]       = "Warn",
	[FrostElName]      = "Warn",
	[ArcaneElName]     = "Warn",
    [NatureElName]     = "shoot",
	[PhysicalElName]   = "Warn",
    [ShadowElName]     = "Shadow Word: Pain",
}

local druidSpells = {
	[FireElName]       = "Warn",
	[FrostElName]      = "Warn",
    [ArcaneElName]     = "Starfire",
    [NatureElName]     = "Wrath",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
}

local hunterSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Arcane Shot",
    [NatureElName]     = "Serpent string",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
}

local rogueSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Warn",
    [NatureElName]     = "Warn",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
}

local warriorSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Warn",
    [NatureElName]     = "Warn",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
}

local paladinSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Warn",
    [NatureElName]     = "Warn",
    [PhysicalElName]   = "Warn",
	[ShadowElName]     = "Warn",
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

function rrScan(DefaultSpellName)
    playerclass = string.lower(UnitClass("player"))
    if not pclasses[playerclass] then
        CastSpellByName(DefaultSpellName)
        return
    end

    local ttoriginalTarget = ""
    local previousTarget = false
    local skipping = true
    local engaging = false
    local unit = "target"

    if UnitExists(unit) then  
        ttoriginalTarget = string.lower(UnitName(unit))
        previousTarget = true
        for i, v in ipairs(EleTargets) do
            if string.lower(v) == ttoriginalTarget then
                engaging = true
                rrEngageElemental(v, true)
                return
            end
        end
    end

    for i, v in ipairs(EleTargets) do
        TargetByName(v)
        if UnitExists(unit) and (string.lower(UnitName(unit)) == string.lower(v)) then
            local unNotAttackable = not UnitIsVisible(unit) or UnitIsFriend(unit, "player")
            local unDead = not (UnitHealth(unit) > 0) or UnitIsDeadOrGhost(unit)
            if not (unNotAttackable or unDead) then
                skipping = false
                rrEngageElemental(v, false)
                engaging = true
            end
        end
        if not skipping then break end
    end

    if skipping and previousTarget then
        TargetByName(ttoriginalTarget)
        CastSpellByName(DefaultSpellName)
    else
        if not engaging then ClearTarget() end
    end
end

function rrEngageElemental(elementalName, continuing)
    if continuing then
        rrCastTheThing(elementalName)
    else
        PlaySound("GLUECREATECHARACTERBUTTON", "master")
        local customMsg = affinityMessages[elementalName]
        if customMsg then
            DEFAULT_CHAT_FRAME:AddMessage(elementalName .. " detected, " .. customMsg, 1, 0, 0)
        end
        rrPrepEngagement(elementalName)
        rrCastTheThing(elementalName)
    end
end

function rrPrepEngagement(elementalName)
    -- Placeholder for future logic if needed
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
                end
                return
            elseif elementalName == ArcaneElName or elementalName == NatureElName then
                if not isInMoonkinForm() then
                    cancelShapeshiftForm()
                end
                -- DO NOT return here! We still want to cast the spell (e.g., Wrath or Starfire)
            end
        end

        if ability ~= "warn" then
            if ability == "shoot" then
                for i = 1, 120 do
                    if IsAutoRepeatAction(i) then
                        return -- already wanding
                    end
                end
            end
            CastSpellByName(ability)
        end
    end
end

SLASH_RRSCAN1 = "/rrscan"
SlashCmdList["RRSCAN"] = function(msg)
    rrScan(msg)
end