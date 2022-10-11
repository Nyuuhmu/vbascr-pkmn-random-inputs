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
local compatibleVersions = 3

local actionLength = 18
local saveGameQueued = false

math.randomseed(os.time())

-- input
local inp_InputTable = {}
local inp_LastInputTable = {}

-- memory
local mem_PlayerDataPointerAddr = 0x00000000
local mem_PlayerDataAddr = 0x00000000

local mem_PlayerName = ""
local mem_PlayerNameAddr = 0x00000000
local mem_PlayerNameAddrOffset = 0x00
local mem_HoursPlayedAddr = 0x00000000
local mem_HoursPlayedAddrOffset = 0x00
local mem_HoursPlayedValue = 0
local mem_MinutesPlayedAddr = 0x00000000
local mem_MinutesPlayedAddrOffset = 0x00
local mem_MinutesPlayedValue = 0
local mem_SecondsPlayedAddr = 0x00000000
local mem_SecondsPlayedAddrOffset = 0x00
local mem_SecondsPlayedValue = 0
local mem_FramesPlayedAddr = 0x00000000
local mem_FramesPlayedAddrOffset = 0x00
local mem_MenuSelectionAddr = 0x00000000
local mem_MenuSelectionAmountAddr = 0x00000000
local mem_CanWalkOnOverworldAddr = 0x00000000
local mem_SceneTypeAddr = 0x00000000
local mem_InputBG3Addr = 0x00000000
local mem_InputBG3Value = 0x0000
local mem_EvolutionBG3Addr = 0x00000000
local mem_EvolutionBG3Value = 0x0000
local mem_EvolutionBG3PixelCheckAddr = 0x00000000
local mem_EvolutionBG3PixelCheckValue = 0x0000

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

    if gameVersion == 31 then
        SetupRubySapphire()
    elseif gameVersion == 32 then
        SetupRubySapphire()
    elseif gameVersion == 33 then
        SetupEmerald()
    else vba.print("Wrong Version. Detected: " .. versionHandler.GetVersionName(gameVersion) .. ", but expected: " .. versionHandler.GetVersionName(compatibleVersions)) end
end

-- sets up memory addresses for ruby and sapphire
function SetupRubySapphire()
    mem_PlayerDataPointerAddr = 0x03001FB4
    mem_PlayerDataAddr = 0x00000000 -- Automatic Set
    mem_PlayerNameAddr = 0x00000000 -- Automatic Set
    mem_PlayerNameAddrOffset = 0x00
    mem_HoursPlayedAddr = 0x00000000 -- Automatic Set
    mem_HoursPlayedAddrOffset = 0x0E
    mem_MinutesPlayedAddr = 0x00000000 -- Automatic Set
    mem_MinutesPlayedAddrOffset = 0x10
    mem_SecondsPlayedAddr = 0x00000000 -- Automatic Set
    mem_SecondsPlayedAddrOffset = 0x11
    mem_FramesPlayedAddr = 0x00000000 -- Automatic Set
    mem_FramesPlayedAddrOffset = 0x00
    mem_MenuSelectionAddr = 0x0202E8FC
    mem_MenuSelectionAmountAddr = 0x0202E8FD
    mem_CanWalkOnOverworldAddr = 0x030006A4
    mem_SceneTypeAddr = 0x0202105A
    mem_InputBG3Addr = 0x0600F000
    mem_InputBG3Value = 0x027A
    mem_EvolutionBG3Addr = 0x0600D000
    mem_EvolutionBG3Value = 0x2062
    mem_EvolutionBG3PixelCheckAddr = 0x050001E4
    mem_EvolutionBG3PixelCheckValue = 0x001F
end

-- sets up memory addresses for emerald
function SetupEmerald()
    mem_PlayerDataPointerAddr = 0x03005D90
    mem_PlayerDataAddr = 0x00000000 -- Automatic Set
    mem_PlayerNameAddr = 0x00000000 -- Automatic Set
    mem_PlayerNameAddrOffset = 0x00
    mem_HoursPlayedAddr = 0x00000000 -- Automatic Set
    mem_HoursPlayedAddrOffset = 0x0E
    mem_MinutesPlayedAddr = 0x00000000 -- Automatic Set
    mem_MinutesPlayedAddrOffset = 0x10
    mem_SecondsPlayedAddr = 0x00000000 -- Automatic Set
    mem_SecondsPlayedAddrOffset = 0x11
    mem_FramesPlayedAddr = 0x00000000 -- Automatic Set
    mem_FramesPlayedAddrOffset = 0x00
    mem_MenuSelectionAddr = 0x0203760E
    mem_MenuSelectionAmountAddr = 0x0203760F
    mem_CanWalkOnOverworldAddr = 0x03000F2C
    mem_SceneTypeAddr = 0x02021686
    mem_InputBG3Addr = 0x0600F800
    mem_InputBG3Value = 0xF00F
    mem_EvolutionBG3Addr = 0x0600D000
    mem_EvolutionBG3Value = 0x2062
    mem_EvolutionBG3PixelCheckAddr = 0x050001A8
    mem_EvolutionBG3PixelCheckValue = 0x7F5F
end


---------------------------------------
-- GET SHIT FROM MEMORY FUNCTIONS -----
---------------------------------------

-- finds player data (emerald moves it around a lot)
function FindPlayerData()
    mem_PlayerDataAddr = string.format("%x", memory.readdword(mem_PlayerDataPointerAddr))

    mem_PlayerNameAddr = ("0x" .. (helperFunctions.ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_PlayerNameAddrOffset)))
    mem_HoursPlayedAddr = ("0x" .. (helperFunctions.ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_HoursPlayedAddrOffset)))
    mem_HoursPlayedValue = memory.readword(mem_HoursPlayedAddr)
    mem_MinutesPlayedAddr = ("0x" .. (helperFunctions.ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_MinutesPlayedAddrOffset)))
    mem_MinutesPlayedValue = memory.readbyte(mem_MinutesPlayedAddr)
    mem_SecondsPlayedAddr = ("0x" .. (helperFunctions.ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_SecondsPlayedAddrOffset)))
    mem_SecondsPlayedValue = memory.readbyte(mem_SecondsPlayedAddr)
end

-- finds the playername from memory
function FindPlayerName()
    local name = ""
    local namedec = memory.readbyterange(mem_PlayerNameAddr, 8)

    for i = 1,8,1 do
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
    local scenetype = memory.readbyte(mem_SceneTypeAddr)

    if scenetype == 0xA0 then return 1 end
    if scenetype == 0x1E then return 2 end

    return 0
end

-- returns the inputtable for this frame
function GetInputs()
    return inputHandler.HandleInputs(GetMode(), inp_LastInputTable)
end

-- applies special overwrites for special ingame happenings, such as evolutions
function HandleAndApplySpecialInputRules()
    local rng = math.random(0, 100)
    guiHandler.SetSpecialRulesText("")

    -- input field rules (needs better determination, basing it off the background palette is kinda dumb?)
    if memory.readword(mem_InputBG3Addr) == mem_InputBG3Value then
        guiHandler.SetSpecialRulesText("Input Field Rule")

        inp_InputTable.start = false
        if inp_InputTable.B == true and rng < 75 then inp_InputTable.B = false end
    end

    -- evolution rules (needs better determination, basing it off the background palette is kinda dumb?)
    if memory.readword(mem_EvolutionBG3Addr) == mem_EvolutionBG3Value then
        if memory.readword(mem_EvolutionBG3PixelCheckAddr) == mem_EvolutionBG3PixelCheckValue then
            guiHandler.SetSpecialRulesText("Evolution Rule")

            inp_InputTable.B = false
        end
    end

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
    FindPlayerName() -- helps updating the playername at the start of the game
    vba.print("Attempting to create an ingame Save...")
    savingAttemptActive = true

    -- get current menu selection to reapply later
    local currentmenuselection = memory.readbyte(mem_MenuSelectionAddr)

    -- set menu selection to save
    memory.writebyte("0x" .. helperFunctions.ToHex(mem_MenuSelectionAddr), memory.readbyte(mem_MenuSelectionAmountAddr) - 3)
    inp_InputTable = {}

    -- open menu
    local cnt = 0
    guiHandler.SetGameSavingDisplay("ATTEMPTING TO OPEN MENU")

    while memory.readbyte(mem_CanWalkOnOverworldAddr) == 00 and cnt < 8 do
        cnt = cnt + 1

        joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = true, select = false, R = false, L = false})
        for i = 1, actionLength do vba.frameadvance() end

        joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
        for i = 1, actionLength do vba.frameadvance() end
    end

    for i = 1, actionLength do vba.frameadvance() end

    -- update display information
    if memory.readbyte(mem_CanWalkOnOverworldAddr) == 00 then
        guiHandler.SetGameSavingDisplay("OPENING MENU FAILED")
        for i = 1, 200 do vba.frameadvance() end 
    else guiHandler.SetGameSavingDisplay("NAVIGATING MENU") end

    -- save by pressing a
    while memory.readbyte(mem_CanWalkOnOverworldAddr) == 01 do
        joypad.set(1, {A = true, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
        for i = 1, actionLength do vba.frameadvance() end

        joypad.set(1, {A = false, B = false, up = false, down = false, left = false, right = false, start = false, select = false, R = false, L = false})
        for i = 1, actionLength do vba.frameadvance() end
    end

    -- reset menu selection
    memory.writebyte("0x" .. helperFunctions.ToHex(mem_MenuSelectionAddr), currentmenuselection)

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
        if inpmode == 0 and memory.readbyte(mem_CanWalkOnOverworldAddr) == 00 then CreateIngameSave() end
    end

    -- decide whether we should save or continue
    if (mem_MinutesPlayedValue == 30 and mem_SecondsPlayedValue == 0x00) then
        vba.frameadvance()

        FindPlayerData()
        filedataHandler.SaveInputs(versionHandler.GetVersionName(gameVersion), mem_PlayerName, inputHandler.GetTotalInputs())

        -- check if we are able to save in current situation, otherwise queue
        if inpmode == 0 and memory.readbyte(mem_CanWalkOnOverworldAddr) == 00 then
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