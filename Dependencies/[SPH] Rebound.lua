local header_path = filesystem.resources_dir() .. 'stand-profile-helper\\Rebound\\Header.bmp'
local subheader_path = filesystem.resources_dir() .. 'stand-profile-helper\\Rebound\\Subheader.bmp'
local footer_path = filesystem.resources_dir() .. 'stand-profile-helper\\Rebound\\Footer.bmp'

if not filesystem.is_regular_file(header_path) then
    util.toast('[SPH] Could not find header, you may need to manually download this file.')
    should_exit = true
end

if not filesystem.is_regular_file(footer_path) then
    util.toast('[SPH] Could not find footer, you may need to manually download this file.')
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

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(header, 1, w / 1080 + 0.0498 + (-28 / 10000), 0, 0, x, y - (145 + -8) / 1080, 0, 1, 1, 1, 1)
        directx.draw_texture(subheader, 1, w / 1080 + 0.01694 + (-10 / 10000) + (4 / 100000), 0, 0, x,
            y - (37 + -2) / 1080, 0, 1, 1, 1, 1)
        directx.draw_texture(footer, 1, w / 1080 + 0.01694 + (-10 / 10000) + (4 / 100000), 0, 0, x, y + h - 1 / 1080, 0,
            1, 1, 1, 1)
    end
    util.yield()
end

util.keep_running()