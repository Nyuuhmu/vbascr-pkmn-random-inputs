---@diagnostic disable: undefined-global
local export = {}


---------------------------------------
-- SAVE AND LOAD INPUT DATA -----------
---------------------------------------

-- save input count to file
function export.SaveInputs(gameversion, playername, inputs)
    local filename = ("InputCounts\\" .. string.lower(gameversion) .. "_" .. playername .. "_InputCount.txt")

    local file,err = io.open(filename, 'w')
    if file then
        file:write(tostring(inputs))
        file:close()
        vba.print("Updated Saved Inputs! Total Inputs: " .. inputs)
    else vba.print("Failed to update Saved Inputs:", err) end
end

-- load input count from file
function export.LoadInputs(gameversion, playername)
    vba.print("Loading Inputs...")
    local inputs
    local filename = ("InputCounts\\" .. string.lower(gameversion) .. "_" .. playername .. "_InputCount.txt")

    local file,err = io.open(filename, 'r')
    if file then
        inputs = file:read()
        file:close()
    else 
        inputs = 0
        vba.print("error:", err)
    end

    vba.print("Successfully Loaded Inputs! Total Inputs: " .. inputs)
    return inputs
end

return export