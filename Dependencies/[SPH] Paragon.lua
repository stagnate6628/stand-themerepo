require("downloader")

local base_dir = filesystem.resources_dir() .. "stand-profile-helper\\Paragon\\"
if not io.isdir(base_dir) then
    io.makedirs(base_dir)
end

local header_path = base_dir .. "Header.bmp"
local subheader_path = base_dir .. "Subheader.bmp"
local footer_path = base_dir .. "Footer.bmp"

if not io.exists(header_path) then
    download_file("Themes/Paragon/Header.bmp", {header_path})
    util.toast("Downloading header")
    should_restart = true
end

if not io.exists(subheader_path) then
    download_file("Themes/Paragon/Subheader.bmp", {subheader_path})
    util.toast("Downloading subheader")
    should_restart = true
end

if not io.exists(footer_path) then
    download_file("Themes/Paragon/Footer.bmp", {footer_path})
    util.toast("Downloading footer")
    should_restart = true
    util.yield(1000)
end

if should_restart then
    util.restart_script()
    util.toast("Restarting the script for you.")
end

local header = directx.create_texture(header_path)
local subheader = directx.create_texture(subheader_path)
local footer = directx.create_texture(footer_path)

while true do
    local x, y, w, h = menu.get_main_view_position_and_size()

    if menu.is_open() then
        -- header
        directx.draw_texture(header, 1, (128 / 1080) / 2, 0, 0, x - 2 / 1920, y - 166 / 1080, 0, 1, 1, 1, 1)

        -- subheader
        directx.draw_texture(subheader, 1, (38 / 1080) / 2, 0, 0, x - 2 / 1920, (y - 38 / 1080), 0, 1, 1, 1, 1)

        -- footer
        directx.draw_texture(footer, 1, (38 / 1080) / 2, 0, 0, x - 2 / 1920, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)

        -- border
        directx.draw_rect(x - 2 / 1920, y, 2 / 1920, h, 72 / 255, 148 / 255, 234 / 255, 1)
        directx.draw_rect(x + w, y, 2 / 1920, h, 72 / 255, 148 / 255, 234 / 255, 1)
    end

    util.yield()
end
