local wezterm = require "wezterm"
local battery_status = require "battery-status"
local system_status = require "system-status.system-status"

local config_parser = require "parse-config"
local util = require "util.util"
local status_bar = {}
local config = config_parser.get_config()

local system_status_config = config.status_bar.system_status
local disk_usage_index = 1
local network_throughput_index = 1

function status_bar.update_status_bar(cwd)
    local cells = {}

    -- system status
    if system_status_config.enabled then
        -- network throughput
        if system_status_config.toggles.show_network_throughput then
            local network_throughput = system_status.get_network_throughput(config)
            if network_throughput ~= nil then
                if network_throughput_index <= #network_throughput then
                    table.insert(cells, network_throughput[network_throughput_index])
                    network_throughput_index = network_throughput_index + 1
                    if network_throughput_index > #network_throughput then
                        network_throughput_index = 1
                    end
                end
            end
        end

        -- filesystems
        if system_status_config.toggles.show_disk_usage then
            local disk_usage = system_status.get_disk_usage(config)
            if disk_usage ~= nil then
                if disk_usage_index <= #disk_usage then
                    table.insert(cells, disk_usage[disk_usage_index])
                    disk_usage_index = disk_usage_index + 1
                    if disk_usage_index > #disk_usage then
                        disk_usage_index = 1
                    end
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
    if config.status_bar.clock.enabled then
        format = config.status_bar.clock.format
        local date = os.date(config.status_bar.clock.format)
        icon = util.get_clock_icon

        table.insert(cells, util.pad_string(1, 1, util.get_clock_icon() .. " " .. date))
    end

    return cells
end

return status_bar
