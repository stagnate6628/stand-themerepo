local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Epsilon\\Header.bmp'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Epsilon\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Epsilon\\Subheader.bmp'

local interaction_header_path = function(i)
	return filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Epsilon\\Interaction Header\\Header' .. i .. '.bmp'
end

for i = 1, 18 do
	if not filesystem.exists(interaction_header_path(i)) then
		util.toast('[ThemeRepo] Interaction header ' .. i .. ' not found!')
		util.stop_script()
	end
end

if not filesystem.exists(header_path) or not filesystem.exists(footer_path) or 
	not filesystem.exists(subheader_path) then

	util.toast('[ThemeRepo] One or more files are missing!')
	util.stop_script()
end

local header = directx.create_texture(header_path)
local footer = directx.create_texture(footer_path)
local subheader = directx.create_texture(subheader_path)
local globe = directx.create_texture(interaction_header_path(1))

util.create_tick_handler(function()
	if menu.is_open() then
		for i = 1, 18 do
			util.yield(50)
			globe = directx.create_texture(interaction_header_path(i))
		end
	
		util.yield(8 * 1000)

		local x, y, w, h = menu.get_main_view_position_and_size()
		directx.draw_texture(globe, 1, w / 1080 + 0.04984, 0, 0, x, y - 130 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(header, 1, w / 1080 + 0.04984, 0, 0, x, y - 130 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(subheader, 1, w / 1080 + 0.01274, 0, 0, x, y - 28 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(footer, 1, w / 1080 + 0.01368, 0, 0, x, y + h - (1 / 1080) + 0.0013, 0, 1, 1, 1, 1)
	end
	return true
end)