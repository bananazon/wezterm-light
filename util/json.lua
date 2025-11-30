local wezterm = require "wezterm"
local json = {}

local function json_parse_string(input)
    local json_data = wezterm.json_parse(input)
    return json_data
end

local function json_parse_file(filename)
    if file_exists(filename) then
        local filehandle = io.open(filename, "r")
        local json_string = ""
        if filehandle ~= nil then
            json_string = filehandle:read("*a")
            filehandle:close()
        end
        local json_data = wezterm.json_parse(json_string)
        return json_data
    else
        return nil
    end
end

json.json_parse_file = json_parse_file
json.json_parse_string = json_parse_string

return json
