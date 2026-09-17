--Just some weird functions i think i might need, if I actually do i will add them to seprate modules later in development

local experimental_table = {}

function experimental_table.TODO(message)
    assert(false, "TODO:"..message)
end

function experimental_table.format_output_message(level, source, message)
    return("["..level.."][DreamFactory->"..source.."] "..message)
end

return(experimental_table)