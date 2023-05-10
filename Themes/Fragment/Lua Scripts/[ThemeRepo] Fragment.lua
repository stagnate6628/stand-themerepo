local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Fragment\\Header.bmp'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Fragment\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Fragment\\Subheader.bmp'

if not filesystem.exists(header_path) or not filesystem.exists(footer_path) or not
	filesystem.exists(subheader_path) then

	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)

util.create_tick_handler(function()
	if menu.is_open() then
		local x, y, w, h = menu.get_main_view_position_and_size()
		directx.draw_texture(header, 1, (w / 1080) + 0.03223, 0, 0, x, y - 128 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(subheader, 1, w / 1080 + 0.02714, 0, 0, x, y - 58 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(footer, 1, w / 1080 + 0.02718, 0, 0, x, (y + h - (1 / 1080) + 0.0013), 0, 1, 1, 1, 1)
	end
	return true
end)