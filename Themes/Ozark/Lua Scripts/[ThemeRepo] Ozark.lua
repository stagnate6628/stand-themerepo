local header_path = filesystem.resources_dir() .. "ThemeRepo\\Themes\\Ozark\\Header.bmp"
local subheader_path = filesystem.resources_dir() .. "ThemeRepo\\Themes\\Ozark\\Subheader.bmp"

local interaction_header_path = function(i)
    return filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Ozark\\Interaction Header\\Header' .. i .. ".bmp"
end

for i = 1, 18 do
    if not io.exists(interaction_header_path(i)) then
        util.toast('[ThemeRepo] Header ' .. i .. ' not found!')
        util.stop_script()
    end
end

if not filesystem.exists(header_path) or notfilesystem.exists(subheader_path) then
	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local subheader = directx.create_texture(subheader_path)
local globe = directx.create_texture(interaction_header_path(1))

util.create_tick_handler(function()
    if menu.is_open() then
        for i = 1, 18 do
            util.yield(50)
            globe = directx.create_texture(interaction_header_path(i))
        end

        local x, y, w, h = menu.get_main_view_position_and_size()
        directx.draw_texture(globe, 1, w / 1080 + 0.0498, 0, 0, x, y - 145 / 1080, 0, 1, 1, 1, 1)
        directx.draw_texture(header, 1, w / 1080 + 0.0498, 0, 0, x, y - 145 / 1080, 0, 1, 1, 1, 1)

        util.yield(8 * 1000)
    end
    return true
end)