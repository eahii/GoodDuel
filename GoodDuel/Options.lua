local _, ns = ...

local panel = CreateFrame("Frame")

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Good Duel")

local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
hint:SetText("Said in /say when a duel starts and ends. Leave a field empty to say nothing.")

local boxes = {}

local function addMessageField(key, labelText, y)
	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", 16, y)
	label:SetText(labelText)

	-- InputBoxTemplate draws its border outside the frame, so inset it to line up with the label
	local box = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 6, -6)
	box:SetSize(320, 20)
	box:SetAutoFocus(false)
	box:SetMaxLetters(255)
	box:SetScript("OnTextChanged", function(self, userInput)
		if userInput then
			GoodDuelDB[key] = self:GetText()
		end
	end)
	box:SetScript("OnEnterPressed", box.ClearFocus)
	box:SetScript("OnEscapePressed", box.ClearFocus)

	boxes[key] = box
end

addMessageField("startText", "Duel start message", -80)
addMessageField("endText", "Duel end message", -136)

local function refresh()
	for key, box in pairs(boxes) do
		box:SetText(GoodDuelDB[key] or "")
		box:SetCursorPosition(0)
	end
end

local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
reset:SetPoint("TOPLEFT", 16, -196)
reset:SetSize(140, 22)
reset:SetText("Reset to defaults")
reset:SetScript("OnClick", function()
	for key, value in pairs(ns.DEFAULTS) do
		GoodDuelDB[key] = value
	end
	refresh()
end)

panel:SetScript("OnShow", refresh)

local category = Settings.RegisterCanvasLayoutCategory(panel, "Good Duel")
Settings.RegisterAddOnCategory(category)

SLASH_GOODDUEL1 = "/goodduel"
SlashCmdList.GOODDUEL = function()
	Settings.OpenToCategory(category:GetID())
end
