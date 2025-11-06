function CritSounds:OnCombatLogEventUnfiltered()
    --See https://warcraft.wiki.gg/wiki/COMBAT_LOG_EVENT for more info on these
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName,
        spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = CombatLogGetCurrentEventInfo()

    if self.db.profile.isEnabled and (sourceGUID == UnitGUID("player") or CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)) then

        if (amount ~= nil and type(amount) == "number" or (subevent == "SWING_DAMAGE" and spellID ~= nil and type(spellID) == "number")) then
            if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") then
                if (resisted == true and spellName ~= nil) then --resisted in this case is crit for the _HEAL event (18th param)
                    CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack);
                end
            else
                if (critical == true or (subevent == "SWING_DAMAGE" and resisted == true)) then --swing_damage also lacks 3 params most other _damage has
                    CritSounds_MakeSound(self.db.profile.soundFrequency, self.db.profile.soundChannel, self.db.profile.soundPack);
                end
            end
        end

    end
end

function CritSounds_MakeSound(soundFrequency, soundChannel, soundPack)

    local soundArray = BOZO_SOUNDS;

    if (type(soundPack) == "string") then
        if (soundPack == "MJ") then
            soundArray = MJ_PACK;
        elseif (soundPack == "Waltuh") then
            soundArray = WALTUH_PACK;
        end
    end

    local index = math.random(#soundArray);
    local sound = soundArray[index];

    local randomNum = math.random(100) - 1;

    local channel = soundChannel;
    if (soundChannel == nil or type(soundChannel) ~= "string") then
        channel = "Master";
    end

    if (sound and randomNum < soundFrequency) then
        PlaySoundFile(sound,channel);
    end

end