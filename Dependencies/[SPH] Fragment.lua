local header_path = filesystem.resources_dir() .. 'stand-profile-helper\\Fragment\\Header.bmp'
local footer_path = filesystem.resources_dir() .. 'stand-profile-helper\\Fragment\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'stand-profile-helper\\Fragment\\Subheader.bmp'

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

xy = 0
menu.slider(menu.my_root(), '.', {}, "", -10000000000000, 10000000000000, 1, 1, function(value)
    xy = value / 10000
end)

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(header, 1, (w / 1080) + 0.03223, 0, 0, x, (y - (128) / 1080), 0, 1, 1, 1, 1)
        directx.draw_texture(subheader, 1, w / 1080 + 0.02714, 0, 0, x, (y - 58 / 1080), 0, 1, 1, 1, 1)
        directx.draw_texture(footer, 1, w / 1080 + 0.02718, 0, 0, x, (y + h - (1 / 1080) + 0.0013), 0, 1, 1, 1, 1)
    end
    util.yield()
end

util.keep_running()