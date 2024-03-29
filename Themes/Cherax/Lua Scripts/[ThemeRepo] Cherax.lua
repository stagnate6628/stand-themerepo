local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Cherax\\Header.bmp'

if not filesystem.exists(header_path) then
	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)

util.create_tick_handler(function()
	if menu.command_box_is_open() then
		local cmd_x, cmd_y, w, h = menu.command_box_get_dimensions()
		directx.draw_rect(0.358, 0.094, 0.2848, h + 0.005, 0.050, 0.003, 0.082, 1)
	end

	if menu.is_open() then
		local x, y = menu.get_main_view_position_and_size()
		directx.draw_texture(header, 0.030, 0.030, 0.5, 0.5, x - 0.078, y + 0.191, 0.0, 1, 1, 1, 1)
		directx.draw_rect(x - 0.05, y, 0.302, 0.382, 0.050, 0.003, 0.082, 1)
		directx.draw_rect(x - 0.108, y - 0.023, 0.060, 0.023, 0.439, 0.137, 0.886, 1)
	end
	return true
end)