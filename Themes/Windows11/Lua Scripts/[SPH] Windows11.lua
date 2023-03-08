require('ProfileHelperLib')

local background_path = filesystem.resources_dir() .. 'ProfileHelper\\Themes\\Windows11\\Background.png'
local profile_path = filesystem.resources_dir() .. 'ProfileHelper\\Themes\\Windows11\\Profile.png'

if not io.exists(background_path) then
		util.toast('[SPH] Background not found, attempting download.')
		lib:download_file('Themes/Windows11/Background.png', {background_path})
end

if not io.exists(profile_path) then
		util.toast('[SPH] ProfileIcon not found, attempting download.')
		lib:download_file('Themes/Windows11/Profile.png', {profile_path})
end

local profile = directx.create_texture(profile_path)
local background = directx.create_texture(background_path)

while true do
		if menu.command_box_is_open() then
				local cmd_x, cmd_y, w, h = menu.command_box_get_dimensions()
				directx.draw_rect(0.357, 0.09, 0.0015, h + 0.007, 0.247, 0.282, 0.8, 1.0)
				directx.draw_rect(0.358, 0.09, 0.2848, h + 0.007, 1, 1, 1, 1)
		end

		if menu.is_open() then
				local x, y = menu.get_main_view_position_and_size()
				directx.draw_texture(profile, 0.01, 0.01, 0.0, 0.0, x - 0.07, y - 0.078, 0.0, 1, 1, 1, 1)
				directx.draw_texture(background, 0.17, 0.17, 0.0, 0.0, x - 0.075, y - 0.105, 0.0, 1, 1, 1, 1)
				directx.draw_rect(x - 0.065, y - 0.0036, 0.318, 0.001, 0.247, 0.282, 0.8, 1.0)
				directx.draw_text(x - 0.06, y - 0.095, 'Stand', ALIGN_TOP_LEFT, 0.5, 0.5, 0.5, 0.5, 1.0, false)
		end
		util.yield()
end
