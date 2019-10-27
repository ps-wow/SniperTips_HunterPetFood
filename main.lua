local SniperTips_HunterPetFood = LibStub("AceAddon-3.0"):NewAddon('SniperTips_HunterPetFood');
local LibTooltip = LibStub("SniperTips-2.0");
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

--Only load the addon if player is a hunter
function SniperTips_HunterPetFood:PlayerClassIsHunter()
  local _, englishClass, _ = UnitClass('player');
  return englishClass == 'HUNTER'
end

----------------
-- Core Logic --
----------------
function SniperTips_HunterPetFood:ItemIsFood(item)
  -- TODO: Can this if statement be simplified with a boolean return?
  if (item.classID == 0) then
    return true
  end
  return false
end

function SniperTips_HunterPetFood:HandleItem(self, item)

  if (SniperTips_HunterPetFood:PlayerClassIsHunter() == false) then
    return
  end

  -- Only load for the consumables item category
  if (SniperTips_HunterPetFood:ItemIsFood(item) == false) then
    return -- void
  end

  local rating, ratingColour = SniperTips_HunterPetFood:GetFoodRating(item)

  if (rating ~= nil and ratingColour ~= nil) then
    self:AddDoubleLine(
      SniperTips_HunterPetFood.Globals.TitleColour.escape.."Food Rating: ",
      ratingColour..rating
    );
  end
end

----------------------
-- Hunter Pet Logic --
----------------------

function SniperTips_HunterPetFood:GetFoodRating(item)
  local petExists = UnitExists("pet")
  local petFoodRatings = {
    ["Cat"] = {
      [8952] = { ["good"] = 61, ["bad"] = 65, ["na"] = 999 }, -- Roasted Quail
    },
    ["Bear"] = {
    },
    ["Boar"] = {
      [8952] = { ["good"] = 99, ["bad"] = 99, ["na"] = 99 }, -- Roasted Quail
      --[1015] = { ["good"] = 29, ["bad"] = 999, ["na"] = 99 }, -- Lean Wolf Flank, placeholders: bad/na
      --[4536] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 }, -- Shiny Red Apple [13 = placeholder value]
      --[11584] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 }, -- Cactus Apple Surprise [13 = placeholder value]
      -- TODO: !important: 22 and 60 are placeholder values
      -- [2677] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
      -- [2681] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
      --[117] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 } -- Tough Jerky [13 = placeholder value]
    },
    ["Wolf"] = {
      -- TODO: Also placeholder values for development
      --[2681] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
      --[769] = { ["good"] = 13, ["bad"] = 22, ["na"] = 60 },
    }
  }

  if (petExists) then
    -- Get the pet type: eg. Boar
    local petType = UnitCreatureFamily("pet");
    -- Get the pet level.
    local petLevel = UnitLevel("pet");

    -- Only load ratings if we have them defined for the petType
    SniperTips_HunterPetFood:Dump('ratings for pet', petFoodRatings[petType])
    if (petFoodRatings[petType] ~= nil) then
      -- Lookup the item id against the pet type
      local ratings = petFoodRatings[petType][item.id] or nil;
      local rating, ratingColour;

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
    end -- (/if petFoodRatings[petType])
  end -- (/if petExists)

  return nil, nil
end

------------------
-- Registration --
------------------

LibTooltip:AddItemHandler(SniperTips_HunterPetFood)
