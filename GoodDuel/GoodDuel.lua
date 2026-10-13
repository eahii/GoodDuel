local START_TEXT = "gl hf"
local END_TEXT = "gd"
local PENDING_MAX_AGE = 20
local COUNTDOWN_SECONDS = 3

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

local function say(text)
	pending[#pending + 1] = { text = text, queuedAt = GetTime() }
	capture:Show()
end

local duelStartedAt = nil

local events = CreateFrame("Frame")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:RegisterEvent("DUEL_FINISHED")
events:SetScript("OnEvent", function(_, event, text)
	if event == "CHAT_MSG_SYSTEM" then
		if issecretvalue and issecretvalue(text) then
			return
		end
		if not duelStartedAt and type(text) == "string" and text:match(countdownPattern) then
			duelStartedAt = GetTime()
			say(START_TEXT)
		end
	elseif event == "DUEL_FINISHED" and duelStartedAt then
		local fought = GetTime() - duelStartedAt >= COUNTDOWN_SECONDS
		duelStartedAt = nil
		pending = {}
		if fought then
			say(END_TEXT)
		else
			capture:Hide()
		end
	end
end)
