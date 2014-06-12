local Libra = LibStub("Libra")
local Type, Version = "OptionsFrame", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Options = Libra.modules[Type]

Options.Prototype = Options.Prototype or CreateFrame("Frame")
Options.ParentPrototype = Options.ParentPrototype or {}

local mt = {__index = Options.Prototype}
local parentMT = {__index = setmetatable(Options.ParentPrototype, {__index = Options.Prototype})}

local Prototype = Options.Prototype
local ParentPrototype = Options.ParentPrototype

local function createFrame(name, parent)
	local frame = CreateFrame("Frame")
	frame.name = name
	frame.parent = parent
	InterfaceOptions_AddCategory(frame)
	
	local title = frame:CreateFontString(nil, nil, "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	-- title:SetPoint("RIGHT", -16, 0)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(name)
	frame.title = title
	
	local desc = frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	desc:SetHeight(32)
	desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
	desc:SetPoint("RIGHT", -32, 0)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetNonSpaceWrap(true)
	frame.desc = desc
	
	return frame
end

local function constructor(self, name)
	local frame = setmetatable(createFrame(name), parentMT)
	frame.controls = {}
	return frame
end


function ParentPrototype:AddSubCategory(name, separateControls)
	local frame = setmetatable(createFrame(name, self.name), mt)
	frame.db = self.db
	frame.controls = separateControls and {} or self.controls
	self.subCategories = self.subCategories or {}
	tinsert(self.subCategories, frame)
	return frame
end

function Prototype:SetDatabase(database)
	self.db = database
	if self.subCategories then
		for i, v in ipairs(self.subCategories) do
			v.db = database
		end
	end
end

function Prototype:SetDescription(text)
	self.desc:SetText(text)
end

local controls = {}

local function set(self, value)
	if self.set then
		self:set(value)
	elseif self.parent.db then
		self.parent.db[self.key] = value
	end
	if self.func then
		self:func(value)
	end
	for key, control in pairs(self.parent.controls) do
		if control.disabled then
			control:SetEnabled(not control.disabled())
		end
	end
end

local function get(self)
	if self.get then
		return self:get()
	elseif self.parent.db then
		return self.parent.db[self.key]
	end
end

do
	local function onClick(self)
		local checked = self:GetChecked() ~= nil
		PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		set(self, checked)
	end
	
	controls.CheckButton = function(parent)
		local checkButton = CreateFrame("CheckButton", nil, parent, "OptionsBaseCheckButtonTemplate")
		checkButton:SetPushedTextOffset(0, 0)
		checkButton:SetScript("OnClick", onClick)
		checkButton.SetValue = checkButton.SetChecked
		
		checkButton.label = checkButton:CreateFontString(nil, nil, "GameFontHighlight")
		checkButton.label:SetPoint("LEFT", checkButton, "RIGHT", 0, 1)
		
		return checkButton
	end
end

do
	local ColorPickerFrame = ColorPickerFrame
	
	local function setColor(self, color)
		self.swatch:SetVertexColor(color.r, color.g, color.b)
	end
	
	local function saveColor(self, r, g, b)
		self.swatch:SetVertexColor(r, g, b)
		local color = get(self)
		color.r = r
		color.g = g
		color.b = b
		set(self, color)
	end
	
	local function swatchFunc()
		saveColor(ColorPickerFrame.extraInfo, ColorPickerFrame:GetColorRGB())
	end
	
	local function cancelFunc(prev)
		saveColor(ColorPickerFrame.extraInfo, ColorPicker_GetPreviousValues())
	end
	
	local function onClick(self)
		local info = UIDropDownMenu_CreateInfo()
		local color = get(self)
		info.r, info.g, info.b = color.r, color.g, color.b
		info.swatchFunc = swatchFunc
		info.cancelFunc = cancelFunc
		info.extraInfo = self
		OpenColorPicker(info)
	end
	
	local function onEnter(self)
		self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		if self.tooltipText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
		end
	end
	
	local function onLeave(self)
		self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		GameTooltip:Hide()
	end
	
	controls.ColorButton = function(parent, data)
		local colorButton = CreateFrame("Button", nil, parent)
		colorButton:SetSize(16, 16)
		colorButton:SetPushedTextOffset(0, 0)
		colorButton:SetScript("OnClick", onClick)
		colorButton:SetScript("OnEnter", onEnter)
		colorButton:SetScript("OnLeave", onLeave)
		colorButton.SetValue = setColor
		
		colorButton:SetNormalTexture([[Interface\ChatFrame\ChatFrameColorSwatch]])
		colorButton.swatch = colorButton:GetNormalTexture()
		
		colorButton.bg = colorButton:CreateTexture(nil, "BACKGROUND")
		colorButton.bg:SetSize(14, 14)
		colorButton.bg:SetPoint("CENTER")
		colorButton.bg:SetTexture(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		
		colorButton.label = colorButton:CreateFontString(nil, nil, "GameFontHighlight")
		colorButton.label:SetPoint("LEFT", colorButton, "RIGHT", 5, 1)
		colorButton.label:SetJustifyH("LEFT")
		
		return colorButton
	end
end

do
	local function onValueChanged(self, value, isUserInput)
		if isUserInput then
			set(self, value)
		end
		self.currentValue:SetText(value)
	end
	
	controls.Slider = function(parent, data)
		local slider = Libra:CreateSlider(parent)
		slider:SetScript("OnValueChanged", onValueChanged)
		slider:SetMinMaxValues(data.min, data.max)
		slider:SetValueStep(data.step)
		return slider
	end
end

do
	local function initialize(self, level, menuList)
		for i, v in ipairs(menuList) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.func = set
			info.arg1 = v
			info.checked = (v == PM.db.font)
			self:AddButton(info)
		end
	end
	
	controls.Dropdown = function(parent, data)
		local dropdown = Libra:CreateDropdown("Frame", parent)
		dropdown.SetValue = dropdown.SetText
		dropdown.initialize = data.initialize or initialize
		dropdown.menuList = data.menuList
		return dropdown
	end
end

local objectData = {
	CheckButton = {
		x = -2,
		y = -16,
		bottomOffset = 8,
	},
	ColorButton = {
		x = 3,
		y = -21,
		bottomOffset = 3,
	},
	Slider = {
		x = 7,
		y = -27,
		bottomOffset = -5,
	},
	Dropdown = {
		x = -15,
		y = -32,
		bottomOffset = 8,
	},
}

function Prototype:CreateOptions(options)
	for i, option in ipairs(options) do
		local control = controls[option.type](self, option)
		local data = objectData[option.type]
		if i == 1 then
			control:SetPoint("TOPLEFT", self.desc, "BOTTOMLEFT", data.x, data.y + 8)
		elseif option.newColumn then
			control:SetPoint("TOPLEFT", self.desc, "BOTTOM", data.x - 2, data.y + 8)
		else
			local previousOption = options[i - 1]
			local previousData = objectData[previousOption.type]
			control:SetPoint("TOPLEFT", self.controls[#self.controls], "BOTTOMLEFT", data.x - previousData.x, data.y + previousData.bottomOffset - (option.gap or 0))
		end
		if option.width then
			control:SetWidth(option.width)
		end
		control.parent = self
		control.label:SetText(option.label)
		control.tooltipText = option.tooltipText
		control.key = option.key
		control.set = option.set
		control.get = option.get
		control.func = option.func
		control.disabled = option.disabled
		tinsert(self.controls, control)
	end
end

function Prototype:SetupControls()
	for i, control in ipairs(self.controls) do
		local value = get(control)
		control:SetValue(value)
		if control.func then
			control:func(value)
		end
	end
end

Libra:RegisterModule(Type, Version, constructor)