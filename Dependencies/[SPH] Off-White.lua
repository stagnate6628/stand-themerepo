local header_path = filesystem.resources_dir() .. "ProfileHelper\\Off-White\\Header.bmp"

if not filesystem.is_regular_file(header_path) then
    util.toast('[SPH] Could not find header, you may need to manually download this file.')
    should_exit = true
end

if should_exit then
    util.stop_script()
end

local header = directx.create_texture(header_path)

while true do
    if menu.is_open() then
        directx.draw_texture(header, 0.0375, 0.0375, 0.5, 0.5, 110 / 1920, 0.2491, 0, 1, 1, 1, 1)
    end
    util.yield()
end