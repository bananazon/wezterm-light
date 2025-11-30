package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local memory_usage = {}

function darwin_memory_usage(config)
    local pagesize = nil
    local total = nil
    local success, stdout, stderr = wezterm.run_child_process({ "sysctl", "-n", "hw.pagesize" })
    if success then
        pagesize = stdout
    end

    success, stdout, stderr = wezterm.run_child_process({ "sysctl", "-n", "hw.memsize" })
    if success then
        total = stdout
    end

    if pagesize ~= nil and total ~= nil then
        -- https://github.com/giampaolo/psutil/blob/master/psutil/_psosx.py#L113-L126
        success, stdout, stderr = wezterm.run_child_process({ "vm_stat" })
        if success then
            local bytes_total       = total
            local bytes_free        = stdout:match("Pages free:%s+(%d+)") * pagesize
            local bytes_active      = stdout:match("Pages active:%s+(%d+)") * pagesize
            local bytes_inactive    = stdout:match("Pages inactive:%s+(%d+)") * pagesize
            local bytes_wired       = stdout:match("Pages wired down:%s+(%d+)") * pagesize
            local bytes_speculative = stdout:match("Pages speculative:%s+(%d+)") * pagesize
            local bytes_used        = bytes_active + bytes_wired
            local bytes_available   = bytes_inactive + bytes_free

            local memory_unit       = config["status_bar"]["system_status"]["memory_unit"]
            local usage             = string.format("%s %s / %s", wezterm.nerdfonts.md_memory,
                util.byte_converter(bytes_used, memory_unit), util.byte_converter(bytes_total, memory_unit))
            return util.pad_string(2, 2, usage)
        end
    end
    return nil
end

function linux_memory_usage(config)
    local success, stdout, stderr = wezterm.run_child_process({ "free", "-b", "-w" })
    if success then
        local bytes_total, bytes_used, bytes_free, bytes_shared, bytes_buffers, bytes_cache, bytes_available = stdout
            :match("Mem:%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        local memory_unit = config["status_bar"]["system_status"]["memory_unit"]
        local usage = string.format("%s %s / %s", wezterm.nerdfonts.md_memory,
            util.byte_converter(bytes_used, memory_unit), util.byte_converter(bytes_total, memory_unit))
        return util.pad_string(2, 2, usage)
    end
    return nil
end

memory_usage.darwin_memory_usage = darwin_memory_usage
memory_usage.linux_memory_usage = linux_memory_usage

return memory_usage
