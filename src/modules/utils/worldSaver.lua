local EXPERIMENTAL = require("src.modules.experimental.experimental")

local writer = {}
local saver  = {}

local OPCODE_BLOCK       = 0x01
local OPCODE_REPEAT      = 0x02
local OPCODE_SKIP        = 0x03
local OPCODE_BLOCK_STATE = 0x04

local MAX_U16 = 0xFFFF

local SAVER_VERSION_MAJOR = 0
local SAVER_VERSION_MINOR = 1
local SAVER_VERSION_PATCH = 0

saver.__version = "0.1.0"




function writer.append_byte(buffer, value)
    assert(
        value >= 0 and value <= 0xFF,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_byte",
            "Wanted to append value '"..tostring(value).."' but it is out of range."
        )
    )

    buffer[#buffer + 1] = value
end

function writer.add_separator(buffer)
    writer.append_byte(buffer, 0)
end

function writer.append_string(buffer, value)
    for index = 1, #value do
        writer.append_byte(buffer, string.byte(value, index))
    end
end




function writer.append_u8(buffer, value)
    assert(
        value >= 0 and value <= 0xFF,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_u8",
            "u8 out of range: "..tostring(value)
        )
    )

    buffer[#buffer + 1] = value
end

function writer.append_u16(buffer, value)
    assert(
        value >= 0 and value <= 0xFFFF,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_u16",
            "u16 out of range: "..tostring(value)
        )
    )

    buffer[#buffer + 1] = value % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x100) % 0x100
end

function writer.append_u32(buffer, value)
    assert(
        value >= 0 and value <= 0xFFFFFFFF,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_u32",
            "u32 out of range: "..tostring(value)
        )
    )

    buffer[#buffer + 1] = value % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x100) % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x10000) % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x1000000) % 0x100
end


--==================================================
-- Signed Integers
--==================================================

function writer.append_i8(buffer, value)
    assert(
        value >= -128 and value <= 127,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_i8",
            "i8 out of range: "..tostring(value)
        )
    )

    if value < 0 then
        value = value + 0x100
    end

    writer.append_u8(buffer, value)
end

function writer.append_i16(buffer, value)
    assert(
        value >= -32768 and value <= 32767,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_i16",
            "i16 out of range: "..tostring(value)
        )
    )

    if value < 0 then
        value = value + 0x10000
    end

    writer.append_u16(buffer, value)
end

function writer.append_i32(buffer, value)
    assert(
        value >= -2147483648 and value <= 2147483647,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->append_i32",
            "i32 out of range: "..tostring(value)
        )
    )

    if value < 0 then
        value = value + 0x100000000
    end

    writer.append_u32(buffer, value)
end



-- Used to make sure the file is actually one of our world files.
function saver.add_magic_number(buffer)
    writer.append_string(buffer, "DREAM")
end

function saver.add_header(buffer, major, minor, patch)
    --Game version--
    writer.append_u8(buffer, major)
    writer.append_u8(buffer, minor)
    writer.append_u8(buffer, patch)
    writer.add_separator(buffer)

    --Saver version--
    writer.append_u8(buffer, SAVER_VERSION_MAJOR)
    writer.append_u8(buffer, SAVER_VERSION_MINOR)
    writer.append_u8(buffer, SAVER_VERSION_PATCH)
    writer.add_separator(buffer)

    --Saver method--
    writer.append_string(buffer, "bytes")
    writer.add_separator(buffer)

    --Saver style--
    writer.append_string(buffer, "repeat_skip")
    writer.add_separator(buffer)
end



--[[
    BLOCK

    Writes a single block to the current world position.

    Format:
        [0x01][u16 block ID][u8 facing]

    Example:
        BLOCK Stone

    After loading the block, the world cursor advances by 1.
]]--
function saver.add_block(buffer, block)
    writer.append_u8(buffer, OPCODE_BLOCK)

    -- Block ID --
    writer.append_u16(buffer, block:get_id())

    -- Facing:
    -- 1 = north
    -- 2 = west
    -- etc.
    writer.append_u8(buffer, block:get_facing())
end


--[[
    REPEAT

    Repeats the previously written block N additional times.

    Example world:

        Stone
        Stone
        Stone
        Stone

    Becomes:

        BLOCK Stone
        REPEAT 3

    The original BLOCK is NOT included in the repeat count.

    Large repeats are automatically split into multiple u16 commands.

    Example:

        REPEAT 100000

    Becomes approximately:

        REPEAT 65535
        REPEAT 34465
]]--
function saver.add_repeat(buffer, howMany)
    assert(
        howMany >= 0,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->add_repeat",
            "Repeat amount cannot be negative: "..tostring(howMany)
        )
    )

    while howMany > 0 do
        local repeatAmount = math.min(howMany, MAX_U16)

        writer.append_u8(buffer, OPCODE_REPEAT)
        writer.append_u16(buffer, repeatAmount)

        howMany = howMany - repeatAmount
    end
end


--[[
    SKIP

    Advances the world cursor without writing a block.

    Skipped positions are assumed to be AIR by the loader.

    Example world:

        Stone
        Air
        Air
        Air
        Dirt

    Becomes:

        BLOCK Stone
        SKIP 3
        BLOCK Dirt

    Large skips are automatically split into multiple u16 commands.
]]--
function saver.add_skip(buffer, howMany)
    assert(
        howMany >= 0,
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->add_skip",
            "Skip amount cannot be negative: "..tostring(howMany)
        )
    )

    while howMany > 0 do
        local skipAmount = math.min(howMany, MAX_U16)

        writer.append_u8(buffer, OPCODE_SKIP)
        writer.append_u16(buffer, skipAmount)

        howMany = howMany - skipAmount
    end
end

--[[
    Reserved for blocks which eventually need additional persistent data.

    Examples:
        growth state
        damage
        custom orientation
        special flags

    Machines should probably NOT use this system because machines will
    eventually have their own instance/object serialization section.
]]--
function saver.add_block_state(buffer, block)
    if not block.save_state then
        return
    end

    writer.append_u8(buffer, OPCODE_BLOCK_STATE)
    block:save_state(writer, buffer)
end

function saver.clear_buffer(buffer)
    for i = #buffer, 1, -1 do
        buffer[i] = nil
    end
end

function saver.write_file(path, buffer)
    local file = assert(
        io.open(path, "wb"),
        EXPERIMENTAL.format_output_message(
            "ERROR",
            "worldSaver->write_file",
            "Failed to open save file: "..path
        )
    )

    for _, byte in ipairs(buffer) do
        file:write(string.char(byte))
    end

    file:close()
end


return(saver)