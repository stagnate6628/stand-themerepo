local status, err = pcall(require, "downloader")

local header_path = filesystem.resources_dir() .. "ProfileHelper\\Ozark\\Header.bmp"
local subheader_path = filesystem.resources_dir() .. "ProfileHelper\\Ozark\\Subheader.bmp"

if not io.exists(header_path) then
    if not status then
        util.toast("[SPH] Header not found, you may need to manually download this file.")
        should_exit = true
        return
    end

    util.toast("[SPH] Header not found, attempting download. The script will automatically restart when finished.")
    download_file("Themes/Ozark/Header.bmp", {header_path})
    util.toast("[SPH] Restarting")
    util.restart_script()
end

if not io.exists(subheader_path) then
    if not status then
        util.toast("[SPH] Could not find footer, you may need to manually download this file.")
        should_exit = true
        return
    end

    util.toast("[SPH] Footer not found, attempting download. The script will automatically restart when finished.")
    download_file("Themes/Ozark/Subheader.bmp", {subheader_path})
    util.toast("[SPH] Restarting")
    util.restart_script()
end

if should_exit then
    util.stop_script()
end

local header = directx.create_texture(header_path)
local subheader = directx.create_texture(subheader_path)

while true do
    if menu.is_open() then
        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(header, 1, w / 1080 + 0.0498, 0, 0, x, y - 145 / 1080, 0, 1, 1, 1, 1)
        directx.draw_texture(subheader, 1, w / 1080 + 0.01694, 0, 0, x, y - 37 / 1080, 0, 1, 1, 1, 1)
    end
    util.yield()
end

util.keep_running()