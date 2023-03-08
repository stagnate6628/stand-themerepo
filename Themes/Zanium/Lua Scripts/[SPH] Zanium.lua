require('ProfileHelperLib')

local background_path = filesystem.resources_dir() .. "ProfileHelper\\Themes\\Zanium\\Background.png"
local logo_path = filesystem.resources_dir() .. "ProfileHelper\\Themes\\Zanium\\Logo.png"

if not io.exists(background_path) then
    util.toast("[SPH] Background not found, attempting download.")
    lib:download_file("Themes/Zanium/Background.png", {background_path})

end

if not io.exists(logo_path) then
    util.toast("[SPH] Logo not found, attempting download.")
    lib:download_file("Themes/Zanium/Logo.png", {logo_path})
end

local logo = directx.create_texture(logo_path)
local background = directx.create_texture(background_path)

while true do
    if menu.command_box_is_open() then
        local x, y, w, h = menu.command_box_get_dimensions()
        directx.draw_line(0.358, 0.0936, 0.6428, 0.0936, 1, 0, 0, 1)
        directx.draw_rect(0.358, 0.094, 0.2848, h + 0.005, 0.0, 0.003, 0.015, 0.8)
    end

    if menu.is_open() then
        local x, y = menu.get_main_view_position_and_size()
        directx.draw_texture(background, 0.16, 0.16, 0.0, 0.0, x - 0.1, y - 0.1, 0.0, 1, 1, 1, 1)
        directx.draw_texture(logo, 0.2, 0.2, 0.0, 0.0, x - 0.119, y - 0.144, 0.0, 1, 1, 1, 1)
        directx.draw_text(x + 0.03, y - 0.066, "STAND TRAINER", ALIGN_TOP_LEFT, 0.9, 1, 1, 1, 1, false)
    end

    util.yield()
end
