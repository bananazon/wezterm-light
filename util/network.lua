local wezterm = require "wezterm"
local network = {}

local function network_data_darwin(interface)
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

local function network_data_linux(interface)
    local success, stdout, stderr = wezterm.run_child_process({ "cat", "/proc/net/dev" })
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

local function darwin_is_connected(interface)
    local success, stdout, _ = wezterm.run_child_process({ "ifconfig", interface })
    if success then
        status = stdout:match("status: ([^\n]+)")
        if status then
            if status == "active" then
                return true
            else
                return false
            end
        end
    else
        return true
    end
    return true
end

local function darwin_get_icon(interface)
    local success, stdout, _ = wezterm.run_child_process({ "networksetup", "-listallhardwareports" })
    if success then
        for port, device, address in stdout:gmatch("Hardware Port: ([^\n]+)\nDevice: ([^\n]+)\nEthernet Address: ([^\n]+)") do
            if device == interface then
                if string.find(port, "Wi-Fi", 0, true) then
                    if darwin_is_connected(interface) then
                        return wezterm.nerdfonts.md_wifi_strength_4
                    else
                        return wezterm.nerdfonts.md_wifi_strength_off
                    end
                else
                    if darwin_is_connected(interface) then
                        return wezterm.nerdfonts.md_network
                    else
                        return wezterm.nerdfonts.md_network_off
                    end
                end
            end
        end
    end
    return wezterm.nerdfonts.md_network
end

local function linux_is_connected(interface)
    local filename = path_join({ "/sys/class/net", interface, "carrier" })
    if file_exists(filename) then
        local filehandle = io.open(filename, "r")
    end
    return wezterm.nerdfonts.md_network
end

local function linux_interface_exists(interface)
    filename = path_join({ "/sys/class/net", interface })
    if is_dir(filename) then
        return true
    end
    return false
end

local function linux_get_icon(interface)
    if not linux_interface_exists(interface) then
        return wezterm.nerdfonts.md_alert
    end
end

local function get_interface_type(config, interface)
    if config.os_name == "darwin" then
        return darwin_get_icon(interface)
    elseif config.os_name == "linux" then
        return linux_get_icon(interface)
    end
end

network.get_interface_type = get_interface_type
network.network_data_darwin = network_data_darwin
network.network_data_linux = network_data_linux

return network
