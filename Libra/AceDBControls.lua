local Libra = LibStub("Libra")
local Type, Version = "AceDBControls", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}


local L = {
	default = "Default",
	reset = "Reset profile",
	new = "Create new profile",
	choose = "Active profile",
	copy = "Copy From",
	delete = "Delete a profile",
	delete_confirm = "Are you sure you want to delete the selected profile?",
	profiles = "Profiles",

	dual_profile = "Dual profile",
	enabled = "Enable dual profile",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
	L["default"] = "Standard"
	L["reset"] = "Profil zur\195\188cksetzen"
	L["new"] = "Neu"
	L["choose"] = "Vorhandene Profile"
	L["copy"] = "Kopieren von..."
	L["delete"] = "Profil l\195\182schen"
	L["delete_confirm"] = "Willst du das ausgew\195\164hlte Profil wirklich l\195\182schen?"
	L["profiles"] = "Profile"
	
	L["dual_profile"] = "Duales Profil"
	L["enabled"] = "Aktiviere Duale Profile"
elseif LOCALE == "frFR" then
	L["default"] = "D\195\169faut"
	L["reset"] = "R\195\169initialiser le profil"
	L["new"] = "Nouveau"
	L["choose"] = "Profils existants"
	L["copy"] = "Copier \195\160 partir de"
	L["delete"] = "Supprimer un profil"
	L["delete_confirm"] = "Etes-vous s\195\187r de vouloir supprimer le profil s\195\169lectionn\195\169 ?"
	L["profiles"] = "Profils"

	L["dual_profile"] = 'Second profil'
	L["enabled"] = 'Activez le second profil'
elseif LOCALE == "koKR" then
	L["default"] = "기본값"
	L["reset"] = "프로필 초기화"
	L["new"] = "새로운 프로필"
	L["choose"] = "프로필 선택"
	L["copy"] = "복사"
	L["delete"] = "프로필 삭제"
	L["delete_confirm"] = "정말로 선택한 프로필의 삭제를 원하십니까?"
	L["profiles"] = "프로필"
	
	L["dual_profile"] = "이중 프로필"
	L["enabled"] = "이중 프로필 사용"
elseif LOCALE == "esES" or LOCALE == "esMX" then
	L["default"] = "Por defecto"
	L["reset"] = "Reiniciar Perfil"
	L["new"] = "Nuevo"
	L["choose"] = "Perfiles existentes"
	L["copy"] = "Copiar de"
	L["delete"] = "Borrar un Perfil"
	L["delete_confirm"] = "¿Estas seguro que quieres borrar el perfil seleccionado?"
	L["profiles"] = "Perfiles"
elseif LOCALE == "zhTW" then
	L["default"] = "預設"
	L["reset"] = "重置設定檔"
	L["new"] = "新建"
	L["choose"] = "現有的設定檔"
	L["copy"] = "複製自"
	L["delete"] = "刪除一個設定檔"
	L["delete_confirm"] = "你確定要刪除所選擇的設定檔嗎？"
	L["profiles"] = "設定檔"
elseif LOCALE == "zhCN" then
	L["default"] = "默认"
	L["reset"] = "重置配置文件"
	L["choose_desc"] = "你可以通过在文本框内输入一个名字创立一个新的配置文件，也可以选择一个已经存在的配置文件。"
	L["new"] = "新建"
	L["choose"] = "现有的配置文件"
	L["copy"] = "复制自"
	L["delete"] = "删除一个配置文件"
	L["delete_confirm"] = "你确定要删除所选择的配置文件么？"
	L["profiles"] = "配置文件"
	
	L["dual_profile"] = "双重配置文件"
	L["enabled"] = "开启双重配置文件"
elseif LOCALE == "ruRU" then
	L["default"] = "По умолчанию"
	L["reset"] = "Сброс профиля"
	L["new"] = "Новый"
	L["choose"] = "Существующие профили"
	L["copy"] = "Скопировать из"
	L["delete"] = "Удалить профиль"
	L["delete_confirm"] = "Вы уверены, что вы хотите удалить выбранный профиль?"
	L["profiles"] = "Профили"
	
	L["dual_profile"] = "Второй профиль"
	L["enabled"] = "Включить двойной профиль"
end

local defaultProfiles = {}

local function profileSort(a, b)
	return a.value < b.value
end

local tempProfiles = {}

local function getProfiles(db, common, nocurrent)
	local profiles = {}
	
	-- copy existing profiles into the table
	local currentProfile = db:GetCurrentProfile()
	for _, v in ipairs(db:GetProfiles(tempProfiles)) do 
		if not (nocurrent and v == currentProfile) then 
			profiles[v] = v 
		end 
	end
	
	-- add our default profiles to choose from ( or rename existing profiles)
	for k, v in pairs(defaultProfiles) do
		if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
			profiles[k] = v
		end
	end
	
	local sortProfiles = {}
	for k, v in pairs(profiles) do
		tinsert(sortProfiles, {text = v, value = k})
	end
	sort(sortProfiles, profileSort)
	
	return sortProfiles
end

local function dropdownOnClick(self, profile, func)
	func(self.owner.db, profile)
end

local function initializeDropdown(self, level, menuList)
	for i, v in ipairs(getProfiles(self.db, self.common, self.nocurrent)) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v.text
		info.func = dropdownOnClick
		info.arg1 = v.value
		info.arg2 = self.func
		info.checked = not self.nocurrent and (v.value == self.getCurrent(self.db))
		info.notCheckable = self.nocurrent
		self:AddButton(info)
	end
end

local function createDropdown(parent)
	local dropdown = Libra:CreateDropdown("Frame", parent)
	dropdown:SetWidth(160)
	dropdown:JustifyText("LEFT")
	dropdown.initialize = initializeDropdown
	return dropdown
end

local function menuButton_OnClick(self)
	self.menu:Toggle()
end

local function createMenuButton(parent)
	local button = CreateFrame("Button", Libra:GetWidgetName(), parent, "UIMenuButtonStretchTemplate")
	button:SetScript("OnClick", menuButton_OnClick)
	button.rightArrow:Show()
	button:SetWidth(88)
	
	local menu = Libra:CreateDropdown("Menu")
	menu.xOffset = 0
	menu.yOffset = 0
	menu.relativeTo = button
	menu.initialize = initializeDropdown
	menu.nocurrent = true
	button.menu = menu
	
	return button
end

local function profilesLoaded(self)
	local db = self.db
	
	for k, object in pairs(self.objects) do
		object.db = db
		self[k] = object
	end
	
	db.RegisterCallback(self, "OnNewProfile")
	db.RegisterCallback(self, "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileDeleted")
	
	local keys = db.keys
	defaultProfiles["Default"] = L.default
	defaultProfiles[keys.char] = keys.char
	defaultProfiles[keys.realm] = keys.realm
	defaultProfiles[keys.class] = UnitClass("player")
	
	self.choose:SetText(db:GetCurrentProfile())
	
	local isDualSpecEnabled = db:IsDualSpecEnabled()
	self.dualEnabled:SetChecked(isDualSpecEnabled)
	self.dualProfile:SetEnabled(isDualSpecEnabled)
	self.dualProfile:SetText(db:GetDualSpecProfile())
	
	self:CheckProfiles()
end

local mixins = {
	OnNewProfile = function(self, event, db, profile)
		self:CheckProfiles()
	end,
	OnProfileChanged = function(self, event, db, profile)
		self.choose:SetText(profile)
		self.dualProfile:SetText(db:GetDualSpecProfile())
		self:CheckProfiles()
	end,
	OnProfileDeleted = function(self, event, db, profile)
		self:CheckProfiles()
	end,
	CheckProfiles = function(self)
		local hasNoProfiles = self:HasNoProfiles()
		-- self.copy:SetDisabled(hasNoProfiles)
		-- self.delete:SetDisabled(hasNoProfiles)
	end,
	HasNoProfiles = function(self)
		return next(getProfiles(self.db, nil, true)) == nil
	end,
}

local createProfileScripts = {
	OnEnterPressed = function(self)
		self.db:SetProfile(self:GetText())
		self:ClearFocus()
	end,
	OnEditFocusGained = function(self)
		self:SetTextColor(1, 1, 1)
	end,
	OnEditFocusLost = function(self)
		self:SetTextColor(0.5, 0.5, 0.5)
		self:SetText("")
	end,
}

local function enableDualProfileOnClick(self)
	local checked = self:GetChecked() == 1
	self.db:SetDualSpecEnabled(checked)
	self.dualProfile:SetEnabled(checked)
end

local function deleteProfile(db, profile)
	StaticPopup_Show("DELETE_PROFILE", nil, nil, {db = db, profile = profile})
end

local function constructor(self, db, parent)
	frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(192, 192)
	frame.db = db
	
	frame.ProfilesLoaded = profilesLoaded
	for k, v in pairs(mixins) do frame[k] = v end
	
	-- addon.RegisterCallback(frame, "AddonLoaded", "ProfilesLoaded")
	
	local objects = {}
	frame.objects = objects
	
	local choose = createDropdown(frame)
	choose:SetPoint("TOP")
	choose.label:SetText(L.choose)
	choose.getCurrent = db.GetCurrentProfile
	choose.func = db.SetProfile
	choose.common = true
	objects.choose = choose
	
	local newProfile = Libra:CreateEditbox(frame)
	newProfile:SetPoint("TOPLEFT", choose, "BOTTOMLEFT", 24, -8)
	newProfile:SetPoint("TOPRIGHT", choose, "BOTTOMRIGHT", -17, -8)
	newProfile:SetTextColor(0.5, 0.5, 0.5)
	newProfile:SetScript("OnEscapePressed", newProfile.ClearFocus)
	for script, handler in pairs(createProfileScripts) do
		newProfile:SetScript(script, handler)
	end
	objects.newProfile = newProfile
	
	local label = newProfile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("BOTTOMLEFT", newProfile, "TOPLEFT", -5, -2)
	label:SetPoint("BOTTOMRIGHT", newProfile, "TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)
	label:SetText(L.new)
	
	local copy = createMenuButton(frame)
	copy:SetPoint("TOPLEFT", newProfile, "BOTTOMLEFT", -9, -4)
	copy:SetText("Copy from")
	copy.menu.func = db.CopyProfile
	objects.copy = copy.menu

	local delete = createMenuButton(frame)
	delete:SetPoint("TOPRIGHT", newProfile, "BOTTOMRIGHT", 4, -4)
	delete:SetText("Delete")
	delete.menu.func = deleteProfile
	objects.delete = delete.menu
	
	local reset = CreateFrame("Button", Libra:GetWidgetName(), frame, "UIMenuButtonStretchTemplate")
	reset:SetWidth(96)
	reset:SetPoint("TOPLEFT", copy, "BOTTOM", 0, -4)
	reset:SetPoint("TOPRIGHT", delete, "BOTTOM", 0, -4)
	reset:SetScript("OnClick", function(self) self.db:ResetProfile() end)
	reset:SetText(L.reset)
	objects.reset = reset
	
	local hasDualProfile = db:GetNamespace("LibDualSpec-1.0", true)
	if hasDualProfile then
		local dualProfile = createDropdown(frame)
		dualProfile:SetPoint("TOP", reset, "BOTTOM", 0, -28)
		-- dualProfile:SetPoint("LEFT", choose)
		dualProfile.getCurrent = db.GetDualSpecProfile
		dualProfile.func = db.SetDualSpecProfile
		dualProfile.common = true
		objects.dualProfile = dualProfile
		
		local enabled = CreateFrame("CheckButton", nil, frame, "OptionsBaseCheckButtonTemplate")
		enabled:SetPoint("BOTTOMLEFT", dualProfile, "TOPLEFT", 16, 0)
		enabled:SetPushedTextOffset(0, 0)
		enabled:SetScript("OnClick", enableDualProfileOnClick)
		enabled.tooltipText = L.enable_desc
		local text = enabled:CreateFontString(nil, nil, "GameFontHighlight")
		text:SetPoint("LEFT", enabled, "RIGHT", 0, 1)
		text:SetText(L.enabled)
		objects.dualEnabled = enabled

		enabled.dualProfile = dualProfile
	end
	
	profilesLoaded(frame)
	return frame
end

StaticPopupDialogs["DELETE_PROFILE"] = {
	text = L.delete_confirm,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		data.db:DeleteProfile(data.profile)
	end,
}

Libra:RegisterModule(Type, Version, constructor)