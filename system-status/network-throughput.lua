package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local network_throughput = {}

local function darwin_network_throughput(config)
    util.get_interface_type(config, "en0")
    local network_interface_list = config.status_bar.system_status.network_interface_list
    if network_interface_list ~= nil then
        if #network_interface_list > 0 then
            for _, interface in ipairs(network_interface_list) do
                local r1, s1 = util.network_data_darwin(interface)
                _, _, _ = wezterm.run_child_process({ "sleep", "1" })
                local r2, s2 = util.network_data_darwin(interface)
                local throughput = string.format("%s %s %s%s %s%s", util.get_interface_type(config, interface), interface,
                    wezterm.nerdfonts.cod_arrow_small_down,
                    util.process_bytes(r2 - r1), wezterm.nerdfonts.cod_arrow_small_up, util.process_bytes(s2 - s1))
                return util.pad_string(2, 2, throughput)
            end
        end
    end
end

local function linux_network_throughput(config)
    util.get_interface_type(config, "en0")
    local network_interface_list = config["status_bar"]["system_status"]["network_interface_list"]
    if network_interface_list ~= nil then
        if #network_interface_list > 0 then
            for _, interface in ipairs(network_interface_list) do
                local r1, s1 = util.network_data_linux(interface)
                if r1 ~= nil and s1 ~= nil then
                    _, _, _ = wezterm.run_child_process({ "sleep", "1" })
                    local r2, s2 = util.network_data_linux(interface)
                    if r2 ~= nil and s2 ~= nil then
                        local throughput = string.format("%s %s %s%s %s%s", util.get_interface_type(config, interface),
                            interface,
                            wezterm.nerdfonts.cod_arrow_small_down,
                            util.process_bytes(r2 - r1), wezterm.nerdfonts.cod_arrow_small_up,
                            util.process_bytes(s2 - s1))
                        return util.pad_string(2, 2, throughput)
                    end
                end
            end
        end
    end
    return nil
end

network_throughput.darwin_network_throughput = darwin_network_throughput
network_throughput.linux_network_throughput = linux_network_throughput

return network_throughput
