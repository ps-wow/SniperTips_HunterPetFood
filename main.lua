local SniperTips_HunterPetFood = LibStub("AceAddon-3.0"):NewAddon('SniperTips_HunterPetFood');
local LibTooltip = LibStub("SniperTips-1.0");
local tipColour = { 0.6, 0.2, 0.2 }
SniperTips_HunterPetFood.kbDEBUG = true

SniperTips_HunterPetFood.Globals = {
  ["TitleColour"] = {
    ["escape"] = "|cFFABD473",
    ["rgb"] = { 0.67, 0.83, 0.45 },
    ["rgba"] = { 0.67, 0.83, 0.45, 1 },
  },
  -- 170, 141, 114
  ["Ratings"] = {
    ["NA"] = { 
      ["escape"] = "|cFF9D9D9D",
      ["rgba"] = { 0.62, 0.62, 0.62, 1 }
    },
    ["Bad"] = { 
      ["escape"] = "|cFFFFFFFF",
      ["rgba"] = { 1.00, 1.00, 1.00, 1 }
    },
    ["Good"] = { 
      ["escape"] = "|cFF00A7DD",
      ["rgba"] = { 0.00, 0.44, 0.87, 1 }
    },
    ["Epic"] = {
      ["escape"] = "|cFFA335EE",
      ["rgba"] = { 0.64, 0.21, 0.93, 1 }
    }
  },
  ["NA"] = "N/A",
  ["Bad"] = "Bad",
  ["Good"] = "Good",
  ["Epic"] = "Epic",
}

function SniperTips_HunterPetFood:Dump(str, obj)
  if ViragDevTool_AddData and SniperTips_HunterPetFood.kbDEBUG then 
      ViragDevTool_AddData(obj, str) 
  end
end

---------------------------------------------------
-- Methods to determine if the addon should load --
---------------------------------------------------

-- Only load the addon if on a classic realm.
function SniperTips_HunterPetFood:IsClassicRealm()
  -- Game is classic if GetPetHappiness global function exists.
  if _G['GetPetHappiness'] ~= nil then
    return true
  end

  -- return false -- TODO: once happy with classic logic
  return true
end

--Only load the addon if player is a hunter
function SniperTips_HunterPetFood:PlayerClassIsHunter()
  _, englishClass, _ = UnitClass('player');
  return englishClass == 'HUNTER'
end

-- Combine the above two checks into a single function.
function SniperTips_HunterPetFood:AddonShouldLoad()
  return SniperTips_HunterPetFood:PlayerClassIsHunter() and SniperTips_HunterPetFood:IsClassicRealm()
end

----------------
-- Core Logic --
----------------

function SniperTips_HunterPetFood:HandleItem(self, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
  itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
  itemSetID, isCraftingReagent)
  
  -- Get the item ID
  local id = string.match(itemLink, "item:(%d*)")

  local rating, ratingColour = SniperTips_HunterPetFood:GetFoodRating(id)

  SniperTips_HunterPetFood:Dump('rating', rating)

  if (rating ~= nil and ratingColour ~= nil) then
    --self:AddDoubleLine("Food Rating: ",rating,unpack(SniperTips_HunterPetFood.Globals.TitleColour),unpack(ratingColour));
    self:AddDoubleLine(
      SniperTips_HunterPetFood.Globals.TitleColour.escape.."Food Rating: ",
      ratingColour..rating
    );
  end
end

----------------------
-- Hunter Pet Logic --
----------------------

function SniperTips_HunterPetFood:GetFoodRating(itemId)
  local petExists = UnitExists("pet")
  local petFoodRatings = {
    ["Boar"] = {
       -- TODO: !important: 20 and 60 are placeholder values
      ["2681"] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
      ["117"] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
    },
    ["Wolf"] = {
      -- TODO: Also placeholder values for development
      ["2681"] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
      ["769"] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
    }
  }

  if (petExists) then
    -- Get the pet type: eg. Boar
    local petType = UnitCreatureFamily("pet");
    -- Get the pet level.
    local petLevel = UnitLevel("pet");

    -- Lookup the item id against the pet type
    ratings = petFoodRatings[petType][itemId] or nil;

    if (ratings ~= nil) then
      -- return the rating (coloured)
      if (petLevel >= ratings.na) then
        rating = SniperTips_HunterPetFood.Globals.NA
        ratingColour = SniperTips_HunterPetFood.Globals.Ratings.NA.escape
      elseif (petLevel >= ratings.bad) then
        rating = SniperTips_HunterPetFood.Globals.Bad
        ratingColour = SniperTips_HunterPetFood.Globals.Ratings.Bad.escape
      elseif (petLevel >= ratings.good) then
        rating = SniperTips_HunterPetFood.Globals.Good
        ratingColour = SniperTips_HunterPetFood.Globals.Ratings.Good.escape
      else
        rating = SniperTips_HunterPetFood.Globals.Epic
        ratingColour = SniperTips_HunterPetFood.Globals.Ratings.Epic.escape
      end

      return rating, ratingColour
    end
  end

  return nil, nil
end

------------------
-- Registration --
------------------

if (SniperTips_HunterPetFood:AddonShouldLoad()) then
  LibTooltip:AddItemHandler(SniperTips_HunterPetFood)
end
