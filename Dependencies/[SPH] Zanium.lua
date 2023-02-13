local zhead_txt = "STAND TRAINER"
local zposx_txt = 0.03
local zhsize_txt = 0.9
-- Default text head colour
local zheadtxt_colour = {
    ["r"] = 1.0,
    ["g"] = 1.0,
    ["b"] = 1.0,
    ["a"] = 1.0
}
-- Default text head colour
local zbg_colour = {
    ["r"] = 1.0,
    ["g"] = 1.0,
    ["b"] = 1.0,
    ["a"] = 1.0
}
-- Default text head colour
local zlg_colour = {
    ["r"] = 1.0,
    ["g"] = 1.0,
    ["b"] = 1.0,
    ["a"] = 1.0
}
-- Default cmd top colour
local zbcmd_colour = {
    ["r"] = 1.0,
    ["g"] = 0.0,
    ["b"] = 0.0,
    ["a"] = 1.0
}

local background_path = filesystem.resources_dir() .. "\\stand-profile-helper\\Zanium\\Background.png"
local logo_path = filesystem.resources_dir() .. "\\stand-profile-helper\\Zanium\\Logo.png"

if not filesystem.is_regular_file(background_path) then
    util.toast("[SPH] Could not find background, you may need to manually download this file.")
    should_exit = true
end

if not filesystem.is_regular_file(logo_path) then
    local downloading = true
    -- this is pretty bad
    async_http.init("raw.githubusercontent.com", "/stagnate6628/stand-profile-helper/main/Themes/Zanium/Logo.png",
        function(body, _, status_code)
            local file = assert(io.open(logo_path, "wb"))
            file:write(body)
            file:close()
            downloading = false
        end, function()
            downloading = false
        end)
    async_http.dispatch()

    while downloading do
        util.yield()
    end
    should_exit = true
end

if should_exit then
    util.stop_script()
end

local logo = directx.create_texture(logo_path)
local background = directx.create_texture(background_path)

while true do
    local x, y, width, menu_height = menu.get_main_view_position_and_size()
    local cmd_x, cmd_y, cmd_width, cmd_height = menu.command_box_get_dimensions()

    if menu.command_box_is_open() then
        directx.draw_line(0.358, 0.0936, 0.6428, 0.0936, zbcmd_colour)
        directx.draw_rect(0.358, 0.094, 0.2848, cmd_height + 0.005, {
            ["r"] = 0.0,
            ["g"] = 0.003,
            ["b"] = 0.015,
            ["a"] = 0.8
        })
    end

    if menu.is_open() then
        directx.draw_texture(background, 0.16, 0.16, 0.0, 0.0, x - 0.1, y - 0.1, 0.0, zbg_colour)
        directx.draw_texture(logo, 0.2, 0.2, 0.0, 0.0, x - 0.119, y - 0.144, 0.0, zlg_colour)
        directx.draw_text(x + zposx_txt, y - 0.066, zhead_txt, ALIGN_TOP_LEFT, zhsize_txt, zheadtxt_colour, false)
    end

    util.yield()
end