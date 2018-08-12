local _G = _G
local _, HN = ...
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_MoleMachine")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")
_G.HNMoleMachine = HN

local pairs, next = _G.pairs, _G.next
local IsQuestFlaggedCompleted = _G.IsQuestFlaggedCompleted
local GetMapChildrenInfo = _G.C_Map.GetMapChildrenInfo
local ElvUI = _G.ElvUI

HN.Plugin = {}
HN.CurrentMap = 0
HN.ContinentData = {}

HN.DefaultSettings = {["Alpha"] = 1, ["Scale"] = 2.5}
HN.Options = {
  type = "group",
  name = L["Mole Machine"],
  get = function(info)
    return HN.Config[info.arg]
  end,
  set = function(info, v)
    HN.Config[info.arg] = v
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MoleMachine")
  end,
  args = {
    scale = {
      type = "range",
      name = L["Icon scale"],
      desc = L["The scale of the icons."],
      min = 0.25, max = 5, step = 0.05,
      arg = "Scale",
      order = 10,
    },
    alpha = {
      type = "range",
      name = L["Icon alpha"],
      desc = L["The alpha transparency of the icons."],
      min = 0, max = 1, step = 0.01,
      arg = "Alpha",
      order = 20,
    },
  },
}

HN.Drills = {
  [13534680] = {26, L["Aerie Peak"], 53585},
  [31517359] = {390, L["Stormstout Brewery"], 53598},
  [33302480] = {35, L["The Masonary"], 53587},
  [39110930] = {199, L["The Great Divide"], 53600},
  [44667290] = {650, L["Neltharion's Vault"], 53593},
  [45354992] = {115, L["Ruby Dragonshrine"], 53596},
  [46693876] = {543, L["Blackrock Foundry Overlook"], 53588},
  [50773530] = {104, L["Fel Pits"], 53599},
  [50931607] = {35, L["Shadowforge City"], nil},
  [52885576] = {78, L["Fire Plume Ridge"], 53591},
  [57187711] = {198, L["Throne of Flame"], 53601},
  [57686281] = {379, L["One Keg"], 53595},
  [61293718] = {27, L["Ironforge"], nil},
  --[61442435] = {1186, L["Shadowforge City"], nil},
  [61971280] = {17, L["Nethergarde Keep"], 53594},
  [63333734] = {84, L["Stormwind"], nil},
  [65750825] = {550, L["Elemental Plateau"], 53590},
  [71694799] = {646, L["Broken Shore"], 53589},
  [72421764] = {105, L["Skald"], 53597},
  [76971866] = {118, L["Argent Tournament Grounds"], 53586}
}

local function ElvUISwag(sender)
  if sender == "Livarax-BurningLegion" then
    return [[|TInterface\PvPRankBadges\PvPRank09:0|t ]]
  end
  return nil
end

function HN:CheckMap(mapID)
  for _, p in pairs(HN.ContinentData[HN.CurrentMap]) do
    if mapID == p.mapID then
      return true
    end
  end
  return false
end

function HN.Plugin:OnEnter(_, coord)
  local tooltip = self:GetParent() == _G.WorldMapButton and _G.WorldMapTooltip or _G.GameTooltip
  if self:GetCenter() > _G.UIParent:GetCenter() then
    tooltip:SetOwner(self, "ANCHOR_LEFT")
  else
    tooltip:SetOwner(self, "ANCHOR_RIGHT")
  end
  local drill = HN.Drills[coord]
  if drill then
    tooltip:AddLine(drill[2])
    if drill[3] and not IsQuestFlaggedCompleted(drill[3]) then
      tooltip:AddLine(L["Undiscovered"], 1, 0, 0)
    end
    tooltip:Show()
  end
end

function HN.Plugin:OnLeave(_, _)
  local tooltip = self:GetParent() == _G.WorldMapButton and _G.WorldMapTooltip or _G.GameTooltip
  tooltip:Hide()
end

local function Iterator(t, last)
  if not t or HN.CurrentMap == 946 then return end
  local k, v = next(t, last)
  while k do
    if v then
      if v[1] == HN.CurrentMap or (HN.ContinentData[HN.CurrentMap] and HN.ContinentData[HN.CurrentMap] ~= 0 and HN:CheckMap(v[1])) then
        local icon = (v[3] and not IsQuestFlaggedCompleted(v[3])) and "MiniMap-DeadArrow" or "MiniMap-QuestArrow"
        return k, v[1], "Interface\\Minimap\\"..icon, HN.Config.Scale, HN.Config.Alpha
      end
    end
    k, v = next(t, k)
  end
end

function HN.Plugin:GetNodes2(mapID, _)
  HN.CurrentMap = mapID
  if not HN.ContinentData[HN.CurrentMap] and HN.CurrentMap ~= 946 then
    HN.ContinentData[HN.CurrentMap] = GetMapChildrenInfo(HN.CurrentMap, nil, true) or 0
  end
  return Iterator, HN.Drills
end

HN.Frame = CreateFrame("Frame")
HN.Frame:RegisterEvent("PLAYER_LOGIN")
HN.Frame:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function HN.Frame:PLAYER_LOGIN()
  if not _G.HNMoleMachineConfig then _G.HNMoleMachineConfig = HN.DefaultSettings end
  HN.Config = _G.HNMoleMachineConfig
  for key, value in pairs(HN.DefaultSettings) do
    if HN.Config[key] == nil then
      HN.Config[key] = value
    end
  end

  if ElvUI then
    ElvUI[1]:GetModule("Chat"):AddPluginIcons(ElvUISwag)
  end

  HandyNotes:RegisterPluginDB("MoleMachine", HN.Plugin, HN.Options)
end
