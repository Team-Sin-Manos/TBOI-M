
--Startup
----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are dOne_Character.
--Startup
local mod = RegisterMod("Commission Template - Character + Tainted", 1)
local json = require("json")
local game = Game()
local rng = RNG()

--Stat Functions
local function toTears(fireDelay) --thanks oat for the cool functions for calculating firerate!
	return 30 / (fireDelay + 1)
end
local function fromTears(tears)
	return math.max((30 / tears) - 1, -0.99)
end

--Character Functions
---@param name string
---@param isTainted boolean
---@return table
local function addCharacter(name, isTainted) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
	local character = { -- these stats are added to Isaac's base stats.
		NAME = name,
		ID = Isaac.GetPlayerTypeByName(name, isTainted), -- string, boolean
		Costume_ID = Isaac.GetCostumeIdByPath("gfx/characters/"..name.."-head.anm2"),
	}
	return character
end
mod.One_Character = addCharacter("One", false)
mod.Two_Character = addCharacter("Two", true)

function mod:evalCache(player, cacheFlag) -- this function applies all the stats the character gains/loses on a new run.
	---@param name string
	---@param speed number
	---@param tears number
	---@param damage number
	---@param range number
	---@param shotspeed number
	---@param luck number
	---@param tearcolor Color
	---@param flying boolean
	---@param tearflag TearFlags
	local function addStats(name, speed, tears, damage, range, shotspeed, luck, tearcolor, flying, tearflag) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
		if player:GetPlayerType(name) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + speed
			end
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = math.max(1.0, fromTears(toTears(player.MaxFireDelay) + tears))
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + damage
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.TearRange = player.TearRange + range * 40
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + shotspeed
			end
			if cacheFlag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + luck
			end
			if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = tearcolor
			end
			if cacheFlag == CacheFlag.CACHE_FLYING and flying then
				player.CanFly = true
			end
			if cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | tearflag
			end
		end
	end
	mod.One_Stats = addStats("One", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
	mod.Two_Stats = addStats("Two", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:playerSpawn(player)
    if player:GetPlayerType(mod.One_Character.NAME) then
        player:AddNullCostume(mod.One_Character.Costume_ID)
    end
    if player:GetPlayerType(mod.Two_Character.NAME) then
        player:AddNullCostume(mod.Two_Character.Costume_ID)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.playerSpawn)

--Saving and Loading Data!
local persistentData = {
	unlocks = {
		One = {
			MOM = false,
		},
		Two = {
			MOM = false,
		},
	}
}

function mod:STOREsavedata()
	local jsonString = json.encode(persistentData)
	mod:SaveData(jsonString)
end

function mod:LOADsavedata()
	if mod:HasData() then
		local myTable = json.decode(mod:LoadData())
	end
end

function mod:preGameExit()
	mod:STOREsavedata()
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)

function mod:OnGameStart(isSave)
	mod:LOADsavedata()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnGameStart)

function mod:GetSaveData()
	if not mod.persistentData then
		if mod:HasData() then
			mod.persistentData = json.decode(mod:LoadData())
		else
			mod.persistentData = {}
		end
	end
		return mod.persistentData
end

--Debug Console
function mod.oncmd(_, command, args)
	if command == "unlocks" and args == mod.One_Character.NAME then
		print(mod.One_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
	end
	if command == "unlocks" and args == mod.Two_Character.NAME then
		print(mod.Two_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
		if mod:HasData() then
			print("MOM")
			print(mod:GetSaveData().unlocks.Two.MOM)
		end
	end
	if command == "unlocks" and args == mod.Two_Character.NAME .. " unlock" then
		print(mod.Two_Character.NAME.."'s UNLOCKS ARE ALL UNLOCKED")
		if mod:HasData() then
			persistentData.unlocks.Two.MOM = true
			mod:STOREsavedata()

			print("MOM")
			print(mod:GetSaveData().unlocks.Two.MOM)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.oncmd)