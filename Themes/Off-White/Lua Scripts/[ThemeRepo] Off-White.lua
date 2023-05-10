local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Off-White\\Header.bmp'

if not filesystem.exists(header_path) then
	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)

util.create_tick_handler(function()
	if menu.is_open() then
		local x = menu.get_main_view_position_and_size()
		directx.draw_texture(header, 0.0375, 0.0375, x + 0.37, 0.5, 110 / 1920, 0.2491, 0, 1, 1, 1, 1)
	end
	return true
end)