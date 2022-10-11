---@diagnostic disable: undefined-global
local export = {}

local inp_Mode = -1
local inp_Bias = -1
local inp_TotalInputs = 0
local inp_RepeatChance = 33

-- walkmode takes control whenever the player is 
-- located in the overworld and is able to move around freely
-- Walkmode Input Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local wlk_Group1Chance = 10
local wlk_Group2Chance = 80
local wlk_Group3Chance = 10
local wlk_aChance = 80
local wlk_bChance = 20
local wlk_upChance = 25
local wlk_downChance = 25
local wlk_leftChance = 25
local wlk_rightChance = 25
local wlk_startChance = 60
local wlk_selectChance = 40

-- actmode takes control whenever the player is
-- locked into interacting with something, such as talking to a npc or having to navigate through a menu
-- Act Mode Input Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local act_Group1Chance = 60
local act_Group2Chance = 30
local act_Group3Chance = 10
local act_aChance = 60
local act_bChance = 40
local act_upChance = 32
local act_downChance = 32
local act_leftChance = 18
local act_rightChance = 18
local act_startChance = 60
local act_selectChance = 40

-- battlemode takes control whenever the player is
-- in any kind of active battle screen, excluding things such as the bag and pokemon (switch) menues
-- Battle Mode Input Groups Groups 1:[A B] 2:[Up Down Left Right] 3:[Start Select]
local btl_Group1Chance = 60
local btl_Group2Chance = 30
local btl_Group3Chance = 10
local btl_aChance = 80
local btl_bChance = 20
local btl_upChance = 32
local btl_downChance = 18
local btl_leftChance = 32
local btl_rightChance = 18
local btl_startChance = 40
local btl_selectChance = 60


---------------------------------------
-- INPUTS -----------------------------
---------------------------------------

-- mode is decided by the caller (gen specific script)
-- Input Mode: 0 = Walk Mode (Overworld), 1 = Act Mode (Menu) 2 = Battle Mode (Battles)
function export.HandleInputs(mode, lastinputs)
    inp_Mode = mode
    inp_TotalInputs = inp_TotalInputs + 1

    local rng = math.random(0, 100)

    -- decide whether to repeat input or generate a new one
    if rng < inp_RepeatChance and lastinputs ~= nil then
        return lastinputs
    else
        if inp_Mode == 0 then return WalkModeInput() end
        if inp_Mode == 1 then return ActModeInput() end
        if inp_Mode == 2 then return BattleModeInput() end
    end
end


---------------------------------------
-- INPUTS DEPENDING ON MODE SELECTED --
---------------------------------------

-- selects a random input for walk mode (WLK)
function export.WalkModeInput()
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

    return inputtable
end

-- selects a random input for act mode (ACT)
function export.ActModeInput()
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

    return inputtable
end

-- selects a random input for battle mode (BTL)
function export.BattleModeInput()
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

    return inputtable
end


---------------------------------------
-- BIAS -------------------------------
---------------------------------------

-- sets bias based on kayboard inputs
function export.HandleBias()

    -- keyboard inputs for bias
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
        wlk_downChance = 20
        wlk_leftChance = 25
        wlk_rightChance = 25

    -- Down Bias
    elseif inp_Bias == 2 then
        wlk_upChance = 20
        wlk_downChance = 30
        wlk_leftChance = 25
        wlk_rightChance = 25

    -- Left Bias
    elseif inp_Bias == 3 then
        wlk_upChance = 25
        wlk_downChance = 25
        wlk_leftChance = 30
        wlk_rightChance = 20

    -- Right Bias
    elseif inp_Bias == 4 then
        wlk_upChance = 25
        wlk_downChance = 25
        wlk_leftChance = 20
        wlk_rightChance = 30
    end
end

---------------------------------------
-- GETTERS SETTERS --------------------
---------------------------------------

function export.GetInputMode()
    return inp_Mode
end

function export.GetBiasMode()
    return inp_Bias
end

function export.GetTotalInputs()
    return inp_TotalInputs
end

function export.SetTotalInputs(amount)
    inp_TotalInputs = amount
end

function export.GetChancesByMode(mode)
    if mode == 0 then return { A = wlk_aChance, B = wlk_bChance, up = wlk_upChance, down = wlk_downChance, left = wlk_leftChance, right = wlk_rightChance, start = wlk_startChance, select = wlk_selectChance, L = 0, R = 0, group1 = wlk_Group1Chance, group2 = wlk_Group2Chance, group3 = wlk_Group3Chance } end
    if mode == 1 then return { A = act_aChance, B = act_bChance, up = act_upChance, down = act_downChance, left = act_leftChance, right = act_rightChance, start = act_startChance, select = act_selectChance, L = 0, R = 0, group1 = act_Group1Chance, group2 = act_Group2Chance, group3 = act_Group3Chance } end
    if mode == 2 then return { A = btl_aChance, B = btl_bChance, up = btl_upChance, down = btl_downChance, left = btl_leftChance, right = btl_rightChance, start = btl_startChance, select = btl_selectChance, L = 0, R = 0, group1 = btl_Group1Chance, group2 = btl_Group2Chance, group3 = btl_Group3Chance } end
end

return export