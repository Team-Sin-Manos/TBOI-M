
--Startup
----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are dOne_Stats.
--Startup
local mod = RegisterMod("Commission Template - Character + Tainted", 1)
local game = Game()
local rng = RNG()

---@param name string
---@param isTainted boolean
---@param speed number
---@param tears number
---@param damage number
---@param range number
---@param shotspeed number
---@param luck number
---@param tearcolor Color
---@param flying boolean
---@param tearflag TearFlags
---@return table
local function characterStats(name, isTainted, speed, tears, damage, range, shotspeed, luck, tearcolor, flying, tearflag) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
	local character = { -- these stats are added to Isaac's base stats.
		NAME = name,
		ID = Isaac.GetPlayerTypeByName(name, isTainted), -- string, boolean
		Costume_ID = Isaac.GetCostumeIdByPath("gfx/characters/"..name.."-head.anm2"),
		Stats = {
			SPEED = speed, -- number
			FIREDELAY = tears, -- number
			DAMAGE = damage, -- number
			RANGE = range, -- number
			SHOTSPEED = shotspeed, -- number
			LUCK = luck, -- number
			TEARCOLOR = tearcolor, -- Color
			FLYING = flying, -- boolean
			TEARFLAG = tearflag, -- TearFlags
		},
	}
	return character
end
--Character Stat Definitions
----------characterStats(NAME, isTainted, SPEED, FIREDELAY, DAMAGE, RANGE, SHOTSPEED, LUCK, TEARCOLOR, FLYING, TEARFLAG)
mod.One_Stats = characterStats("One", false, 0, 0, 0, 0, 0, 0, Color(1,1,1,1,0,0,0), false, TearFlags.TEAR_NORMAL)
mod.Two_Stats = characterStats("Two", true, 0, 0, 0, 0, 0, 0, Color(1,1,1,1,0,0,0), false, TearFlags.TEAR_NORMAL)

--Stat Functions
local function toTears(fireDelay) --thanks oat for the cool functions for calculating firerate!
	return 30 / (fireDelay + 1)
end
local function fromTears(tears)
	return math.max((30 / tears) - 1, -0.99)
end

function mod:evalCache(player, cacheFlag) -- this function applies all the stats the character gains/loses on a new run.
	if player:GetName() == mod.One_Stats.NAME then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + mod.One_Stats.Stats.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = math.max(1.0, fromTears(toTears(player.MaxFireDelay) + mod.One_Stats.Stats.FIREDELAY))
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + mod.One_Stats.Stats.SHOTSPEED
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + mod.One_Stats.Stats.SPEED
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + mod.One_Stats.Stats.LUCK
		end
		if cacheFlag == CacheFlag.CACHE_FLYING and mod.One_Stats.Stats.FLYING then
			player.CanFly = true
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | mod.One_Stats.Stats.TEARFLAG
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = mod.One_Stats.Stats.TEARCOLOR
		end
	end
	if player:GetName() == mod.Two_Stats.NAME then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + mod.Two_Stats.Stats.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = math.max(1.0, fromTears(toTears(player.MaxFireDelay) + mod.Two_Stats.Stats.FIREDELAY))
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + mod.Two_Stats.Stats.SHOTSPEED
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + mod.Two_Stats.Stats.SPEED
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + mod.Two_Stats.Stats.LUCK
		end
		if cacheFlag == CacheFlag.CACHE_FLYING and mod.Two_Stats.Stats.FLYING then
			player.CanFly = true
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | mod.Two_Stats.Stats.TEARFLAG
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = mod.Two_Stats.Stats.TEARCOLOR
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:playerSpawn(player)
    if player:GetName() == mod.One_Stats.NAME then
        player:AddNullCostume(mod.One_Stats.Costume_ID)
    end
    if player:GetName() == mod.Two_Stats.NAME then
        player:AddNullCostume(mod.Two_Stats.Costume_ID)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.playerSpawn)