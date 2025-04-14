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
    [FireElName]     = "fireball",
    [FrostElName]    = "frostbolt",
    [ArcaneElName]   = "arcane rupture",
    [NatureElName]   = "shoot",
}

local warlockSpells = {
    [FireElName]     = "Shadowbolt",
    [NatureElName]   = "shoot",
    [ShadowElName]   = "Firebolt",
}

local priestSpells = {
    [NatureElName]   = "shoot",
    [ShadowElName]   = "shadow word: pain",
}

local druidSpells = {
    [ArcaneElName]     = "Starfire",
    [NatureElName]     = "Wrath",
    [PhysicalElName]   = "Warn",
}

local hunterSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Arcane Shot",
    [NatureElName]     = "Serpent string",
    [PhysicalElName]   = "Warn",
}

local rogueSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Warn",
    [NatureElName]     = "Warn",
    [PhysicalElName]   = "Warn",
}

local warriorSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Warn",
    [NatureElName]     = "Warn",
    [PhysicalElName]   = "Warn",
}

local paladinSpells = {
    [FireElName]       = "Warn",
    [FrostElName]      = "Warn",
    [ArcaneElName]     = "Arcane Shot",
    [NatureElName]     = "Repentance",
    [PhysicalElName]   = "Warn",
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
    if not zzcontains(pclasses, playerclass) then
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
            --DEFAULT_CHAT_FRAME:AddMessage(UnitName(unit) .. " targetted correctly")
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

        -- Define the custom message from the affinityMessages table
        local customMsg = affinityMessages[elementalName]
        if customMsg then
            DEFAULT_CHAT_FRAME:AddMessage(elementalName .. " detected, " .. customMsg, 1, 0, 0)
        end

        rrPrepEngagement(elementalName)
        rrCastTheThing(elementalName)
    end
end

function rrPrepEngagement(elementalName)
    -- Optional prep message or logic
end

function rrCastTheThing(elementalName)
    local abilities = pclasses[playerclass]
    if zzcontains(abilities, elementalName) then
        local ability = string.lower(abilities[elementalName])
        if ability ~= "warn" and ability ~= "shoot" then
            CastSpellByName(ability)
        end
    end
end

function zzcontains(ttable, titem)
    for i in ttable do
        if i == titem then return true end
    end
    return false
end

function zzcontainsKey(ttable, titem)
    for i, v in ipairs(ttable) do
        if i == titem then return true end
    end
    return false
end

SLASH_RRSCAN1 = "/rrscan"
SlashCmdList["RRSCAN"] = function(msg)
    rrScan(msg)
end