local folderOfThisFile = (...):match("(.-)[^%.]+$")
local util = {}

function has_value(array, value)
    for _, element in ipairs(array) do
        if element == value then
            return true
        end
    end
    return false
end

util.has_value = has_value

local conversion = require(folderOfThisFile .. "conversion")
util.byte_converter = conversion.byte_converter
util.process_bytes = conversion.process_bytes

local filesystem = require(folderOfThisFile .. "filesystem")
util.basename = filesystem.basename
util.dirname = filesystem.dirname
util.file_exists = filesystem.file_exists
util.get_cwd = filesystem.get_cwd
util.is_dir = filesystem.is_dir
util.path_join = filesystem.path_join

local json = require(folderOfThisFile .. "json")
util.json_parse_file = json.json_parse_file
util.json_parse_string = json.json_parse_string

local network = require(folderOfThisFile .. "network")
util.darwin_interface_exists = network.darwin_interface_exists
util.darwin_is_connected = network.darwin_is_connected
util.get_interface_icon = network.get_interface_icon
util.linux_interface_exists = network.linux_interface_exists
util.linux_is_connected = network.linux_is_connected
util.network_data_darwin = network.network_data_darwin
util.network_data_linux = network.network_data_linux

local strings = require(folderOfThisFile .. "strings")
util.get_plural = strings.get_plural
util.pad_string = strings.pad_string
util.split_lines = strings.split_lines
util.split_words = strings.split_words
util.string_split = strings.string_split

return util
