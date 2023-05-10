local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Superior V\\Header.png'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Superior V\\Footer.png'

if not filesystem.exists(header_path) or not filesystem.exists(footer_path) then
	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)

util.create_tick_handler(function()
    if menu.is_open() then
        x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_rect(x, y - (80 / 1080), w, 80 / 1080, {r=3/255,g=4/255,b=3/255,a=235/255})
        directx.draw_texture(header, 1, (81 / 1080) / 2, 0, 0, x, y - 80 / 1080, 0, 1, 1, 1, 1)

        directx.draw_rect(x, y + h - (1 / 1080), w, (5 / 1080), {r=200/255,g=200/255, b=200/255, a=1})
        directx.draw_rect(x, y + h + 02.9 / 1080, w, 23 / 1080, {r=3/255,g=4/255,b=3/255,a=200/255})
        directx.draw_texture(footer, 1, (29.5 / 1080) / 2, 0, 0, x, y + h - (0.8 / 1080), 0, 1, 1, 1, 1)
    end
    return true
end)