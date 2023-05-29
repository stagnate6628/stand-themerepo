local header_path = filesystem.resources_dir() .. "ThemeRepo\\Themes\\Paragon\\Header.bmp"
local subheader_path = filesystem.resources_dir() .. "ThemeRepo\\Themes\\Paragon\\Subheader.bmp"
local footer_path = filesystem.resources_dir() .. "ThemeRepo\\Themes\\Paragon\\Footer.bmp"

if not filesystem.exists(header_path) or not filesystem.exists(footer_path) or not
	filesystem.exists(subheader_path) then

	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local subheader = directx.create_texture(subheader_path)
local footer = directx.create_texture(footer_path)

util.create_tick_handler(function()
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(header, 1, (128 / 1080) / 2, 0, 0, x - 2 / 1920, y - 166 / 1080, 0, 1, 1, 1, 1)
        directx.draw_texture(subheader, 1, (38 / 1080) / 2, 0, 0, x - 2 / 1920, (y - 38 / 1080), 0, 1, 1, 1, 1)
        directx.draw_texture(footer, 1, (38 / 1080) / 2, 0, 0, x - 2 / 1920, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)
        directx.draw_rect(x - 2 / 1920, y, 2 / 1920, h, 72 / 255, 148 / 255, 234 / 255, 1)
        directx.draw_rect(x + w, y, 2 / 1920, h, 72 / 255, 148 / 255, 234 / 255, 1)
    end
    return true
end)