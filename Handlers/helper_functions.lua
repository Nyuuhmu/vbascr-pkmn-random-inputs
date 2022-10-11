---@diagnostic disable: undefined-global
local export = {}


---------------------------------------
-- HELPER FUNCTIONS -------------------
---------------------------------------

-- converts a decimal (string) into a hex
function export.ToHex(str)
    return string.format("%x", tostring(str))
end

-- formats numbers to have leading 0's
function export.FormatNum(num)
    if num < 10 then return (0 .. num) else return num end
end

return export