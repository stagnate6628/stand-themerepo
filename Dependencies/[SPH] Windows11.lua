local white<const> = {
    ["r"] = 1.0,
    ["g"] = 1.0,
    ["b"] = 1.0,
    ["a"] = 1.0
}
local line_colour<const> = {
    ["r"] = 0.247,
    ["g"] = 0.282,
    ["b"] = 0.8,
    ["a"] = 1.0
}

local background_path = filesystem.resources_dir() .. "\\ProfileHelper\\Windows11\\Background.png"
local profile_path = filesystem.resources_dir() .. "\\ProfileHelper\\Windows11\\Profile.png"

if not filesystem.is_regular_file(background_path) then
    util.toast("[SPH] Could not find background, you may need to manually download this file.")
    should_exit = true
end

if not filesystem.is_regular_file(profile_path) then
    local downloading = true
    -- this is pretty bad
    async_http.init("raw.githubusercontent.com", "/stagnate6628/stand-profile-helper/main/Themes/Windows11/Profile.png",
        function(body, _, status_code)
            local file = assert(io.open(profile_path, "wb"))
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
end

if should_exit then
    util.stop_script()
end

local profile = directx.create_texture(profile_path)
local background = directx.create_texture(background_path)

while true do
    local x, y, width, menu_height = menu.get_main_view_position_and_size()
    local cmd_x, cmd_y, cmd_width, cmd_height = menu.command_box_get_dimensions()

    if menu.command_box_is_open() then
        directx.draw_rect(0.357, 0.09, 0.0015, cmd_height + 0.007, line_colour)
        directx.draw_rect(0.358, 0.09, 0.2848, cmd_height + 0.007, white)
    end

    if menu.is_open() then
        directx.draw_texture(profile, 0.01, 0.01, 0.0, 0.0, x - 0.07, y - 0.078, 0.0, white)
        directx.draw_texture(background, 0.17, 0.17, 0.0, 0.0, x - 0.075, y - 0.105, 0.0, {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        })

        directx.draw_rect(x - 0.065, y - 0.0036, 0.318, 0.001, line_colour)

		-- this would show the players name but i dont want to use natives
        -- directx.draw_text(x - 0.048, y - 0.075, "some name goes here", ALIGN_TOP_LEFT, 0.9, {
        --     ["r"] = 0.0,
        --     ["g"] = 0.0,
        --     ["b"] = 0.0,
        --     ["a"] = 1.0
        -- }, false)
        directx.draw_text(x - 0.06, y - 0.095, "Stand", ALIGN_TOP_LEFT, 0.5, {
            ["r"] = 0.5,
            ["g"] = 0.5,
            ["b"] = 0.5,
            ["a"] = 1.0
        }, false)
    end

    util.yield()
end