local wezterm = require "wezterm"
local conversion = {}

function pad_float(number)
    return string.format("%.2f", number)
end

-- Simple byte converter
-- Usage: foo = util.byte_converter(67108864, "Gi")
--        foo = util.byte_converter(67108864, "M")
function byte_converter(number, unit)
    if unit == nil then
        unit = "auto"
    end
    local suffix = "B"

    if unit == "auto" then
        for _, unit_prefix in ipairs { "", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi", "Yi" } do
            if math.abs(number) < 1024.0 then
                return string.format("%.2f %s%s", number, unit_prefix, suffix)
            end
            number = number / 1024
        end
        return string.format("%.2f Yi%s", number, suffix)
    else
        local divisor = 1000
        if string.len(unit) == 2 and ends_with(unit, "i") then
            divisor = 1024
        end

        prefix_map = {
            K = 1,
            Ki = 1,
            M = 2,
            Mi = 2,
            G = 3,
            Gi = 3,
            T = 4,
            Ti = 4,
            P = 5,
            Pi = 5,
            E = 6,
            Ei = 6,
            Z = 7,
            Zi = 7,
            Y = 8,
            Yi = 8,
        }

        if prefix_map[unit] ~= nil then
            power = prefix_map[unit]
            value = number / (divisor ^ power)
            return string.format("%.2f %s%s", value, unit, suffix)
        else
            return string.format("%s %s", number, suffix)
        end
    end
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
