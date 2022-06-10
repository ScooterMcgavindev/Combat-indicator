local CreateFrame = CreateFrame
local UnitAffectingCombat = UnitAffectingCombat
local UnitExists = UnitExists
local pairs = pairs

local CombatIndicatorDB_local
local events = {}
function events:ADDON_LOADED(...)
	if select(1, ...) == "CombatIndicator" then
		CombatIndicatorDB_local = CombatIndicatorDB
		if not CombatIndicatorDB_local then -- addon loaded for first time
			CombatIndicatorDB_local = {}
			print("CombatIndicator load default")
			CombatIndicatorDB_local["point"] = "CENTER"
			CombatIndicatorDB_local["relativePoint"] = "CENTER"
			CombatIndicatorDB_local["xOffset"] = 0
			CombatIndicatorDB_local["yOffset"] = 0
		end

		-- safe check all saved variables are there (in case older version was loaded)
		if not CombatIndicatorDB_local["point"] then CombatIndicatorDB_local["point"] = "CENTER" end
		if not CombatIndicatorDB_local["relativePoint"] then CombatIndicatorDB_local["relativePoint"] = "CENTER" end
		if not CombatIndicatorDB_local["xOffset"] then CombatIndicatorDB_local["xOffset"] = 0 end
		if not CombatIndicatorDB_local["yOffset"] then CombatIndicatorDB_local["yOffset"] = 0 end

		addon:UnregisterEvent("ADDON_LOADED")
		print("CombatIndicator Loaded")
	end
end

--- gets executed once all ui information is available
function events:PLAYER_ENTERING_WORLD()
    addon:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

--- save variables to SavedVariables
function events:PLAYER_LOGOUT()
	CombatIndicatorDB = CombatIndicatorDB_local
end



local function FrameOnUpdate(self)
    for _,ciFrame in pairs(self.ciFrames) do
        if UnitExists(ciFrame.unit) and UnitAffectingCombat(ciFrame.unit) then
            ciFrame:Show()
        else
            ciFrame:Hide()
        end
    end
end

local function OnDragStart(self)
    if( IsAltKeyDown() ) then
        self.isMoving = true
        self:StartMoving()
    end
end

local function OnDragStop(self)
    if( self.isMoving ) then
        self.isMoving = nil
        self:StopMovingOrSizing()
    end
	local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
end

local ciCore = CreateFrame("Frame")
ciCore.ciFrames = {}
ciCore:SetScript("OnUpdate", FrameOnUpdate)

local function CreateCombatIndicatorForUnit(unit, frame, offset, size)

    local ciFrame = CreateFrame("Frame", "CombatIndicator" .. unit, frame)
	
	ciFrame:ClearAllPoints()
	ciFrame:SetMovable(true)
	ciFrame:EnableMouse(true)
	ciFrame:SetClampedToScreen(true)
	ciFrame:RegisterForDrag("LeftButton")
	ciFrame:SetScript("OnDragStart", OnDragStart)
	ciFrame:SetScript("OnDragStop", OnDragStop)
    ciFrame:SetPoint("TOP", UIParent, "TOP", -300, -350)
    ciFrame:SetSize(size, size)
    ciFrame.texture = ciFrame:CreateTexture(nil, "BORDER")
    ciFrame.texture:SetAllPoints(ciFrame)
    ciFrame.texture:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    ciFrame:Hide()
    ciFrame.unit = unit
	ciFrame:SetScript("OnUpdate", StatsFrame.update)
	ciFrame:SetScript("OnEnter", StatsFrame.enter)
	ciFrame:RegisterEvent("PLAYER_LOGIN")
	ciFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	
    return ciFrame
end


ciCore.ciFrames["target"] = CreateCombatIndicatorForUnit("target", XPerl_TargetportraitFrame, {x = -200, y = -30}, 15)
ciCore.ciFrames["focus"] = CreateCombatIndicatorForUnit("focus", XPerl_FocusportraitFrame, {x = -270, y = -30}, 15)