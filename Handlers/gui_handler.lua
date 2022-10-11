---@diagnostic disable: undefined-global
local export = {}

local helperFunctions = require "Handlers\\helper_functions"

local specialRulesText = ""
local savingAttemptProcessText = ""


---------------------------------------
-- GENERAL INFORMATION ----------------
---------------------------------------

-- displays information such as playername, total time, etc.
function export.DrawRunInformation(gameversion, playername, timeplayed, totalinputs)
    gui.text(5, 5, playername .. " " .. timeplayed)
    gui.text(5, 15, totalinputs)

    if saveGameQueued then gui.text(5, 25, "GAME SAVE QUEUED", "orange") end
end

-- displays current input mode
function export.DrawModeDisplay(mode)
    local text

    if mode == 0 then text = "WLK"
    elseif mode == 1 then text = "ACT"
    elseif mode == 2 then text = "BTL" end

    gui.text(130, 15, text)
end

-- displays bias mode information
function export.DrawBiasDisplay(bias)
    local biastext

    if bias == 1 then biastext = "   WLK Bias - Up"
    elseif bias == 2 then biastext = " WLK Bias - Down"
    elseif bias == 3 then biastext = " WLK Bias - Left"
    elseif bias == 4 then biastext = "WLK Bias - Right"
    else biastext = " WLK Bias - None" end

    gui.text(171, 25, biastext)
end

-- displays button inputs
function export.DrawInputDisplay(inputtable, chancestable, bias)

    -- background lines
    gui.text(150, 5, "---", "black")
    gui.text(173, 5, "--------", "black")
    gui.text(218, 5, "---", "black")

    gui.line(150, 8, 150, 21, "black")
    gui.line(161, 8, 161, 21, "black")
    gui.line(173, 8, 173, 21, "black")
    gui.line(184, 8, 184, 21, "black")
    gui.line(195, 8, 195, 21, "black")
    gui.line(206, 8, 206, 21, "black")
    gui.line(219, 8, 219, 21, "black")
    gui.line(230, 8, 230, 21, "black")

    -- inputs
    if inputtable.A then gui.text(149, 5, "A", "green") else gui.text(149, 5, "A", "grey") end
    if inputtable.B then gui.text(160, 5, "B", "green") else gui.text(160, 5, "B", "grey") end
    if inputtable.up then gui.text(172, 5, "U", "green") else gui.text(172, 5, "U", "grey") end
    if inputtable.down then gui.text(183, 5, "D", "green") else gui.text(183, 5, "D", "grey") end
    if inputtable.left then gui.text(194, 5, "L", "green") else gui.text(194, 5, "L", "grey") end
    if inputtable.right then gui.text(205, 5, "R", "green") else gui.text(205, 5, "R", "grey") end
    if inputtable.start then gui.text(216, 5, "ST", "green") else gui.text(216, 5, "ST", "grey") end
    if inputtable.select then gui.text(227, 5, "SL", "green") else gui.text(227, 5, "SL", "grey") end

    -- chances
    gui.text(147, 15, helperFunctions.FormatNum(math.floor(chancestable.A * (chancestable.group1 / 100) + 0.5)))
    gui.text(158, 15, helperFunctions.FormatNum(math.floor(chancestable.B * (chancestable.group1 / 100) + 0.5)))
    gui.text(216, 15, helperFunctions.FormatNum(math.floor(chancestable.start * (chancestable.group3 / 100) + 0.5)))
    gui.text(227, 15, helperFunctions.FormatNum(math.floor(chancestable.select * (chancestable.group3 / 100) + 0.5)))

    -- chances, input bias colouring
    if bias ~= -1 and inp_Mode == 0 then
        if bias == 1 then
            gui.text(170, 15, helperFunctions.FormatNum(math.floor(chancestable.up * (chancestable.group2 / 100) + 0.5)), "green")
        else gui.text(170, 15, helperFunctions.FormatNum(math.floor(chancestable.up * (chancestable.group2 / 100) + 0.5)), "orange") end

        if bias == 2 then
            gui.text(181, 15, helperFunctions.FormatNum(math.floor(chancestable.down * (chancestable.group2 / 100) + 0.5)), "green")
        else gui.text(181, 15, helperFunctions.FormatNum(math.floor(chancestable.down * (chancestable.group2 / 100) + 0.5)), "orange") end

        if bias == 3 then
            gui.text(192, 15, helperFunctions.FormatNum(math.floor(chancestable.left * (chancestable.group2 / 100) + 0.5)), "green")
        else gui.text(192, 15, helperFunctions.FormatNum(math.floor(chancestable.left * (chancestable.group2 / 100) + 0.5)), "orange") end

        if bias == 4 then
            gui.text(203, 15, helperFunctions.FormatNum(math.floor(chancestable.right * (chancestable.group2 / 100) + 0.5)), "green")
        else gui.text(203, 15, helperFunctions.FormatNum(math.floor(chancestable.right * (chancestable.group2 / 100) + 0.5)), "orange") end
    else
        gui.text(170, 15, helperFunctions.FormatNum(math.floor(chancestable.up * (chancestable.group2 / 100) + 0.5)))
        gui.text(181, 15, helperFunctions.FormatNum(math.floor(chancestable.down * (chancestable.group2 / 100) + 0.5)))
        gui.text(192, 15, helperFunctions.FormatNum(math.floor(chancestable.left * (chancestable.group2 / 100) + 0.5)))
        gui.text(203, 15, helperFunctions.FormatNum(math.floor(chancestable.right * (chancestable.group2 / 100) + 0.5)))
    end
end


---------------------------------------
-- TIME SPECIFIC INFORMATION ----------
---------------------------------------

-- displays save game queued text
function export.DrawSaveGameQueuedInformation()
    gui.text(5, 25, "GAME SAVE QUEUED", "orange")
end

-- displays information if the script is trying to do an ingame save
function export.DrawGameSavingDisplay()
    gui.text(130, 5, "ATTEMPTING TO SAVE GAME", "orange")
    gui.text(135, 15, "> " .. savingAttemptProcessText, "orange")
end

-- displays information if a special rule is active
function export.DrawSpecialRuleDisplay()
    if specialRulesText == "" then return end

    gui.text(5, 150, "> " .. specialRulesText)
end


---------------------------------------
-- GETTERS SETTERS --------------------
---------------------------------------

function export.SetSpecialRulesText(text)
    specialRulesText = text
end

function export.SetGameSavingDisplay(text)
    savingAttemptProcessText = text
end

return export