function CritSounds:OnCombatLogEventUnfiltered()
    --See https://warcraft.wiki.gg/wiki/COMBAT_LOG_EVENT for more info on these
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName,
        spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = CombatLogGetCurrentEventInfo()

    if self.db.profile.isEnabled and (sourceGUID == UnitGUID("player") or CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)) then

        if (amount ~= nil and type(amount) == "number" or (subevent == "SWING_DAMAGE" and spellID ~= nil and type(spellID) == "number")) then
            if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") then
                if (resisted == true and spellName ~= nil) then --resisted in this case is crit for the _HEAL event (18th param)
                    CritSounds_MakeSound(self.db.profile.soundFrequency);
                end
            else
                if (critical ~= false or (subevent == "SWING_DAMAGE" and resisted ~= false)) then --swing_damage also lacks 3 params most other _damage has
                    CritSounds_MakeSound(self.db.profile.soundFrequency);
                end
            end
        end

    end
end

function CritSounds_MakeSound(soundFrequency)

    local index = math.random(#BOZO_SOUNDS);
    local sound = BOZO_SOUNDS[index];

    local randomNum = math.random(100) - 1;

    if (sound and randomNum < soundFrequency) then
        PlaySoundFile(sound,"Master");
    end

end