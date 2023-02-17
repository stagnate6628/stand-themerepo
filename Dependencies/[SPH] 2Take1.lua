local footer_path = filesystem.resources_dir() .. 'ProfileHelper\\2Take1\\Footer.bmp'

if not filesystem.is_regular_file(footer_path) then
		util.toast('[SPH] Could not find footer, you may need to manually download this file.')
    return
end

local footer = directx.create_texture(filesystem.resources_dir() .. 'ProfileHelper\\2Take1\\Footer.bmp')

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(footer, 1, (31 / 1080) / 2, 0, 0, x - 0.01 / 1920, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)
    end
    util.yield()
end

util.keep_running()
