---@diagnostic disable: undefined-global
local export = {}

local mem_GameVersionGen1Addr = 0x0134
local mem_GameVersionYellowValue = {80, 79, 75, 69, 77, 79, 78, 32, 89, 69, 76, 76, 79, 87, 0, 128}

local mem_GameVersionGen2Addr = 0x0134
local mem_GameVersionCrystalValue = {80, 77, 95, 67, 82, 89, 83, 84, 65, 76, 0, 66, 89, 84, 69, 192}

local mem_GameVersionGen3Addr = 0x080000A0
local mem_GameVersionRubyValue = {80, 79, 75, 69, 77, 79, 78, 32, 82, 85, 66, 89, 65, 88, 86, 69}
local mem_GameVersionSapphireValue = {80, 79, 75, 69, 77, 79, 78, 32, 83, 65, 80, 80, 65, 88, 80, 69}
local mem_GameVersionEmeraldValue = {80, 79, 75, 69, 77, 79, 78, 32, 69, 77, 69, 82, 66, 80, 69, 69}

local v_Red = 11
local v_Blue = 12
local v_Yellow = 13
local v_Gold = 21
local v_Silver = 22
local v_Crystal = 23
local v_Ruby = 31
local v_Sapphire = 32
local v_Emerald = 33


---------------------------------------
-- HELPER FUNCTIONS -------------------
---------------------------------------

local function DecTableToString(table)
    local result = ""
    for i = 1,16 do result = result .. string.char(table[i]) end

    return result
end


---------------------------------------
-- VERSION ----------------------------
---------------------------------------

-- attempts to find the version by snooping for a defined string within the rom
function export.FindVersion()
    local version = -1

    -- Yellow
    vba.print("Gen1 Check: \"" .. DecTableToString(memory.readbyterange(mem_GameVersionGen1Addr, 16)) .. "\"")
    if table.concat(memory.readbyterange(mem_GameVersionGen1Addr, 16)) == table.concat(mem_GameVersionYellowValue) then version = v_Yellow end

    -- Crystal
    vba.print("Gen2 Check: \"" .. DecTableToString(memory.readbyterange(mem_GameVersionGen2Addr, 16)) .. "\"")
    if table.concat(memory.readbyterange(mem_GameVersionGen2Addr, 16)) == table.concat(mem_GameVersionCrystalValue) then version = v_Crystal end

    -- Gen3
    vba.print("Gen3 Check: \"" .. DecTableToString(memory.readbyterange(mem_GameVersionGen3Addr, 16)) .. "\"")
    --vba.print(memory.readbyterange(mem_GameVersionGen3Addr, 16))

    -- Ruby
    if table.concat(memory.readbyterange(mem_GameVersionGen3Addr, 16)) == table.concat(mem_GameVersionRubyValue) then version = v_Ruby end

    -- Sapphire
    if table.concat(memory.readbyterange(mem_GameVersionGen3Addr, 16)) == table.concat(mem_GameVersionSapphireValue) then version = v_Sapphire end

    -- Emerald
    if table.concat(memory.readbyterange(mem_GameVersionGen3Addr, 16)) == table.concat(mem_GameVersionEmeraldValue) then version = v_Emerald end

    return version
end

-- returns a string representation of the version value
function export.GetVersionName(version)
    if version == v_Yellow then return "Yellow" end
    if version == v_Crystal then return "Crystal" end
    if version == v_Ruby then return "Ruby" end
    if version == v_Sapphire then return "Sapphire" end
    if version == v_Emerald then return "Emerald" end

    if version == 1 then return "Gen1" end
    if version == 2 then return "Gen2" end
    if version == 3 then return "Gen3" end

    return "unknown"
end


---------------------------------------
-- CHARSET ----------------------------
---------------------------------------

-- charset used by gen1
local gen1Charset = {
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'V', 'S', 'L', 'M', ':', 'ぃ', 'ぅ',
    '‘', '’', '“', '”', '・', '⋯', 'ぁ', 'ぇ', 'ぉ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '(', ')', ':', ';', '[', ']',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
    'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'é', '\'d', '\'l', '\'s', '\'t', '\'v',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    '\'', 'PK', 'MN', '-', '\'r', '\'m', '?', '!', '.', 'ァ', 'ゥ', 'ェ', '▷', '▶', '▼', '♂',
    'pk$', '×', '.', '/', ',', '♀', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
}

-- charset used by gen3
local gen3Charset = {
    ' ', 'À', 'Á', 'Â', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', ' ', 'Î', 'Ï', 'Ò', 'Ó', 'Ô',
    'Œ', 'Ù', 'Ú', 'Û', 'Ñ', 'ß', 'à', 'á', ' ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', ' ',
    'î', 'ï', 'ò', 'ó', 'ô', 'œ', 'ù', 'ú', 'û', 'ñ', 'º', 'ª', 'ᵉʳ', '&', '+', ' ',
    ' ', ' ', ' ', ' ', 'Lv', '=', ';', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    '▯', '¿', '¡', 'PK', 'MN', 'PO', 'Ké', 'x', 'x', 'x', 'Í', '%', '(', ')', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'â', ' ', ' ', ' ', ' ', ' ', ' ', 'í',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '⬆', '⬇', '⬅', '➡', '*', '*', '*',
    '*', '*', '*', '*', 'ᵉ', '<', '>', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    'ʳᵉ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '?', '.', '-', '・',
    '...', '“', '”', '‘', '’', '♂', '♀', 'pk$', ',', '×', '/', 'A', 'B', 'C', 'D', 'E',
    'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
    'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '▶',
    ':', 'Ä', 'Ö', 'Ü', 'ä', 'ö', 'ü', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
}

-- returns the a char based on generation and index
function export.GetChar(version, index)
    if version == v_Yellow then return gen1Charset[index] end
    if version == v_Emerald or version == v_Sapphire or version == v_Ruby then return gen3Charset[index] end
end

return export