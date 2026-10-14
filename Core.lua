CritSounds = LibStub("AceAddon-3.0"):NewAddon("CritSounds", "AceConsole-3.0", "AceEvent-3.0")

local defaults = {
	profile = {
		isEnabled = true,
		soundFrequency = 100,
		soundChannel = "Master",
		soundPack = "Main",
		triggers = {
			dots = true,
			hots = true,
			heals = true,
			autoAttacks = true,
			petAttacks = true,
		},
	},
}



function CritSounds:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CritSoundsDB", defaults, true)

	self:RegisterChatCommand("crit", "SlashCommand")
	self:RegisterChatCommand("crits", "SlashCommand")
	self:RegisterChatCommand("critsounds", "SlashCommand")

	CritSounds_SetPack();
	CritSounds_SyncDefaults();
end

function CritSounds:OnEnable()
    local _, _, _, interfaceVersion = GetBuildInfo()

    local isModernClient =
        interfaceVersion >= 120000
        or (interfaceVersion >= 16000 and interfaceVersion < 20000)

    if not isModernClient then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")
        return
    end

    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "CastSuccess")
    self:RegisterEvent("UNIT_COMBAT", "UnitCombatValidator")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeftCombat")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnteredCombat")
end

function CritSounds:SlashCommand()
	Settings.OpenToCategory(CritSoundsCategory:GetID())
end


function CritSounds:GetIsEnabled(info)
	return self.db.profile.isEnabled;
end
function CritSounds:SetIsEnabled(info, value)
	self.db.profile.isEnabled = value;
end
function CritSounds:GetSoundFrequency(info)
	return self.db.profile.soundFrequency;
end
function CritSounds:SetSoundFrequency(info, value)
	self.db.profile.soundFrequency = value;
end
function CritSounds:GetSoundChannel(info)
	return self.db.profile.soundChannel;
end
function CritSounds:SetSoundChannel(info, value)
	self.db.profile.soundChannel = value;
end
function CritSounds:GetSoundPack(info)
	return self.db.profile.soundPack
end
function CritSounds:SetSoundPack(info, value)
	self.db.profile.soundPack = value
end
function CritSounds:GetPerCharacter(info)
	return CritSoundsDB.perCharacter == true;
end
function CritSounds:SetPerCharacter(info, value)
	CritSoundsDB.perCharacter = value;
	CritSounds_SyncDefaults();
end
function CritSounds:GetTrigger(info, key)
	return self.db.profile.triggers[key] ~= false
end
function CritSounds:SetTrigger(info, key, value)
	self.db.profile.triggers[key] = value and true or false
end


function CritSounds_SetPack()
	local pack = CritSounds.db.profile.soundPack
	if not CritSoundsPacks[pack] then
		pack = "BOZO_SOUNDS"
	end
	CritSounds.db.profile.soundPack = pack
end

-- Initialize database with safety checks
local function EnsureDB()
	if not CritSoundsDB then
		CritSoundsDB = {}
	end
	if not CritSoundsDB.soundEnabled then
		CritSoundsDB.soundEnabled = {}
	end
	if not CritSoundsCharDB then
		CritSoundsCharDB = {}
	end
	if not CritSoundsCharDB.soundEnabled then
		CritSoundsCharDB.soundEnabled = {}
	end
end

function CritSounds_GetEnabled()
	EnsureDB()
	if CritSoundsDB.perCharacter then
		return CritSoundsCharDB.soundEnabled
	end
	return CritSoundsDB.soundEnabled
end

function CritSounds_SyncDefaults()
	local enabled = CritSounds_GetEnabled()
	for packName, sounds in pairs(CritSoundsPacks or {}) do
		if type(sounds) == "table" then
			for _, soundFile in ipairs(sounds) do
				local key = packName .. ":" .. soundFile
				if enabled[key] == nil then
					enabled[key] = true
				end
			end
		end
	end
end