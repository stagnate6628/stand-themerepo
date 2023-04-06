local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Phantom X\\Header.bmp'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Phantom X\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Phantom X\\Subheader.bmp'

if not io.exists(header_path) then
	util.toast('[ThemeRepo] Header not found!')
	util.stop_script()
end

if not io.exists(footer_path) then
	util.toast('[ThemeRepo] Footer not found!')
	util.stop_script()
end

if not io.exists(subheader_path) then
	util.toast('[ThemeRepo] Subheader not found!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)

while true do
	if menu.is_open() then
		local x, y, w, h = menu.get_main_view_position_and_size()
		directx.draw_texture(header, 1, (98 / 1080) / 2, 0, 0, x, y - 127 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(subheader, 1, (28.7 / 1000) / 2, 0, 0, x, y - 31 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(footer, 1, (31 / 1080) / 2, 0, 0, x - 0.01 / 1920, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)
	end
	util.yield()
end

util.keep_running()
