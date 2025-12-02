package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local disk_usage = {}

function darwin_disk_usage(disk_list)
    local disk_usage_data = {}
    if disk_list ~= nil then
        if #disk_list > 0 then
            for _, disk_item in ipairs(disk_list) do
                local success, stdout, _ = wezterm.run_child_process({ "/bin/df", "-k", disk_item.mountpoint })
                if success then
                    local df_data = util.split_words(util.split_lines(stdout)[2])
                    local disk_total = df_data[2] * 1024
                    local disk_available = df_data[4] * 1024
                    local disk_used = disk_total - disk_available
                    local mountpoint = df_data[9]
                    local usage = string.format("%s %s %s / %s", wezterm.nerdfonts.md_harddisk, mountpoint,
                        util.byte_converter(disk_used, disk_item.unit),
                        util.byte_converter(disk_total, disk_item.unit))
                    table.insert(disk_usage_data, util.pad_string(2, 2, usage))
                end
            end
        end
        return disk_usage_data
    end
    return nil
end

function linux_disk_list_jc(disk_list)
    local disk_usage_data = {}
    for _, disk_item in ipairs(disk_list) do
        local success, stdout, _ = wezterm.run_child_process({ "jc", "--pretty", "df", disk_item.mountpoint })
        if success then
            dfout = json_parse_string(stdout)
            if dfout ~= nil and #dfout == 1 then
                disk_total = dfout[1]["1k_blocks"] * 1024
                disk_used = dfout[1].used * 1024
                local usage = string.format("%s %s %s / %s", wezterm.nerdfonts.md_harddisk, disk_item.mountpoint,
                    util.byte_converter(disk_used, "auto"),
                    util.byte_converter(disk_total, "auto"))
                table.insert(disk_usage_data, util.pad_string(2, 2, usage))
            end
        end
    end
    return disk_usage_data
end

function linux_disk_usage_no_jc(disk_list)
    local disk_usage_data = {}
    for _, disk_item in ipairs(disk_list) do
        local success, stdout, stderr = wezterm.run_child_process({ "/bin/df", "-k", disk_item.mountpoint })
        if success then
            local df_data = util.split_words(util.split_lines(stdout)[2])
            local disk_total = df_data[2] * 1024
            local disk_available = df_data[4] * 1024
            local disk_used = df_data[3] * 1024
            local mountpoint = df_data[6]
            local usage = string.format("%s %s %s / %s", wezterm.nerdfonts.md_harddisk, mountpoint,
                util.byte_converter(disk_used, disk_item.unit),
                util.byte_converter(disk_total, disk_item.unit))
            table.insert(disk_usage_data, util.pad_string(2, 2, usage))
        end
    end
    return disk_usage_data
end

function linux_disk_usage(disk_list)
    if disk_list ~= nil then
        if #disk_list > 0 then
            if which("jc") then
                return linux_disk_list_jc(disk_list)
            else
                return linux_disk_usage_no_jc(disk_list)
            end
        end
    end
    return nil
end

disk_usage.darwin_disk_usage = darwin_disk_usage
disk_usage.linux_disk_usage = linux_disk_usage

return disk_usage
