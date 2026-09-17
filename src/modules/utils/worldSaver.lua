local EXPERIMENTAL = require("src.modules.experimental.experimental")

local writer = {}
local saver  = {}
saver.__version = "0.0.1"

function writer.append_byte(buffer, value)
    assert(value >= 0 and value <= 255, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "Wanted to append value '"..value.."' but it is out of range."))
    buffer[#buffer + 1] = value
end

function writer.add_separator(buffer)
    buffer[#buffer + 1] = 0
end

function writer.append_string(buffer, value)
    for index = 1, #value do
        writer.append_byte(buffer, string.byte(value, index))
    end
end

function writer.append_u8(buffer, value)
    assert(value >= 0 and value <= 0xFF, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "u8 out of range."))

    buffer[#buffer + 1] = value
end

function writer.append_u16(buffer, value)
    assert(value >= 0 and value <= 0xFFFF, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "u16 out of range."))

    buffer[#buffer + 1] = value % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x100) % 0x100
end

function writer.append_u32(buffer, value)
    assert(value >= 0 and value <= 0xFFFFFFFF, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "u32 out of range."))

    buffer[#buffer + 1] = value % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x100) % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x10000) % 0x100
    buffer[#buffer + 1] = math.floor(value / 0x1000000) % 0x100
end

function writer.append_i8(buffer, value)
    assert(value >= -128 and value <= 127, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "i8 out of range."))

    if value < 0 then
        value = value + 0x100
    end

    writer.append_u8(buffer, value)
end

function writer.append_i16(buffer, value)
    assert(value >= -32768 and value <= 32767, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "i16 out of range."))

    if value < 0 then
        value = value + 0x10000
    end

    writer.append_u16(buffer, value)
end

function writer.append_i32(buffer, value)
    assert(value >= -2147483648 and value <= 2147483647, EXPERIMENTAL.format_output_message("ERROR", "worldSaver->append_bytes", "i32 out of range."))

    if value < 0 then
        value = value + 0x100000000
    end

    writer.append_u32(buffer, value)
end

--Just so we identify it's actually our file, so we don't get weird files added by the user that we fail parsing and error out
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
    writer.append_u8(buffer, 1)
    writer.append_u8(buffer, 0)
    writer.append_u8(buffer, 0)
    writer.add_separator(buffer)
    --Saver method--
    writer.append_string(buffer, "bytes")
    writer.add_separator(buffer)
    --Saver style--
    writer.append_string(buffer, "jumping")
    writer.add_separator(buffer)
end

function saver.add_block(buffer, block)
    --block identifier--
    writer.append_u8(buffer, 0x00)
    --ID--
    writer.append_u16(buffer, block.id)
    --facing (eg. 1 = north, 2 = west, ect.)--
    writer.append_u8(buffer, block.facing)
end

--[[
Basically an idea of jumping in saving, we will have for example:

    (0x00 is a identifier that it is a block) 
    
    0x00[ID: 2, Facing: 1(north)] 

and there will be for example 5 more of the same blocks facing the same way with the same ID
so we will add the block.

    0x00[ID: 2, Facing: 1]

and now we add the jump which has as an identifier 0x01

    0x00[ID: 2, Facing: 1] 0x01[howMany: 5]

the block we saved first is counted as 1 and then 5 additional blocks will be "added", this is to save space if we have an early
build that doesn't have caves for example and ores yet, we will be saving hundreds of the same blocks, so we will just jump over them.
]]--
function saver.add_jump(buffer, howMany)
    --jump identifier--
    writer.append_u8(buffer, 0x01)
    --number of how many skips--
    writer.append_u16(buffer, howMany)
end

--Not implemented yet, halucinated function i think i will need later xD
function saver.add_block_state(buffer, block)
    if block.save_state then
        block:save_state(writer, buffer)
    end
end

function saver.write_file(path, buffer)
    local file = assert(io.open(path, "wb"))

    for _, byte in ipairs(buffer) do
        file:write(string.char(byte))
    end

    file:close()
end

return(saver)