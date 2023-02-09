local footer_path = filesystem.resources_dir() .. 'stand-profile-helper\\Circuit\\Footer.bmp'
-- local subheader_path = filesystem.resources_dir() .. 'stand-profile-helper\\Circuit\\Subheader.bmp'

if not filesystem.is_regular_file(footer_path) then
    util.toast('[SPH] Could not find footer, you may need to manually download this file.')
    return
end

-- if not filesystem.is_regular_file(subheader_path) then
--     util.toast('[SPH] Could not find subheader, you may need to manually download this file.')
--     return
-- end

local footer = directx.create_texture(footer_path)
-- local subheader = directx.create_texture(subheader_path)

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        -- is drawn over by the header
        -- directx.draw_texture(subheader, 1, (33.7 / 1080) / 2, 0, 0, x, (y + h - (1 / 1080) - xy) , 0, 1, 1, 1, 1)
        directx.draw_texture(footer, 1, (34.7 / 1080) / 2, 0, 0, (x + 32) / 1920, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)
    end
    util.yield()
end

util.keep_running()