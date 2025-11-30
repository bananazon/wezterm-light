package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local uptime = {}

function darwin_uptime(config)
    local success, stdout, stderr = wezterm.run_child_process({ "sysctl", "-n", "kern.boottime" })
    if success then
        local timestamp = stdout:match("{ sec = %d+, usec = %d+ } (%a+%s+%a+%s+%d+%s+%d+:%d+:%d+%s+%d+)")
        success, stdout, stderr = wezterm.run_child_process({ "/bin/date", "-j", "-f", "%a %b %d %H:%M:%S %Y", timestamp,
            "+%s" })
        if success then
            local delta = util.get_timestamp() - stdout
            local days, hours, minutes, seconds = util.duration(delta)
            local up = { "up" }
            if days > 0 then
                table.insert(up, string.format("%d %s", days, util.get_plural(days, "day")))
            end
            table.insert(up, string.format("%d:%02d", hours, minutes))
            return util.pad_string(2, 2, table.concat(up, " "))
        end
    end
    return nil
end

function linux_uptime(config)
    local success, stdout, _ = wezterm.run_child_process({ "cut", "-f1", "-d.", "/proc/uptime" })
    if success then
        local days, hours, minutes, _ = util.duration(stdout)
        local up = { "up" }
        if days > 0 then
            table.insert(uptime, string.format("%d %s", days, util.get_plural(days, "day")))
        end
        table.insert(uptime, string.format("%d:%02d", hours, minutes))
        return util.pad_string(2, 2, table.concat(uptime, " "))
    end
    return nil
end

uptime.darwin_uptime = darwin_uptime
uptime.linux_uptime = linux_uptime

return uptime
