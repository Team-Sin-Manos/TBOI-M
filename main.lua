local MyCharacterMod = RegisterMod("Gabriel Character Mod", 1)

-- Character types matching players.xml names
local moquiType = Isaac.GetPlayerTypeByName("Moqui", false)
local taintedMoquiType = Isaac.GetPlayerTypeByName("Tainted Moqui", true)

-- Costumes unchanged, referencing original Gabriel assets
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_hair.anm2")
local stolesCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_stoles.anm2")

function MyCharacterMod:GiveCostumesOnInit(player)
    local pType = player:GetPlayerType()
    if pType ~= moquiType and pType ~= taintedMoquiType then
        return
    end
    player:AddNullCostume(hairCostume)
    player:AddNullCostume(stolesCostume)
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.GiveCostumesOnInit)

local game = Game()
local HOLY_OUTBURST_ID = Isaac.GetItemIdByName("Holy Outburst")

-- Cache update for Moqui stats (keep tears, range, shotspeed default)
function MyCharacterMod:HandleStartingStats(player, flag)
    local pType = player:GetPlayerType()

    if pType == moquiType then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = 2.5
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = 0.8
        end

    elseif pType == taintedMoquiType then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = 3.5
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = 0.9
        end
    end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MyCharacterMod.HandleStartingStats)

-- Helper to set hearts properly
local function SetHeartsTo(player, halfHearts)
    -- Remove all hearts first:
    player:SetMaxHearts(0)
    player:AddMaxHearts(halfHearts)
    player:SetHearts(halfHearts)
end

-- Set starting items & stats once on player init
function MyCharacterMod:OnPlayerInit(player)
    local pType = player:GetPlayerType()

    if pType == moquiType then
        -- Add the tick trinket only (items handled by XML)
        player:AddTrinket(TrinketType.TRINKET_TICK, true)

    elseif pType == taintedMoquiType then
        -- Give Holy Outburst pocket item for tainted Moqui
        player:SetPocketActiveItem(HOLY_OUTBURST_ID, ActiveSlot.SLOT_POCKET, true)
        local pool = game:GetItemPool()
        pool:RemoveCollectible(HOLY_OUTBURST_ID)
    end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.OnPlayerInit)

-- Holy Outburst item usage effect
function MyCharacterMod:HolyOutburstUse(_, _, player)
    local spawnPos = player.Position
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, spawnPos, Vector.Zero, player):ToEffect()
    creep.Scale = 2
    creep:Update()
    return true
end
MyCharacterMod:AddCallback(ModCallbacks.MC_USE_ITEM, MyCharacterMod.HolyOutburstUse, HOLY_OUTBURST_ID)

-- Optional: Holy water trail effect for both characters
function MyCharacterMod:HandleHolyWaterTrail(player)
    local pType = player:GetPlayerType()
    if pType ~= moquiType and pType ~= taintedMoquiType then
        return
    end
    if game:GetFrameCount() % 4 == 0 then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player):ToEffect()
        creep.SpriteScale = Vector(0.5, 0.5)
        creep:Update()
    end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MyCharacterMod.HandleHolyWaterTrail)
