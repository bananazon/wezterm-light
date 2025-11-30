local wezterm = require "wezterm"
local conversion = {}

-- Simple byte converter
-- Usage: foo = util.byte_converter(67108864, "Gi")
--        foo = util.byte_converter(67108864, "M")
function byte_converter(bytes, unit)
    local divisor = 0
    local multiple = 0
    local suffix = "B"
    local prefix = unit:sub(1, 1)
    if unit:find("i" .. "$") then
        divisor = 1024
    else
        divisor = 1000
    end

    if prefix == "K" then
        multiple = 1
    elseif prefix == "M" then
        multiple = 2
    elseif prefix == "G" then
        multiple = 3
    elseif prefix == "T" then
        multiple = 4
    elseif prefix == "P" then
        multiple = 5
    elseif prefix == "E" then
        multiple = 6
    else
        return string.format("%.2f %s", bytes, suffix)
    end

    return string.format("%.2f %s%s", bytes / divisor ^ multiple, unit, suffix)
end

function duration(delta)
    delta = math.floor(delta)
    local days = math.floor(delta / 86400)
    local hours = math.floor(((delta - (days * 86400)) / 3600))
    local minutes = math.floor(((delta - days * 86400 - hours * 3600) / 60))
    local seconds = math.floor((delta - (days * 86400) - (hours * 3600) - (minutes * 60)))

    return days, hours, minutes, seconds
end

function process_bytes(num)
    local suffix = "B"
    for _, unit in ipairs({ "", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi" }) do
        if math.abs(num) < 1024.0 then
            return string.format("%.2f %s%s/s", num, unit, suffix)
        end
        num = num / 1024
    end
    return string.format("%.1f %s%s", num, "Yi", suffix)
end

conversion.byte_converter = byte_converter
conversion.duration = duration
conversion.process_bytes = process_bytes

return conversion
