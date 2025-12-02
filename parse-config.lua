local wezterm = require "wezterm"
local util = require "util.util"

local config_parser = {}

-- Recursive function to convert table into "namedtuple-like" table
function make_namedtuple(t)
    if type(t) ~= "table" then return t end
    local nt = {}
    for k, v in pairs(t) do
        nt[k] = make_namedtuple(v)
    end
    return nt
end

function config_parser.get_config()
    local config = {
        display = {
            tab_bar_font = {
                family  = "JetBrains Mono",
                size    = 12,
                stretch = "Normal",
                weight  = "Regular",
            },
            terminal_font = {
                family  = "JetBrains Mono",
                size    = 14,
                stretch = "Normal",
                weight  = "Regular",
            },
            initial_cols = 80,
            initial_rows = 25,
            color_scheme = {
                enable_gradient = false,
                randomize_color_scheme = false,
                scheme_name = "Novel",
            },
            window_background_opacity = 1,
            window_padding = {
                left   = 5,
                right  = 5,
                top    = 5,
                bottom = 5,
            }
        },
        environment = {
            audible_bell     = "Disabled",
            scrollback_lines = 20000,
            term             = "xterm-256color",
        },
        status_bar = {
            update_interval = 3,
            clock = {
                enabled = true,
                format = "%a %b %-d %H:%M",
            },
            system_status = {
                disk_list = { { mountpoint = "/", unit = "auto" } },
                enabled = true,
                memory_unit = "auto",
                network_interface_list = {},
                toggles = {
                    show_battery_status = true,
                    show_clock = true,
                    show_cpu_usage = true,
                    show_disk_usage = true,
                    show_memory_usage = true,
                    show_network_throughput = true,
                }
            }
        },
        tabs = {
            title_is_cwd = true,
        },
    }

    -- OS-specific defaults
    if wezterm.target_triple:find("apple") then
        config.keymod = "SUPER"
        config.os_name = "darwin"
        config.environment.window_decorations = "RESIZE"
    elseif wezterm.target_triple:find("linux") then
        config.keymod = "SHIFT|CTRL"
        config.os_name = "linux"
        config.environment.window_decorations = "TITLE | RESIZE"
    end

    -- Apply overrides if present
    if util.file_exists(util.path_join({ wezterm.config_dir, "overrides.lua" })) then
        local overrides = require "overrides"
        config = overrides.override_config(config)
    end

    -- Convert to "namedtuple-like" table
    return make_namedtuple(config)
end

return config_parser
