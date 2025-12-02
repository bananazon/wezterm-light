local wezterm = require "wezterm"
local filesystem = {}

function basename(path)
    return string.gsub(path, "(.*/)(.*)", "%2")
end

function dirname(path)
    return string.gsub(path, "(.*/)(.*)", "%1")
end

function path_join(path_bits)
    return table.concat(path_bits, "/")
end

function get_cwd(pane)
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = cwd_uri.file_path
        cwd = string.gsub(cwd, wezterm.home_dir, "~")
        return cwd
    end
    return nil
end

function which(name)
    local success, stdout, _ = wezterm.run_child_process({ "which", name })
    if success then
        return true
    end
    return false
end

function file_exists(filename)
    local f = io.open(filename, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function is_dir(path)
    local ok, _ = file_exists(path)
    if not ok then
        return false
    end

    local command = "cd " .. path
    local handle = io.popen(command)
    if handle == nil then
        return false
    end
    local result = handle:close()
    return result == true
end

function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

filesystem.basename = basename
filesystem.dirname = dirname
filesystem.file_exists = file_exists
filesystem.get_cwd = get_cwd
filesystem.is_dir = is_dir
filesystem.path_join = path_join
filesystem.which = which

return filesystem
