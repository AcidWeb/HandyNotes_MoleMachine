local _G = _G
local _, HN = ...
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
  name = "Mole Machine",
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
      name = "Icon Scale",
      desc = "The scale of the icons.",
      min = 0.25, max = 5, step = 0.05,
      arg = "Scale",
      order = 10,
    },
    alpha = {
      type = "range",
      name = "Icon Alpha",
      desc = "The alpha transparency of the icons.",
      min = 0, max = 1, step = 0.01,
      arg = "Alpha",
      order = 20,
    },
  },
}

HN.Drills = {
  [13534680] = {26, "Aerie Peak", 53585},
  [31517359] = {390, "Stormstout Brewery", 53598},
  [33302480] = {35, "The Masonary", 53587},
  [39110930] = {199, "The Great Divide", 53600},
  [44667290] = {650, "Neltharion's Vault", 53593},
  [45354992] = {115, "Ruby Dragonshrine", 53596},
  [46693876] = {543, "Blackrock Foundry Overlook", 53588},
  [50773530] = {104, "Fel Pits", 53599},
  [50931607] = {35, "Shadowforge City", nil},
  [52885576] = {78, "Fire Plume Ridge", 53591},
  [57187711] = {198, "Throne of Flame", 53601},
  [57686281] = {379, "One Keg", 53595},
  [61293718] = {27, "Ironforge", nil},
  --[61442435] = {1186, "Shadowforge City", nil},
  [61971280] = {17, "Nethergarde Keep", 53594},
  [63333734] = {84, "Stormwind", nil},
  [65750825] = {550, "Elemental Plateau", 53590},
  [71694799] = {646, "Broken Shore", 53589},
  [72421764] = {105, "Skald", 53597},
  [76971866] = {118, "Argent Tournament Grounds", 53586}
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
      tooltip:AddLine("Undiscovered", 1, 0, 0)
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
