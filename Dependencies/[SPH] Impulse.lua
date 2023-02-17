local header_path = filesystem.resources_dir() .. 'ProfileHelper\\Impulse\\Header1.bmp'
local footer_path = filesystem.resources_dir() .. 'ProfileHelper\\Impulse\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ProfileHelper\\Impulse\\Subheader.bmp'

if not filesystem.is_regular_file(footer_path) then
    util.toast('[SPH] Could not find footer, you may need to manually download this file.')
    should_exit = true
end

if not filesystem.is_regular_file(header_path) then
    util.toast('[SPH] Could not find header, you may need to manually download this file.')
    should_exit = true
end

if not filesystem.is_regular_file(subheader_path) then
    util.toast('[SPH] Could not find subheader, you may need to manually download this file.')
    should_exit = true
end

if should_exit then
    util.stop_script()
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)

util.create_tick_handler(function()
    if not menu.is_open() then
        return false
    end

    for i = 1, 50 do
        util.yield(50)
        header = directx.create_texture(filesystem.resources_dir() .. 'ProfileHelper\\Impulse\\Header' .. i ..
                                            '.bmp')
        util.yield()
    end

    util.yield(1000)
end)

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(header, 1, (w / 1080) + 0.05115, 0, 0, x, (y - (146) / 1080), 0, 1, 1, 1, 1)
        directx.draw_texture(subheader, 1, (w / 1080) + 0.016, 0, 0, x, (y - 35 / 1080), 0, 1, 1, 1, 1)
        directx.draw_texture(footer, 1, (w / 1080) + 0.0169, 0, 0, x, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)

    end
    util.yield()
end

util.keep_running()