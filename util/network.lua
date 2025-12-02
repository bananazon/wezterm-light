local wezterm = require "wezterm"
local network = {}

function darwin_interface_exists(interface)
    local success, stdout, _ = wezterm.run_child_process({ "networksetup", "-listallhardwareports" })
    if success then
        for port, device, _ in stdout:gmatch("Hardware Port: ([^\n]+)\nDevice: ([^\n]+)\nEthernet Address: ([^\n]+)") do
            if device == interface then
                if string.find(port, "Wi-Fi", 0, true) then
                    return "wireless", true
                else
                    return "wired", true
                end
            end
        end
    end
    return nil, false
end

function darwin_is_connected(interface)
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

function darwin_interface_icon(interface)
    type, exists = darwin_interface_exists(interface)
    if exists then
        if type == "wireless" then
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
    return wezterm.nerdfonts.md_network
end

function linux_interface_exists(interface)
    filename = path_join({ "/sys/class/net", interface })
    if is_dir(filename) then
        filename = path_join({ "/sys/class/net", interface, "wireless" })
        if is_dir(filename) then
            return "wireless", true
        else
            return "wired", true
        end
    end
    return nil, false
end

function linux_is_connected(interface)
    local filename = path_join({ "/sys/class/net", interface, "carrier" })
    if file_exists(filename) then
        content = read_file(filename)
        if tonumber(content) == 1 then
            return true
        else
            return false
        end
    end
    return false
end

function linux_interface_icon(interface)
    type, exists = linux_interface_exists(interface)
    if exists then
        if type == "wireless" then
            if linux_is_connected(interface) then
                return wezterm.nerdfonts.md_wifi_strength_4
            else
                return wezterm.nerdfonts.md_wifi_strength_off
            end
        else
            if linux_is_connected(interface) then
                return wezterm.nerdfonts.md_network
            else
                return wezterm.nerdfonts.md_network_off
            end
        end
    end
    return wezterm.nerdfonts.md_network
end

network.darwin_interface_exists = darwin_interface_exists
network.darwin_interface_icon = darwin_interface_icon
network.darwin_is_connected = darwin_is_connected
network.linux_interface_exists = linux_interface_exists
network.linux_interface_icon = linux_interface_icon
network.linux_is_connected = linux_is_connected

return network
