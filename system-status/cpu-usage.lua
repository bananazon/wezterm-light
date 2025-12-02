package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local cpu_usage = {}

function darwin_cpu_usage(config)
    local success, stdout, stderr = wezterm.run_child_process({ "top", "-l", 1 })
    if success then
        local user, sys, idle = stdout:match("CPU usage: (%d+.%d+)%%%s+user,%s+(%d+.%d+)%%%s+sys,%s+(%d+.%d+)%%%s+idle")
        local usage = string.format("%s user %s%%, sys %s%%, idle %s%%", wezterm.nerdfonts.oct_cpu, user, sys, idle)
        return util.pad_string(2, 2, usage)
    end
    return nil
end

function linux_cpu_usage_jc()
    local success, stdout, _ = wezterm.run_child_process({ "jc", "--pretty", "mpstat" })
    if success then
        cpu_data = util.json_parse_string(stdout)
        if cpu_data ~= nil and #cpu_data == 1 then
            local usage = string.format("%s user %s%%, sys %s%%, idle %s%%", wezterm.nerdfonts.oct_cpu,
                cpu_data[1].percent_usr, cpu_data[1].percent_sys, cpu_data[1].percent_idle)
            return util.pad_string(2, 2, usage)
        end
    end
    return nil
end

function linux_cpu_usage_no_jc()
    local success, stdout, _ = wezterm.run_child_process({ "mpstat" })
    if success then
        local user, nice, sys, iowait, irq, soft, steal, guest, gnice, idle = stdout:match(
            "all%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)")
        local usage = string.format("%s user %s%%, sys %s%%, idle %s%%", wezterm.nerdfonts.oct_cpu, user, sys, idle)
        return util.pad_string(2, 2, usage)
    end
    return nil
end

function linux_cpu_usage()
    if util.which("jc") and util.which("mpstat") then
        return linux_cpu_usage_jc()
    else
        return linux_cpu_usage_no_jc()
    end
end

cpu_usage.darwin_cpu_usage = darwin_cpu_usage
cpu_usage.linux_cpu_usage = linux_cpu_usage

return cpu_usage
