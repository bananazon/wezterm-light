local wezterm = require "wezterm"
local time = {}

function get_clock_icon()
    hour = os.date("*t").hour
    glyphs = {
        wezterm.nerdfonts.md_clock_time_one_outline,
        wezterm.nerdfonts.md_clock_time_two_outline,
        wezterm.nerdfonts.md_clock_time_three_outline,
        wezterm.nerdfonts.md_clock_time_four_outline,
        wezterm.nerdfonts.md_clock_time_five_outline,
        wezterm.nerdfonts.md_clock_time_six_outline,
        wezterm.nerdfonts.md_clock_time_seven_outline,
        wezterm.nerdfonts.md_clock_time_eight_outline,
        wezterm.nerdfonts.md_clock_time_nine_outline,
        wezterm.nerdfonts.md_clock_time_ten_outline,
        wezterm.nerdfonts.md_clock_time_eleven_outline,
        wezterm.nerdfonts.md_clock_time_twelve_outline,
    }
    if hour == 0 then
        return glyphs[12]
    elseif hour <= 12 then
        return glyphs[hour]
    elseif hour > 12 then
        return glyphs[hour - 12]
    end
end

time.get_clock_icon = get_clock_icon

return time
