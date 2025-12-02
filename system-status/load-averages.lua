package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local load_averages = {}

function darwin_load_averages()
    local success, stdout, _ = wezterm.run_child_process({ "/usr/bin/uptime" })
    if success then
        local load1, load5, load15 = stdout:match("load averages:%s+(%d+.%d+)%s+(%d+.%d+)%s+(%d+.%d+)")
        local load = string.format("load: %s, %s, %s", load1, load5, load15)
        return util.pad_string(2, 2, load)
    end
    return nil
end

function linux_load_averages()
    local success, stdout, _ = wezterm.run_child_process({ "/usr/bin/uptime" })
    if success then
        local load1, load5, load15 = stdout:match("load average:%s+(%d+.%d+),%s+(%d+.%d+),%s+(%d+.%d+)")
        local load = string.format("load: %s, %s, %s", load1, load5, load15)
        return util.pad_string(2, 2, load)
    end
    return nil
end

load_averages.darwin_load_averages = darwin_load_averages
load_averages.linux_load_averages = linux_load_averages

return load_averages
