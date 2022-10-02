-- Useful Links
-- https://tasvideos.org/EmulatorResources/VBA/LuaScriptingFunctions
-- https://github.com/DevonStudios/LuaScripts

-- Made by Nyuuh 10/2022

local actionLength = 10
math.randomseed(os.time())

-- Input
local inp_InputTable = {}
local inp_LastInputTable = {}
local inp_RepeatChance = 33
local inp_RepeatCount = 0
local inp_TotalInputs = 0
local inp_Mode = -1
local inp_Bias = -1

-- Memory and PlayerData
local mem_PlayerDataPointerAddr = 0x03005D90
local mem_PlayerDataAddr = 0x00
local mem_pd_PlayerNameOffset = 0x00
local mem_pd_HoursPlayedOffset = 0x0E
local mem_pd_MinutesPlayedOffset = 0x10
local mem_pd_SecondsPlayedOffset = 0x11
local mem_pd_FramesPlayedOffset = 0x12

local mem_OverworldWalkAddr = 0x02037372
local mem_CanWalkOnOverworldAddr = 0x03000F2C
local mem_SceneTypeAddr = 0x02021686

local pd_PlayerName = ""

-- Current Mode Chances (md: Mode Display)
local md_Group1Chance = 0
local md_Group2Chance = 0
local md_Group3Chance = 0
local md_aChance = 0
local md_bChance = 0
local md_upChance = 0
local md_downChance = 0
local md_leftChance = 0
local md_rightChance = 0
local md_startChance = 0
local md_selectChance = 0

-- Walkmode Input Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local wlk_Group1Chance = 15
local wlk_Group2Chance = 80
local wlk_Group3Chance = 5
local wlk_aChance = 60
local wlk_bChance = 40
local wlk_upChance = 25
local wlk_downChance = 25
local wlk_leftChance = 25
local wlk_rightChance = 25
local wlk_startChance = 50
local wlk_selectChance = 50

-- Act Mode Input Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local act_Group1Chance = 80
local act_Group2Chance = 15
local act_Group3Chance = 5
local act_aChance = 60
local act_bChance = 40
local act_upChance = 30
local act_downChance = 20
local act_leftChance = 30
local act_rightChance = 20
local act_startChance = 50
local act_selectChance = 50

-- Battle Mode Input Groups Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local btl_Group1Chance = 80
local btl_Group2Chance = 15
local btl_Group3Chance = 5
local btl_aChance = 75
local btl_bChance = 25
local btl_upChance = 35
local btl_downChance = 15
local btl_leftChance = 35
local btl_rightChance = 15
local btl_startChance = 50
local btl_selectChance = 50


---------------------------------------
-- HELPER FUNCTIONS -------------------
---------------------------------------

-- Converts a Decimal (string) into a Hex
function ToHex(str)
    return string.format("%x", tostring(str))
end

-- Formats Numbers to have leading 0's
function FormatNum(num)
    if num < 10 then return (0 .. num) else return num end
end


---------------------------------------
-- GET SHIT FROM MEMORY FUNCTIONS -----
---------------------------------------

-- Finds the ever elusive PlayerData
function FindPlayerData()
    mem_PlayerDataAddr = string.format("%x", memory.readdword(mem_PlayerDataPointerAddr))
end

-- Returns the Total Time Played in HH:MM:SS:FF
function GetTotalTimePlayed()
    local hh = memory.readword("0x" .. (ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_pd_HoursPlayedOffset)))
    local mm = memory.readbyte("0x" .. (ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_pd_MinutesPlayedOffset)))
    local ss = memory.readbyte("0x" .. (ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_pd_SecondsPlayedOffset)))
    local ff = memory.readbyte("0x" .. (ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_pd_FramesPlayedOffset)))

    return (hh .. ":" .. FormatNum(mm) .. ":" .. FormatNum(ss) .. ":" .. FormatNum(ff))
end

-- Gets the PlayerName from Memory, Ascii: 65 is A, Pkmn: BB/187 is A, Offset is -122
function GetPlayerName()
    local name = ""
    local namedec = memory.readbyterange("0x" .. (ToHex(tonumber(mem_PlayerDataAddr, 16) + mem_pd_PlayerNameOffset)), 8)

    for i = 1,8,1 do
        if namedec[i] ~= 255 then name = name .. string.char(namedec[i] - 122) end
    end

    pd_PlayerName = name
end


---------------------------------------
-- DISPLAY THINGS ---------------------
---------------------------------------

-- Set Chances for the Display
function UpdateDisplayChances(g1, g2, g3, a, b, up, down, left, right, start, sel)
    md_Group1Chance = g1
    md_Group2Chance = g2
    md_Group3Chance = g3
    md_aChance = a
    md_bChance = b
    md_upChance = up
    md_downChance = down
    md_leftChance = left
    md_rightChance = right
    md_startChance = start
    md_selectChance = sel
end

-- Displays Button Inputs
function DrawInputDisplay()

    -- Background Lines
    gui.text(150, 5, "---", "black") 
    gui.text(173, 5, "--------", "black")
    gui.text(218, 5, "---", "black")

    gui.line(150, 8, 149, 21, "black")
    gui.line(161, 8, 160, 21, "black")
    gui.line(173, 8, 173, 21, "black")
    gui.line(184, 8, 184, 21, "black")
    gui.line(195, 8, 195, 21, "black")
    gui.line(206, 8, 206, 21, "black")
    gui.line(219, 8, 219, 21, "black")
    gui.line(230, 8, 230, 21, "black")

    -- Inputs
    if inp_InputTable.A then gui.text(149, 5, "A", "green") else gui.text(149, 5, "A", "grey") end
    if inp_InputTable.B then gui.text(160, 5, "B", "green") else gui.text(160, 5, "B", "grey") end
    if inp_InputTable.up then gui.text(172, 5, "U", "green") else gui.text(172, 5, "U", "grey") end
    if inp_InputTable.down then gui.text(183, 5, "D", "green") else gui.text(183, 5, "D", "grey") end
    if inp_InputTable.left then gui.text(194, 5, "L", "green") else gui.text(194, 5, "L", "grey") end
    if inp_InputTable.right then gui.text(205, 5, "R", "green") else gui.text(205, 5, "R", "grey") end
    if inp_InputTable.start then gui.text(216, 5, "ST", "green") else gui.text(216, 5, "ST", "grey") end
    if inp_InputTable.select then gui.text(227, 5, "SL", "green") else gui.text(227, 5, "SL", "grey") end

    -- Chances
    gui.text(147, 15, FormatNum(math.floor(md_aChance * (md_Group1Chance / 100))))
    gui.text(158, 15, FormatNum(math.floor(md_bChance * (md_Group1Chance / 100))))
    gui.text(216, 15, FormatNum(math.floor(md_startChance * (md_Group3Chance / 100))))
    gui.text(227, 15, FormatNum(math.floor(md_selectChance * (md_Group3Chance / 100))))

    -- Chances, Input Bias Colouring
    if inp_Bias ~= -1 and inp_Mode == 0 then 
        if inp_Bias == 1 then 
            gui.text(170, 15, FormatNum(math.floor(md_upChance * (md_Group2Chance / 100))), "green")
        else gui.text(170, 15, FormatNum(math.floor(md_upChance * (md_Group2Chance / 100))), "orange") end

        if inp_Bias == 2 then 
            gui.text(181, 15, FormatNum(math.floor(md_downChance * (md_Group2Chance / 100))), "green")
        else gui.text(181, 15, FormatNum(math.floor(md_downChance * (md_Group2Chance / 100))), "orange") end

        if inp_Bias == 3 then 
            gui.text(192, 15, FormatNum(math.floor(md_leftChance * (md_Group2Chance / 100))), "green")
        else gui.text(192, 15, FormatNum(math.floor(md_leftChance * (md_Group2Chance / 100))), "orange") end

        if inp_Bias == 4 then 
            gui.text(203, 15, FormatNum(math.floor(md_rightChance * (md_Group2Chance / 100))), "green")
        else gui.text(203, 15, FormatNum(math.floor(md_rightChance * (md_Group2Chance / 100))), "orange") end
    else 
        gui.text(170, 15, FormatNum(math.floor(md_upChance * (md_Group2Chance / 100))))
        gui.text(181, 15, FormatNum(math.floor(md_downChance * (md_Group2Chance / 100))))
        gui.text(192, 15, FormatNum(math.floor(md_leftChance * (md_Group2Chance / 100))))
        gui.text(203, 15, FormatNum(math.floor(md_rightChance * (md_Group2Chance / 100))))
    end
end

-- Displays current Input Mode
function DrawModeDisplay()
    local text
    
    if inp_Mode == 0 then text = "WLK" 
    elseif inp_Mode == 1 then text = "ACT" 
    elseif inp_Mode == 2 then text = "BTL" end

    gui.text(130, 15, text)
end

-- Displays Bias Mode Information
function DrawBiasDisplay() 
    local biastext

    if inp_Bias == 1 then biastext = "   WLK Bias - Up"
    elseif inp_Bias == 2 then biastext = " WLK Bias - Down"
    elseif inp_Bias == 3 then biastext = " WLK Bias - Left"
    elseif inp_Bias == 4 then biastext = "WLK Bias - Right"
    else biastext = " WLK Bias - None" end

    gui.text(171, 25, biastext)
end

-- Draws General Information such as PlayerName, Total Time, etc.
function DrawInformation()
    gui.text(5, 5, pd_PlayerName .. " " .. GetTotalTimePlayed())
    gui.text(5, 15, inp_TotalInputs .. " (" .. inp_RepeatCount .. ")")
end


---------------------------------------
-- SELECT INPUT MODES AND BIAS --------
---------------------------------------

function HandleInputs()

    -- Input Mode: 0 = Walk Mode (Overworld), 1 = Act Mode (Menu) 2 = Battle Mode (Battles)
    local scenetype = memory.readbyte(mem_SceneTypeAddr)

    if scenetype == 0xA0 then 
        inp_Mode = 1
    elseif scenetype == 0x1E then
        inp_Mode = 2
    else inp_Mode = 0 end

    local rng = math.random(0, 100)

    -- Decide whether to repeat Input or generate a new one
    if rng < inp_RepeatChance and inp_TotalInputs ~= 0 then 
        inp_InputTable = inp_LastInputTable
        inp_RepeatCount = inp_RepeatCount + 1
    else
        if inp_Mode == 0 then inp_InputTable = WalkModeInput() 
        elseif inp_Mode == 1 then inp_InputTable = ActModeInput() 
        elseif inp_Mode == 2 then inp_InputTable = BattleModeInput() end

        inp_RepeatCount = 0
    end
end

function HandleBias()

    -- Keyboard Inputs for Bias
    local keyinputs = input.get()
    if keyinputs["W"] then inp_Bias = 1 end
    if keyinputs["A"] then inp_Bias = 3 end
    if keyinputs["S"] then inp_Bias = 2 end
    if keyinputs["D"] then inp_Bias = 4 end
    if keyinputs["Q"] or keyinputs["E"] or keyinputs["R"] then inp_Bias = -1 end

    -- No Bias
    if inp_Bias == -1 then 
        wlk_upChance = 25
        wlk_downChance = 25
        wlk_leftChance = 25
        wlk_rightChance = 25

    -- Up Bias
    elseif inp_Bias == 1 then 
        wlk_upChance = 30
        wlk_downChance = 22
        wlk_leftChance = 24
        wlk_rightChance = 24

    -- Down Bias
    elseif inp_Bias == 2 then 
        wlk_upChance = 22
        wlk_downChance = 30
        wlk_leftChance = 24
        wlk_rightChance = 24

    -- Left Bias
    elseif inp_Bias == 3 then 
        wlk_upChance = 24
        wlk_downChance = 24
        wlk_leftChance = 30
        wlk_rightChance = 22

    -- Right Bias
    elseif inp_Bias == 4 then 
        wlk_upChance = 24
        wlk_downChance = 24
        wlk_leftChance = 22
        wlk_rightChance = 30
    end
end


---------------------------------------
-- INPUTS DEPENDING ON MODE SELECTED --
---------------------------------------

-- Selects a random Input for Walk Mode (WLK)
function WalkModeInput()
    local rng1 = math.random(0, 100)
    local rng2 = math.random(0, 100)

    local inputtable = {}
    inputtable = joypad.get(1)

    -- A/B
    if rng1 < wlk_Group1Chance then 

        if rng2 < wlk_aChance then 
            inputtable.A = true
        elseif rng2 < wlk_aChance + wlk_bChance then 
            inputtable.B = true 
        end

    -- Up Down Left Right
    elseif rng1 < wlk_Group1Chance + wlk_Group2Chance then
        
        if rng2 < wlk_upChance then
            inputtable.up = true
        elseif rng2 < wlk_upChance + wlk_downChance then
            inputtable.down = true
        elseif rng2 < wlk_upChance + wlk_downChance + wlk_leftChance then
            inputtable.left = true
        elseif rng2 < wlk_upChance + wlk_downChance + wlk_leftChance + wlk_rightChance then
            inputtable.right = true
        end

    -- Start Select
    elseif rng1 < wlk_Group1Chance + wlk_Group2Chance + wlk_Group3Chance then

        if rng2 < wlk_startChance then
            inputtable.start = true
        elseif rng2 < wlk_startChance + wlk_selectChance then
            inputtable.select = true
        end
    end

    -- Update Chances for Display
    UpdateDisplayChances(wlk_Group1Chance, wlk_Group2Chance, wlk_Group3Chance, wlk_aChance, wlk_bChance, wlk_upChance, wlk_downChance, wlk_leftChance, wlk_rightChance, wlk_startChance, wlk_selectChance)

    return inputtable
end

-- Selects a random Input for Act Mode (ACT)
function ActModeInput()
    local rng1 = math.random(0, 100)
    local rng2 = math.random(0, 100)

    local inputtable = {}
    inputtable = joypad.get(1)

    -- A/B
    if rng1 < act_Group1Chance then 

        if rng2 < act_aChance then 
            inputtable.A = true
        elseif rng2 < act_aChance + act_bChance then 
            inputtable.B = true 
        end

    -- Up Down Left Right
    elseif rng1 < act_Group1Chance + act_Group2Chance then
        
        if rng2 < act_upChance then
            inputtable.up = true
        elseif rng2 < act_upChance + act_downChance then
            inputtable.down = true
        elseif rng2 < act_upChance + act_downChance + act_leftChance then
            inputtable.left = true
        elseif rng2 < act_upChance + act_downChance + act_leftChance + act_rightChance then
            inputtable.right = true
        end

    -- Start Select
    elseif rng1 < act_Group1Chance + act_Group2Chance + act_Group3Chance then

        if rng2 < act_startChance then
            inputtable.start = true
        elseif rng2 < act_startChance + act_selectChance then
            inputtable.select = true
        end
    end

    -- Update Chances for Display
    UpdateDisplayChances(act_Group1Chance, act_Group2Chance, act_Group3Chance, act_aChance, act_bChance, act_upChance, act_downChance, act_leftChance, act_rightChance, act_startChance, act_selectChance)

    return inputtable
end

-- Selects a random Input for Battle Mode (BTL)
function BattleModeInput()
    local rng1 = math.random(0, 100)
    local rng2 = math.random(0, 100)

    local inputtable = {}
    inputtable = joypad.get(1)

    -- A/B
    if rng1 < btl_Group1Chance then 

        if rng2 < btl_aChance then 
            inputtable.A = true
        elseif rng2 < btl_aChance + btl_bChance then 
            inputtable.B = true 
        end

    -- Up Down Left Right
    elseif rng1 < btl_Group1Chance + btl_Group2Chance then
        
        if rng2 < btl_upChance then
            inputtable.up = true
        elseif rng2 < btl_upChance + btl_downChance then
            inputtable.down = true
        elseif rng2 < btl_upChance + btl_downChance + btl_leftChance then
            inputtable.left = true
        elseif rng2 < btl_upChance + btl_downChance + btl_leftChance + btl_rightChance then
            inputtable.right = true
        end

    -- Start Select
    elseif rng1 < btl_Group1Chance + btl_Group2Chance + btl_Group3Chance then

        if rng2 < btl_startChance then
            inputtable.start = true
        elseif rng2 < btl_startChance + btl_selectChance then
            inputtable.select = true
        end
    end

    -- Update Chances for Display
    UpdateDisplayChances(btl_Group1Chance, btl_Group2Chance, btl_Group3Chance, btl_aChance, btl_bChance, btl_upChance, btl_downChance, btl_leftChance, btl_rightChance, btl_startChance, btl_selectChance)

    return inputtable
end


---------------------------------------
-- SAVING AND LOADING -----------------
---------------------------------------

-- Save Input Count to File
function SaveInputs()
    vba.print("Saving Inputs...")
    local filename = (pd_PlayerName .. "_InputCount.txt")

    local file,err = io.open(filename, 'w')
    if file then
        file:write(tostring(inp_TotalInputs))
        file:close()
    else vba.print("error:", err) end

    vba.print("Successfully Saved Inputs! Total Inputs: " .. inp_TotalInputs)
end

-- Load Input Count from File
function LoadInputs()
    vba.print("Loading Inputs...")
    local filename = (pd_PlayerName .. "_InputCount.txt")

    local file,err = io.open(filename, 'r')
    if file then
        inp_TotalInputs = file:read()
        file:close()
    else vba.print("error:", err) end

    vba.print("Successfully Loaded Inputs! Total Inputs: " .. inp_TotalInputs)
end

-- Create a new Savestate (dun work)
function CreateSaveState()
    savestate.save(savestate.create(10))
end


---------------------------------------
-- MAIN -------------------------------
---------------------------------------

FindPlayerData()
GetPlayerName()
LoadInputs()

while true do

    -- Inputs
    HandleInputs()
    HandleBias()

    -- Progress Loop
    for i = 1, actionLength do 

        -- Set Inputs
        joypad.set(1, inp_InputTable) 

        -- Advance to next Frame (apply Inputs)
        vba.frameadvance() 

        -- Find PlayerData again because that one's a slippery Bastard
        FindPlayerData()

        -- Draw Texts and Information
        DrawInformation()
        DrawInputDisplay()
        DrawModeDisplay()
        DrawBiasDisplay()
    end

    -- Save Input Amounts
    if inp_TotalInputs % 10000 == 0 then
        SaveInputs()
        --CreateSaveState()
    end

    inp_LastInputTable = inp_InputTable
    inp_TotalInputs = inp_TotalInputs + 1
end