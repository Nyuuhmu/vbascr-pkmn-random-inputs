---@diagnostic disable: undefined-global
-- Useful Links
-- https://tasvideos.org/EmulatorResources/VBA/LuaScriptingFunctions
-- https://github.com/DevonStudios/LuaScripts

-- Made by Nyuuh 10/2022

local versionHandler = require "Handlers\\version_handler"
local filedataHandler = require "Handlers\\filedata_handler"
local guiHandler = require "Handlers\\gui_handler"
local inputHandler = require "Handlers\\input_handler"
local helperFunctions = require "Handlers\\helper_functions"

local gameVersion = -1
local compatibleVersions = 1

local actionLength = 18
local saveGameQueued = false

math.randomseed(os.time())

-- input
local inp_InputTable = {}
local inp_LastInputTable = {}

-- memory
local mem_PlayerName = ""
local mem_PlayerNameAddr = 0x0000
local mem_HoursPlayedAddr = 0x0000
local mem_HoursPlayedValue = 0
local mem_MinutesPlayedAddr = 0x0000
local mem_MinutesPlayedValue = 0
local mem_SecondsPlayedAddr = 0x0000
local mem_SecondsPlayedValue = 0
local mem_FramesPlayedAddr = 0x00000000
local mem_FramesPlayedAddrOffset = 0x00
local mem_LastMenuSelectionAddr = 0x0000
local mem_MenuSelectionAmountAddr = 0x0000
local mem_CanWalkOnOverworldAddr = 0x0000
local mem_CanWalkOnOverworldValue = 0x00
local mem_MapBaseAddr = 0x0000
local mem_BattleMapValue = 0x00

-- Etc
local savingAttemptActive = false
local drawInformation = true
local drawInputDisplay = true
local drawInputModeInformation = true
local drawBiasInformation = true


---------------------------------------
-- SETUP FUNCTIONS --------------------
---------------------------------------

-- finds which version is being played and calls setups
function SetupGameVersion()
    gameVersion = versionHandler.FindVersion()
    vba.print("Found Version: " .. versionHandler.GetVersionName(gameVersion))

    if gameVersion == 11 then
        SetupRedBlue()
    elseif gameVersion == 12 then
        SetupRedBlue()
    elseif gameVersion == 13 then
        SetupYellow()
    else vba.print("Wrong Version. Detected: " .. versionHandler.GetVersionName(gameVersion) .. ", but expected: " .. versionHandler.GetVersionName(compatibleVersions)) end
end

-- sets up memory addresses for yellow
function SetupYellow()
    mem_PlayerNameAddr = 0xD157
    mem_HoursPlayedAddr = 0xDA40
    mem_MinutesPlayedAddr = 0xDA42
    mem_SecondsPlayedAddr = 0xDA43
    --mem_FramesPlayedAddr = 0x00000000
    --mem_FramesPlayedAddrOffset = 0x00
    mem_LastMenuSelectionAddr = 0xCC2D
    mem_MenuSelectionAmountAddr = 0xCC28
    mem_CanWalkOnOverworldAddr = 0xFFB0
    mem_CanWalkOnOverworldValue = 0x90
    mem_MapBaseAddr = 0x9C00
    mem_BattleMapValue = 0x7F
end

-- sets up memory addresses for red and blue
function SetupRedBlue()
    SetupYellow() -- currently not implemented
end


---------------------------------------
-- GET SHIT FROM MEMORY FUNCTIONS -----
---------------------------------------

-- finds player data
function FindPlayerData()
    mem_HoursPlayedValue = memory.readword(mem_HoursPlayedAddr)
    mem_MinutesPlayedValue = memory.readbyte(mem_MinutesPlayedAddr)
    mem_SecondsPlayedValue = memory.readbyte(mem_SecondsPlayedAddr)
end

-- finds the playername from memory
function FindPlayerName()
    local name = ""
    local namedec = memory.readbyterange(mem_PlayerNameAddr, 7)

    for i = 1,7,1 do
        if namedec[i] ~= 255 then name = name .. versionHandler.GetChar(gameVersion, (namedec[i] + 1)) end
    end

    mem_PlayerName = name
end

-- returns the total time played in HH:MM:SS
function GetTotalTimePlayed()
    return (mem_HoursPlayedValue .. ":" .. helperFunctions.FormatNum(mem_MinutesPlayedValue) .. ":" .. helperFunctions.FormatNum(mem_SecondsPlayedValue))
end


---------------------------------------
-- SELECT INPUT MODES AND BIAS --------
---------------------------------------

-- returns the input mode based on generation specific attributes
function GetMode()
    local scenetype = memory.readbyte(mem_MapBaseAddr)

    if memory.readbyte(mem_CanWalkOnOverworldAddr) == mem_CanWalkOnOverworldValue then
        return 0
    else
        if scenetype == mem_BattleMapValue then
            return 2
        else return 1 end
    end
end

-- returns the inputtable for this frame
function GetInputs()
    return inputHandler.HandleInputs(GetMode(), inp_LastInputTable)
end

-- applies special overwrites for special ingame happenings, such as evolutions
function HandleAndApplySpecialInputRules()
    local rng = math.random(0, 100)
    guiHandler.SetSpecialRulesText("")

end


---------------------------------------
-- SAVING AND LOADING -----------------
---------------------------------------

-- create a new savestate (dun work)
function CreateSaveState()
    savestate.save(savestate.create(10))
end

-- creates an ingame save
function CreateIngameSave()
    vba.print("Attempting to create an ingame Save...")
    savingAttemptActive = true

    -- get current menu selection to reapply later
    local currentmenuselection = memory.readbyte(mem_LastMenuSelectionAddr)

    -- set menu selection to save
    memory.writebyte("0x" .. helperFunctions.ToHex(mem_LastMenuSelectionAddr), memory.readbyte(mem_MenuSelectionAmountAddr) - 3)
    inp_InputTable = {}

    -- open menu
    local cnt = 0
    guiHandler.SetGameSavingDisplay("ATTEMPTING TO OPEN MENU")

    while memory.readbyte(mem_CanWalkOnOverworldAddr) == mem_CanWalkOnOverworldValue and cnt < 8 do
        cnt = cnt + 1

        for i = 1, 2 do
            joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = true, select = false, R = false, L = false})
            vba.frameadvance()
        end
        
        for i = 1, actionLength do vba.frameadvance() end

        joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
        for i = 1, actionLength do vba.frameadvance() end
    end

    cnt = 0
    for i = 1, actionLength do vba.frameadvance() end

    -- update display information
    if memory.readbyte(mem_CanWalkOnOverworldAddr) == mem_CanWalkOnOverworldValue then
        guiHandler.SetGameSavingDisplay("OPENING MENU FAILED")
        for i = 1, 200 do vba.frameadvance() end 
    else guiHandler.SetGameSavingDisplay("NAVIGATING MENU") end

    -- save by pressing a
    while memory.readbyte(mem_CanWalkOnOverworldAddr) ~= mem_CanWalkOnOverworldValue and cnt < 50 do
        cnt = cnt + 1

        for i = 1, 2 do
            joypad.set(1, {A = true, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
            vba.frameadvance()
        end
        for i = 1, actionLength do vba.frameadvance() end

        for i = 1, 2 do
            joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
            vba.frameadvance()
        end
        for i = 1, actionLength do vba.frameadvance() end
    end

    -- reset menu selection
    memory.writebyte("0x" .. helperFunctions.ToHex(mem_LastMenuSelectionAddr), currentmenuselection)

    saveGameQueued = false
    savingAttemptActive = false
    guiHandler.SetGameSavingDisplay("")
end


---------------------------------------
-- MAIN -------------------------------
---------------------------------------

vba.print("=== Starting Version Check")

SetupGameVersion()
if string.sub(gameVersion, 0, 1) ~= tostring(compatibleVersions) then return end

vba.print("=== Loading and Setting Data")

vba.registerbefore(guiHandler.DrawGameSavingDisplay)
vba.registerbefore(guiHandler.DrawSpecialRuleDisplay)

FindPlayerData()
FindPlayerName()
inputHandler.SetTotalInputs(tonumber(filedataHandler.LoadInputs(versionHandler.GetVersionName(gameVersion), mem_PlayerName)))

vba.print("=== Starting Script")

while true do
    if savingAttemptActive then return end

    -- inputs
    inp_InputTable = GetInputs()
    inputHandler.HandleBias()
    HandleAndApplySpecialInputRules()

    local inpmode = inputHandler.GetInputMode()

    if saveGameQueued then
        if inpmode == 0 and memory.readbyte(mem_CanWalkOnOverworldAddr) == mem_CanWalkOnOverworldValue then CreateIngameSave() end
    end

    -- decide whether we should save or continue
    if (mem_MinutesPlayedValue == 30 and mem_SecondsPlayedValue == 0x00) then
        vba.frameadvance()

        FindPlayerData()
        filedataHandler.SaveInputs(versionHandler.GetVersionName(gameVersion), mem_PlayerName, inputHandler.GetTotalInputs())

        -- check if we are able to save in current situation, otherwise queue
        if inpmode == 0 and memory.readbyte(mem_CanWalkOnOverworldAddr) == mem_CanWalkOnOverworldValue then
            CreateIngameSave()
        else saveGameQueued = true end
    else

        -- progress loop
        for i = 1, actionLength do

            -- set inputs
            joypad.set(1, inp_InputTable)

            -- advance to next frame (apply inputs)
            vba.frameadvance()

            -- find playerdata again because that one's a slippery bastard
            FindPlayerData()

            -- draw texts and information
            if drawInformation then guiHandler.DrawRunInformation(gameVersion, mem_PlayerName, GetTotalTimePlayed(), inputHandler.GetTotalInputs()) end
            if drawInputDisplay then guiHandler.DrawInputDisplay(inp_InputTable, inputHandler.GetChancesByMode(inpmode), inputHandler.GetBiasMode()) end
            if drawInputModeInformation then guiHandler.DrawModeDisplay(inpmode) end
            if drawBiasInformation then guiHandler.DrawBiasDisplay(inputHandler.GetBiasMode()) end
            if saveGameQueued then guiHandler.DrawSaveGameQueuedInformation() end
        end

        inp_LastInputTable = inp_InputTable
    end

end