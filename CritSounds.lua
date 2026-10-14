local InCombat = false
local RecentCrits = 0
local RecentHits = 0
local CritsHappening = false
local StopLoggingHits = false
local EstimatedCritRate = 30
local FirstEstimateDone = false
local SecondEstimateDone = false
local CRIT_CAST_WINDOW = 0.3 -- seconds after your own cast in which a crit heal counts as a direct heal (solo only)
local LastCritKey = nil
local LastCritTime = 0
local LastOwnCast = 0

function CritSounds:OnCombatLogEventUnfiltered()
    --See https://warcraft.wiki.gg/wiki/COMBAT_LOG_EVENT for more info on these
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName,
        spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = CombatLogGetCurrentEventInfo()

    if self.db.profile.isEnabled and (sourceGUID == UnitGUID("player") or CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)) then

        local isPet = sourceGUID ~= UnitGUID("player")

        if (amount ~= nil and type(amount) == "number" or (subevent == "SWING_DAMAGE" and spellID ~= nil and type(spellID) == "number")) then
            if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") then
                if (resisted == true and spellName ~= nil) then --resisted in this case is crit for the _HEAL event (18th param)
                    local trigger = (subevent == "SPELL_PERIODIC_HEAL") and "hots" or "heals"
                    CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack, trigger);
                end
            else
                if (critical == true or (subevent == "SWING_DAMAGE" and resisted == true)) then --swing_damage also lacks 3 params most other _damage has
                    local trigger
                    if isPet then
                        trigger = "petAttacks"
                    elseif subevent == "SWING_DAMAGE" then
                        trigger = "autoAttacks"
                    elseif subevent == "SPELL_PERIODIC_DAMAGE" then
                        trigger = "dots"
                    end
                    CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack, trigger);
                end
            end
        end

    end
end

function CritSounds:CastSuccess(eventLogName, unitTarget, castGUID, spellID, castBarID)

    if (self.db.profile.isEnabled and (unitTarget == "player" or unitTarget == "pet")) then

        LastOwnCast = GetTime()

        -- solo uses real crits from UnitCombatValidator, so only simulate in a group
        if (InCombat and CritsHappening and IsInGroup()) then

            local simulatedCrit = CritSounds_SimulateCrit()
            if (simulatedCrit) then
                CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack);
            end

        end

    end

end

function CritSounds:UnitCombatValidator(eventLogName, unitTarget, event, flagText, amount, schoolMask)

    -- solo needs "target" events for real crits; in a group they stay ignored as before
    local ignoreEvent = unitTarget == "focus" or (unitTarget == "target" and IsInGroup())
    if (ignoreEvent) then
        return
    end

    local isEnemy = string.find(unitTarget, "arena") or string.find(unitTarget, "boss") or string.find(unitTarget, "nameplate")
        or ((unitTarget == "target" or unitTarget == "softenemy") and UnitCanAttack("player", unitTarget))

    -- same hit seen through another unit token (target + nameplate1)
    local now = GetTime()
    local key = (UnitGUID(unitTarget) or unitTarget) .. ":" .. tostring(amount) .. ":" .. tostring(flagText)
    if (key == LastCritKey and now == LastCritTime) then
        return
    end
    LastCritKey = key
    LastCritTime = now

    -- solo: play on the real crit
    if (flagText == "CRITICAL" and not IsInGroup()) then
        if (event == "WOUND" and isEnemy and InCombat) then
            CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack);
        elseif (event == "HEAL" and (unitTarget == "player" or unitTarget == "pet" or (unitTarget == "target" and UnitCanAssist("player", unitTarget)))) then
            -- right after your own cast = direct heal, otherwise assume a HoT tick
            local trigger = (now - LastOwnCast <= CRIT_CAST_WINDOW) and "heals" or "hots"
            CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack, trigger);
        end
    end

    if (flagText == "CRITICAL" and
        ((event == "WOUND" and isEnemy) or
        (event == "HEAL" and not isEnemy))) then

        CritsHappening = true;

        if (not StopLoggingHits) then
            RecentCrits = RecentCrits + 1
            RecentHits = RecentHits + 1
        end

    elseif ((event == "WOUND" and isEnemy) or
        (event == "HEAL" and not isEnemy)) then

        if (not StopLoggingHits) then
            RecentHits = RecentHits + 1
        end

    end

    if (RecentHits > 200) then

        EstimatedCritRate = (RecentCrits / RecentHits) * 100
        StopLoggingHits = true --just in case this causes lag

    elseif (RecentHits > 70 and not SecondEstimateDone) then

        EstimatedCritRate = (RecentCrits / RecentHits) * 100
        SecondEstimateDone = true

    elseif (RecentHits > 20 and not FirstEstimateDone) then

        EstimatedCritRate = (RecentCrits / RecentHits) * 100
        FirstEstimateDone = true

    end

end

function CritSounds:LeftCombat(eventLogName)

    InCombat = false
    CritsHappening = false
    RecentCrits = 0
    RecentHits = 0
    StopLoggingHits = false
    EstimatedCritRate = 30
    FirstEstimateDone = false
    SecondEstimateDone = false
    LastCritKey = nil
    LastCritTime = 0

end

function CritSounds:EnteredCombat(eventLogName)

    InCombat = true
    CritsHappening = false
    RecentCrits = 0
    RecentHits = 0
    StopLoggingHits = false
    EstimatedCritRate = 30
    FirstEstimateDone = false
    SecondEstimateDone = false
    LastCritKey = nil
    LastCritTime = 0

end

function CritSounds_SimulateCrit()

    local simulatedCrit = true;

    if (EstimatedCritRate < 100) then
        local simulation = math.random(0, 100)
        if (simulation > EstimatedCritRate) then
            simulatedCrit = false;
        end
    end

    return simulatedCrit;

end

function CritSounds_MakeSound(soundFrequency, soundChannel, soundPack, triggerType)
    if triggerType then
        local triggers = CritSounds.db.profile.triggers

        if triggers and triggers[triggerType] == false then
            return
        end
    end

    local packName = CritSoundsPacks[soundPack] and soundPack or "BOZO_SOUNDS"
    local soundArray = CritSoundsPacks[packName]
    local enabledSounds = {}
    local enabled = CritSounds_GetEnabled()

    for _, soundFile in ipairs(soundArray) do
        if enabled[packName .. ":" .. soundFile] then
            enabledSounds[#enabledSounds + 1] = soundFile
        end
    end

    if #enabledSounds == 0 then
        return
    end

    local sound = enabledSounds[math.random(#enabledSounds)]
    local randomNum = math.random(100) - 1
    local channel = soundChannel or "Master"

    if sound and randomNum < soundFrequency then
        PlaySoundFile("Interface\\AddOns\\CritSounds\\" .. sound, channel)
    end
end