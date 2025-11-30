local wezterm = require "wezterm"
local battery_status = require "battery-status"
local system_status = require "system-status.system-status"

local config_parser = require "parse-config"
local util = require "util.util"
local status_bar = {}
local config = config_parser.get_config()

local system_status_config = config.status_bar.system_status

function status_bar.update_status_bar(cwd)
    local cells = {}

    -- system status
    if system_status_config.enabled then
        -- network throughput
        if system_status_config.toggles.show_network_throughput then
            local network_throughput = system_status.get_network_throughput(config)
            if network_throughput ~= nil then
                table.insert(cells, network_throughput)
            end
        end

        -- filesystems
        if system_status_config.toggles.show_disk_usage then
            local disk_usage = system_status.get_disk_usage(config)
            if disk_usage ~= nil then
                for _, disk_usage_data in ipairs(disk_usage) do
                    table.insert(cells, disk_usage_data)
                end
            end
        end

        -- memory
        if system_status_config.toggles.show_memory_usage then
            local memory_usage = system_status.get_memory_usage(config)
            if memory_usage ~= nil then
                table.insert(cells, memory_usage)
            end
        end

        -- cpu
        if system_status_config.toggles.show_cpu_usage then
            local cpu_usage = system_status.get_cpu_usage(config)
            if cpu_usage ~= nil then
                table.insert(cells, cpu_usage)
            end
        end
    end

    -- battery
    if config.status_bar.system_status.toggles.show_battery_status then
        if #wezterm.battery_info() > 0 then
            for _, b in ipairs(wezterm.battery_info()) do
                local icon, battery_percent = battery_status.get_battery_status(b)
                local bat = icon .. " " .. battery_percent
                table.insert(cells, util.pad_string(1, 1, bat))
            end
        end
    end

    -- clock
    if config.status_bar.system_status.toggles.show_clock then
        local date = wezterm.strftime "%a %b %-d %H:%M"
        table.insert(cells, util.pad_string(2, 2, date))
    end

    return cells
end

return status_bar
