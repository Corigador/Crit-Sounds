local panel = CreateFrame("Frame", "CritSoundsOptionsPanel", UIParent)
panel.name = "CritSounds"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("CritSounds")

local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
description:SetText("Manage and preview your sounds.")

local channels = { "Master", "Music", "Effects", "Ambiance", "Dialog" }
local packNames = {
    BOZO_SOUNDS = "Bozo",
    FAAH_PACK = "Faah",
    MJ_PACK = "MJ",
    WALTUH_PACK = "Waltuh",
}
local packOrder = { "BOZO_SOUNDS", "FAAH_PACK", "MJ_PACK", "WALTUH_PACK" }

local isEnabled = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
isEnabled:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -8)
isEnabled.Text:SetText(CRITS_TEXT_OPT_VAR_CRITSENABLED or "Enable Crit Sounds")
isEnabled:SetScript("OnClick", function(self)
    CritSounds:SetIsEnabled(nil, self:GetChecked() and true or false)
end)

local frequency = CreateFrame("Slider", "CritSoundsFrequencySlider", panel, "OptionsSliderTemplate")
frequency:SetPoint("TOPLEFT", isEnabled, "BOTTOMLEFT", 4, -28)
frequency:SetWidth(240)
frequency:SetMinMaxValues(0, 100)
frequency:SetValueStep(1)
frequency:SetObeyStepOnDrag(true)
frequency.Low:SetText("0")
frequency.High:SetText("100")
frequency:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    self.Text:SetText("Crit Sound Frequency: " .. value)
    CritSounds:SetSoundFrequency(nil, value)
end)

local channelLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
channelLabel:SetText("Sound Channel")

local channel = CreateFrame("Frame", "CritSoundsChannelDropdown", panel, "UIDropDownMenuTemplate")
channel:SetPoint("TOPLEFT", frequency, "BOTTOMLEFT", -20, -36)
channelLabel:SetPoint("BOTTOMLEFT", channel, "TOPLEFT", 20, 2)
UIDropDownMenu_SetWidth(channel, 120)

local packLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
packLabel:SetText("Sound Pack")

local pack = CreateFrame("Frame", "CritSoundsPackDropdown", panel, "UIDropDownMenuTemplate")
pack:SetPoint("LEFT", channel, "RIGHT", -10, 0)
packLabel:SetPoint("BOTTOMLEFT", pack, "TOPLEFT", 20, 2)
UIDropDownMenu_SetWidth(pack, 120)

local function InitChannel()
    UIDropDownMenu_Initialize(channel, function()
        for _, name in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.checked = CritSounds:GetSoundChannel() == name
            info.func = function()
                CritSounds:SetSoundChannel(nil, name)
                UIDropDownMenu_SetText(channel, name)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(channel, CritSounds:GetSoundChannel())
end

local function InitPack()
    UIDropDownMenu_Initialize(pack, function()
        for _, key in ipairs(packOrder) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = packNames[key]
            info.checked = CritSounds:GetSoundPack() == key
            info.func = function()
                CritSounds:SetSoundPack(nil, key)
                UIDropDownMenu_SetText(pack, packNames[key])
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(pack, packNames[CritSounds:GetSoundPack()] or CritSounds:GetSoundPack())
end

local triggerList = {
    { key = "autoAttacks", label = "Auto attacks" },
    { key = "petAttacks",  label = "Pet attacks" },
    { key = "dots",        label = "DoTs" },
    { key = "hots",        label = "HoTs" },
    { key = "heals",       label = "Direct heals" },
}

local triggerLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
triggerLabel:SetPoint("TOPLEFT", channel, "BOTTOMLEFT", 20, -8)
triggerLabel:SetText("Play sounds on:")

local triggerChecks = {}
local lastRowAnchor

for i, t in ipairs(triggerList) do
    local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    if i == 1 then
        cb:SetPoint("TOPLEFT", triggerLabel, "BOTTOMLEFT", -4, -4)
        lastRowAnchor = cb
    elseif i % 2 == 0 then
        cb:SetPoint("LEFT", triggerChecks[i - 1], "RIGHT", 150, 0)
    else
        cb:SetPoint("TOPLEFT", triggerChecks[i - 2], "BOTTOMLEFT", 0, -2)
        lastRowAnchor = cb
    end
    cb.Text:SetText(t.label)
    cb:SetScript("OnClick", function(self)
        CritSounds:SetTrigger(nil, t.key, self:GetChecked())
    end)
    cb.triggerKey = t.key
    triggerChecks[i] = cb
end

local perCharacter = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
perCharacter:SetPoint("TOPLEFT", lastRowAnchor, "BOTTOMLEFT", 0, -8)
perCharacter.Text:SetText("Enable for character specific sound selection from the below packs:")
perCharacter:SetScript("OnClick", function(self)
    CritSounds:SetPerCharacter(nil, self:GetChecked() and true or false)
    panel:UpdateSoundList()
end)

local collapsed = {}

local scroll = CreateFrame(
    "ScrollFrame",
    "CritSoundsScrollFrame",
    panel,
    "UIPanelScrollFrameTemplate"
)
scroll:SetPoint("TOPLEFT", perCharacter, "BOTTOMLEFT", 0, -12)
scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -32, 16)

local content = CreateFrame("Frame", nil, scroll)
scroll:SetScrollChild(content)

local function PlayPreview(soundFile)
    PlaySoundFile(
        "Interface\\AddOns\\CritSounds\\" .. soundFile,
        "Master"
    )
end

local function CreateSoundRow(packName, soundFile, y, width)
    local row = CreateFrame("Frame", nil, content)
    row:SetSize(width, 28)
    row:SetPoint("TOPLEFT", 20, y)

    local settingKey = packName .. ":" .. soundFile

    local checkbox = CreateFrame(
        "CheckButton",
        nil,
        row,
        "InterfaceOptionsCheckButtonTemplate"
    )
    checkbox:SetPoint("LEFT", 0, 0)
    checkbox:SetChecked(CritSounds_GetEnabled()[settingKey] == true)

    if checkbox.Text then
        checkbox.Text:SetText(soundFile)
    end

    checkbox:SetScript("OnClick", function(self)
        CritSounds_GetEnabled()[settingKey] = self:GetChecked() and true or false
    end)

    local play = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    play:SetSize(64, 22)
    play:SetPoint("RIGHT", -4, 0)
    play:SetText("Play")
    play:SetScript("OnClick", function()
        PlayPreview(soundFile)
    end)

    return row
end

local function CreateSoundFolder(packName, sounds, y, width)
    local folder = CreateFrame("Button", nil, content)
    folder:SetSize(width, 26)
    folder:SetPoint("TOPLEFT", 4, y)

    local label = folder:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", 6, 0)
    label:SetText((collapsed[packName] and "+ " or "- ") .. packName)

    folder:SetScript("OnClick", function()
        collapsed[packName] = not collapsed[packName]
        panel:UpdateSoundList()
    end)

    y = y - 28

    if not collapsed[packName] then
        for _, soundFile in ipairs(sounds) do
            if type(soundFile) == "string" then
                CreateSoundRow(packName, soundFile, y, width - 20)
                y = y - 29
            end
        end
    end

    return y - 5
end

function panel:UpdateSoundList()
    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local packs = {}
    for packName, sounds in pairs(CritSoundsPacks or {}) do
        if type(sounds) == "table" then
            packs[#packs + 1] = packName
            if collapsed[packName] == nil then
                collapsed[packName] = true
            end
        end
    end
    table.sort(packs)

    local width = math.max(scroll:GetWidth() - 24, 300)
    local y = -4

    for _, packName in ipairs(packs) do
        y = CreateSoundFolder(packName, CritSoundsPacks[packName], y, width)
    end

    content:SetSize(width, math.max(-y, 1))
end

panel:SetScript("OnShow", function()
    for _, cb in ipairs(triggerChecks) do
        cb:SetChecked(CritSounds:GetTrigger(nil, cb.triggerKey))
    end
    isEnabled:SetChecked(CritSounds:GetIsEnabled())
    frequency:SetValue(CritSounds:GetSoundFrequency())
    InitChannel()
    InitPack()
    perCharacter:SetChecked(CritSounds:GetPerCharacter())
    panel:UpdateSoundList()
end)

panel:SetScript("OnSizeChanged", function()
    if panel:IsShown() then
        panel:UpdateSoundList()
    end
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, "CritSounds")
Settings.RegisterAddOnCategory(category)
CritSoundsCategory = category