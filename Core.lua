CritSounds = LibStub("AceAddon-3.0"):NewAddon("CritSounds", "AceConsole-3.0", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local THIS_VERSION = C_AddOns.GetAddOnMetadata("CritSounds", "Version")

local defaults = {
	profile = {
		isEnabled = true,
		soundFrequency = 100,
		soundChannel = "Master",
		-- Soundpack = "bozo",
	},
}

local options = {
	name = "Crit Sounds Settings " .. THIS_VERSION,
	handler = CritSounds,
	type = "group",
	args = {
		isEnabled = {
			type = "toggle",
			order = 1,
			width = 1.5,
			name = CRITS_TEXT_OPT_VAR_CRITSENABLED,
			desc = CRITS_TEXT_OPT_TOOL_CRITSENABLED,
			get = "GetIsEnabled",
			set = "SetIsEnabled"
		},
		soundFrequency = {
			type = "range",
			order = 3,
			name = "Crit Sound Frequency",
			desc = "Set how often you want a crit to make a sound. Use this if crits are happening too often.",
			width = 1.5,
			get = "GetSoundFrequency",
			set = "SetSoundFrequency",
			min = 0, max = 100, step = 1,
		},
		soundChannel = {
			type = "select",
			order = 5,
			name = "Sound Channel",
			desc = "Pick the sound channel crit sounds will be played through (you can adjust volume through the normal settings)",
			width = 1,
			get = "GetSoundChannel",
			set = "SetSoundChannel",
			values = {
				Master = "Master",
				Music = "Music",
				Effects = "Effects",
				Ambiance = "Ambiance",
				Dialog = "Dialog",
			},
			sorting = {
				"Master",
				"Music",
				"Effects",
				"Ambiance",
				"Dialog",
			}
		}
		-- Soundpack = {
		-- 	type = "input",
		-- 	order = 15,
		-- 	width = "double",
		-- 	name = CRITS_TEXT_OPT_PACK,
		-- 	desc = CRITS_TEXT_OPT_PACKHELP,
		-- 	usage = "bozo or custom folder (must modify BOZO_SOUNDS constant array)",
		-- 	get = "GetSoundpack",
		-- 	set = "SetSoundpack",
		-- },
	},
}

function CritSounds:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CritSoundsDB", defaults, true)

	AC:RegisterOptionsTable("Crit Sounds_options", options)
	self.optionsFrame, self.mainFrameId = ACD:AddToBlizOptions("Crit Sounds_options", "Crit Sounds")
	_G["MainFrame"] = self.optionsFrame;

	self:RegisterChatCommand("crit", "SlashCommand")
	self:RegisterChatCommand("crits", "SlashCommand")
	self:RegisterChatCommand("critsounds", "SlashCommand")

	CritSounds_SetPack();
end

function CritSounds:OnEnable()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")
end

function CritSounds:SlashCommand()
	Settings.OpenToCategory(self.mainFrameId)
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

-- function CritSounds:GetSoundpack(info)
-- 	return self.db.profile.Soundpack
-- end
-- function CritSounds:SetSoundpack(info, value)
-- 	self.db.profile.Soundpack = value
-- end


function CritSounds_SetPack()

	BOZO_SOUNDS = {
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\taco_bell.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\waltuh.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\lego_yoda.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\earthbound_boss.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\soda.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\obamna.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\bruh.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\fart slightly quieter.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\nfl short base boost.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\pipes_falling.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\vine_boom.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\come_pig.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\ok.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\tidus_haha.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\tim_allen_grunt.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\fireball.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\waltuh2.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\dbz_kameha.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m1.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m2.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m3.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m4.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m5.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m6.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m7.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m8.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m9.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m10.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m11.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\waltuh3.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m12.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m13.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\m14.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\Huh sound.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\seinfeld fast mode.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\Tony Hawk's Pro Skater 12 Special Trick sound effect.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\what the dog doinn.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\bing_chilling.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\dial up.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\mah_waife.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\dropped rings.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\World of Warcraft Level Up Sound.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\You Got Mail.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\Emotional Damage.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\roblox oof.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\Lightning Bolt.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\bazinga.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\eurobeat sound.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\mario yahoo.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\hawk tuah.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\bop it.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\twist it.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\pull it.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\banjo silly.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\minecraft oof.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\gong.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\snake.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\yooo.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\bonk.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\he need some milk.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\whoah.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\xp boot.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\wombo combo.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\thats a lotta damage.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\we got em.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\noice.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\wilhelm.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\amogus1.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\amogus2.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\dbz_tele.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\falcom_sax.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\funky_town.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\game_show_win.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\john_cena_theme.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\mlg_theme.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\mlg_wow.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\nokia_ringtone.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\pteww_sound.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\robo_bich.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\sanic_theme.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\sax_guy.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\sunflower.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\waterphone.mp3",
		"Interface\\AddOns\\CritSounds\\Sounds\\bozo\\xfiles_theme.mp3",
	};

	-- TODO: Figure out how to auto-detect sound files in a directory

end