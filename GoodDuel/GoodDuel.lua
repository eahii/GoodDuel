local addonName, ns = ...

ns.DEFAULTS = { startText = "gl hf", endText = "gd" }

local PENDING_MAX_AGE = 20
local COUNTDOWN_SECONDS = 3
local MAX_MESSAGE_BYTES = 255

local SendChat = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage

-- DUEL_COUNTDOWN is "Duel starting: %d" in enUS; build a locale-safe pattern from it
local countdownPattern = "^" .. (DUEL_COUNTDOWN:gsub("%p", "%%%0"):gsub("%%%%d", "%%d+")) .. "$"

-- SAY is blocked outdoors unless sent from inside a hardware event (patch 8.2.5),
-- so messages wait here and go out on the player's next keypress or world click.
local pending = {}

-- Parentless on purpose: a UIParent child stops receiving keys while the UI is hidden (Alt+Z)
local capture = CreateFrame("Frame", "GoodDuelCaptureFrame")
capture:SetFrameStrata("TOOLTIP")
capture:SetPoint("TOPLEFT")
capture:EnableMouse(false)
capture:EnableKeyboard(true)
capture:SetPropagateKeyboardInput(true)
capture:Hide()

local function flush()
	if #pending == 0 then
		return
	end
	local now = GetTime()
	for _, item in ipairs(pending) do
		if now - item.queuedAt <= PENDING_MAX_AGE then
			SendChat(item.text, "SAY")
		end
	end
	pending = {}
	capture:Hide()
end

capture:SetScript("OnKeyDown", flush)
capture:SetScript("OnKeyUp", flush)
WorldFrame:HookScript("OnMouseDown", flush)

-- "|" starts a WoW escape code (|c, |H, |T); a malformed one gets the message dropped or errors
local function clean(text)
	if type(text) ~= "string" then
		return nil
	end
	text = text:gsub("[%c|]", ""):match("^%s*(.-)%s*$")
	if #text > MAX_MESSAGE_BYTES then
		-- the cut may split a multibyte character, so drop the last one whole
		text = text:sub(1, MAX_MESSAGE_BYTES):gsub("[\192-\255][\128-\191]*$", "")
	end
	if text == "" then
		return nil
	end
	return text
end

local function say(rawText)
	local text = clean(rawText)
	if not text then
		return
	end
	pending[#pending + 1] = { text = text, queuedAt = GetTime() }
	capture:Show()
end

local duelStartedAt = nil

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:RegisterEvent("DUEL_FINISHED")
events:SetScript("OnEvent", function(_, event, text)
	if event == "ADDON_LOADED" then
		if text == addonName then
			GoodDuelDB = GoodDuelDB or {}
			-- only nil gets the default: "" means the player turned that message off
			for key, value in pairs(ns.DEFAULTS) do
				if GoodDuelDB[key] == nil then
					GoodDuelDB[key] = value
				end
			end
			events:UnregisterEvent("ADDON_LOADED")
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		if issecretvalue and issecretvalue(text) then
			return
		end
		if not duelStartedAt and type(text) == "string" and text:match(countdownPattern) then
			duelStartedAt = GetTime()
			say(GoodDuelDB.startText)
		end
	elseif event == "DUEL_FINISHED" and duelStartedAt then
		local fought = GetTime() - duelStartedAt >= COUNTDOWN_SECONDS
		duelStartedAt = nil
		pending = {}
		capture:Hide()
		if fought then
			say(GoodDuelDB.endText)
		end
	end
end)
