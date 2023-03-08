require('ProfileHelperLib')

local header_path = filesystem.resources_dir() .. 'ProfileHelper\\Themes\\Circuit\\Header.bmp'
local footer_path = filesystem.resources_dir() .. 'ProfileHelper\\Themes\\Circuit\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ProfileHelper\\Themes\\Circuit\\Subheader.bmp'

if not io.exists(header_path) then
		util.toast('[SPH] Header not found, attempting download.')
		lib:download_file('Themes/Circuit/Header.bmp', {header_path})
end

if not io.exists(footer_path) then
		util.toast('[SPH] Footer not found, attempting download.')
		lib:download_file('Themes/Circuit/Footer.bmp', {footer_path})
end

if not io.exists(subheader_path) then
		util.toast('[SPH] Footer not found, attempting download.')
		lib:download_file('Themes/Circuit/Subheader.bmp', {subheader_path})
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)

while true do
		if menu.is_open() then
				local x, y, w, h = menu.get_main_view_position_and_size()
				directx.draw_texture(header, 1, (100 / 1080) / 2, 0, 0, x, y - 134 / 1080, 0, 1, 1, 1, 1)
				directx.draw_texture(subheader, 1, (33.7 / 1080) / 2, 0, 0, x, y - 34 / 1080, 0, 1, 1, 1, 1)
				directx.draw_texture(footer, 1, (34.7 / 1080) / 2, 0, 0, x, y + h - (1 / 1080), 0, 1, 1, 1, 1)
		end
		util.yield()
end

util.keep_running()
