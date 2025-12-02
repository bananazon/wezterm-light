package.path = "../util/?.lua;" .. package.path
local wezterm = require "wezterm"
local util = require "util.util"
local network_throughput = {}

function darwin_sample(interface)
    local bytes_recv = nil
    local bytes_sent = nil
    local success, stdout, stderr = wezterm.run_child_process({ "netstat", "-bi", "-I", interface })
    if success then
        local bits = split_words(split_lines(stdout)[2])
        bytes_recv = bits[7]
        bytes_sent = bits[10]
        return bytes_recv, bytes_sent
    end
    return nil, nil
end

function darwin_network_throughput(network_interface_list)
    local network_throughput_data = {}
    if network_interface_list ~= nil then
        if #network_interface_list > 0 then
            for _, interface in ipairs(network_interface_list) do
                local r1, s1 = darwin_sample(interface)
                _, _, _ = wezterm.run_child_process({ "sleep", "1" })
                local r2, s2 = darwin_sample(interface)
                local throughput = string.format("%s %s %s%s %s%s", util.darwin_interface_icon(interface),
                    interface,
                    wezterm.nerdfonts.cod_arrow_small_down,
                    util.process_bytes(r2 - r1), wezterm.nerdfonts.cod_arrow_small_up, util.process_bytes(s2 - s1))
                table.insert(network_throughput_data, util.pad_string(2, 2, throughput))
            end
        end
    end
    return network_throughput_data
end

function linux_sample_jc(interface)
    local success, stdout, _ = wezterm.run_child_process({ "jc", "--pretty", "/proc/net/dev" })
    if success then
        sample = util.json_parse_string(stdout)
        if sample ~= nil then
            for _, item in ipairs(sample) do
                if item.interface == interface then
                    return item.r_bytes, item.t_bytes
                end
            end
        end
    end
    return nil, nil
end

function linux_sample_no_jc(interface)
    local success, stdout, _ = wezterm.run_child_process({ "cat", "/proc/net/dev" })
    if success then
        for _, line in ipairs(split_lines(stdout)) do
            if line:match(string.format("%s:", interface)) then
                local bits = split_words(line)
                return bits[2], bits[10]
            end
        end
    end
    return nil, nil
end

function linux_sample(interface)
    if which("jc") then
        return linux_sample_jc(interface)
    else
        return linux_sample_no_jc(interface)
    end
end

function linux_network_throughput(network_interface_list)
    local network_throughput_data = {}
    if network_interface_list ~= nil then
        if #network_interface_list > 0 then
            for _, interface in ipairs(network_interface_list) do
                local r1, s1 = linux_sample(interface)
                if r1 ~= nil and s1 ~= nil then
                    _, _, _ = wezterm.run_child_process({ "sleep", "1" })
                    local r2, s2 = linux_sample(interface)
                    if r2 ~= nil and s2 ~= nil then
                        local throughput = string.format("%s %s %s%s %s%s", util.linux_interface_icon(interface),
                            interface,
                            wezterm.nerdfonts.cod_arrow_small_down,
                            util.process_bytes(r2 - r1), wezterm.nerdfonts.cod_arrow_small_up,
                            util.process_bytes(s2 - s1))
                        table.insert(network_throughput_data, util.pad_string(2, 2, throughput))
                    end
                end
            end
        end
    end
    return network_throughput_data
end

network_throughput.darwin_network_throughput = darwin_network_throughput
network_throughput.linux_network_throughput = linux_network_throughput

return network_throughput
