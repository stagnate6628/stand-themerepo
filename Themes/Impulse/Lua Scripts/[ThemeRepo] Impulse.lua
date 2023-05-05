local header_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Impulse\\Header1.bmp'
local footer_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Impulse\\Footer.bmp'
local subheader_path = filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Impulse\\Subheader.bmp'

local function get_header_path(i)
	return filesystem.resources_dir() .. 'ThemeRepo\\Themes\\Impulse\\Header' .. i .. '.bmp'
end

for i = 1, 50 do
	if not io.exists(get_header_path(i)) then
		util.toast('[ThemeRepo] Header ' .. i .. ' not found!')
		util.stop_script()
	end
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

-- this is probably broken
util.create_tick_handler(function()
	if not menu.is_open() then
		return false
	end

	for i = 1, 50 do
		util.yield(50)
		header = directx.create_texture(get_header_path(i))
		util.yield()
	end

	util.yield(1000)
end)

while true do
	if menu.is_open() then
		local x, y, w, h = menu.get_main_view_position_and_size()
		directx.draw_texture(header, 1, (w / 1080) + 0.05115, 0, 0, x, y - 146 / 1080, 0, 1, 1, 1, 1)
		directx.draw_texture(subheader, 1, (w / 1080) + 0.016, 0, 0, x, (y - 35 / 1080), 0, 1, 1, 1, 1)
		directx.draw_texture(footer, 1, (w / 1080) + 0.0169, 0, 0, x, (y + h - (1 / 1080)), 0, 1, 1, 1, 1)
	end
	util.yield()
end

util.keep_running()
