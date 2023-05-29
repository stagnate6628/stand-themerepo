local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Rebound\\Header.bmp'
local subheader_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Rebound\\Subheader.bmp'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Rebound\\Footer.bmp'

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

		directx.draw_texture(header, 1, w / 1080 + 0.047, 0, 0, x, y - 137 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(subheader, 1, w / 1080 + 0.015979, 0, 0, x, y - 35 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(footer, 1, w / 1080 + 0.01598, 0, 0, x, y + h - 1 / 1080, 0, 1, 1, 1, 1)

		-- directx.draw_text(
		-- 	x + 0.003, y - 0.025,
		-- 	lang.get_string(menu.get_current_menu_list().menu_name):upper(),
		-- 	ALIGN_TOP_LEFT,
		-- 	0.6,
		-- 	1,
		-- 	1,
		-- 	1,
		-- 	1
		-- )
		-- directx.draw_text(
		-- 	x + 0.235, y - 0.025,
		-- 	table.concat(menu.get_active_list_cursor_text(true, false):split('/'), ' / '),
		-- 	ALIGN_TOP_RIGHT,
		-- 	0.6,
		-- 	1,
		-- 	1,
		-- 	1,
		-- 	1
		-- )
	end
	return true
end)