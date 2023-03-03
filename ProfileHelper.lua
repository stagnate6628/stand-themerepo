-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, 'auto-updater')
if not status then
	local auto_update_complete = nil
	util.toast('Installing auto-updater...', TOAST_ALL)
	async_http.init('raw.githubusercontent.com', '/hexarobi/stand-lua-auto-updater/main/auto-updater.lua',
	                function(result, headers, status_code)
		local function parse_auto_update_result(result, headers, status_code)
			local error_prefix = 'Error downloading auto-updater: '
			if status_code ~= 200 then
				util.toast(error_prefix .. status_code, TOAST_ALL)
				return false
			end
			if not result or result == '' then
				util.toast(error_prefix .. 'Found empty file.', TOAST_ALL)
				return false
			end
			filesystem.mkdir(filesystem.scripts_dir() .. 'lib')
			local file = io.open(filesystem.scripts_dir() .. 'lib\\auto-updater.lua', 'wb')
			if file == nil then
				util.toast(error_prefix .. 'Could not open file for writing.', TOAST_ALL)
				return false
			end
			file:write(result)
			file:close()
			util.toast('Successfully installed auto-updater lib', TOAST_ALL)
			return true
		end
		auto_update_complete = parse_auto_update_result(result, headers, status_code)
	end, function()
		util.toast('Error downloading auto-updater lib. Update failed to download.', TOAST_ALL)
	end)
	async_http.dispatch()
	local i = 1
	while (auto_update_complete == nil and i < 40) do
		util.yield(250)
		i = i + 1
	end
	if auto_update_complete == nil then
		error('Error downloading auto-updater lib. HTTP Request timeout')
	end
	auto_updater = require('auto-updater')
end
if auto_updater == true then
	error('Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again')
end

local auto_update_config = {
	source_url = 'https://raw.githubusercontent.com/stagnate6628/stand-profile-helper/main/ProfileHelper.lua',
	script_relpath = SCRIPT_RELPATH,
	verify_file_begins_with = '--',
	check_interval = 86400,
	-- silent_updates = true,
	dependencies = {{
		name = 'downloader',
		source_url = 'https://raw.githubusercontent.com/stagnate6628/stand-profile-helper/main/lib/downloader.lua',
		script_relpath = 'lib/downloader.lua',
		verify_file_begins_with = '-- sph-downloader.lua',
		check_interval = 604800,
		is_required = true
	}}
}

auto_updater.run_auto_update(auto_update_config)
-- require('lib/downloader')

for _, dependency in auto_update_config.dependencies do
	if dependency.is_required then
		if dependency.loaded_lib == nil then
			util.toast('Error loading lib ' .. dependency.name, TOAST_ALL)
		else
			local var_name = dependency.name
			_G[var_name] = dependency.loaded_lib
		end
	end
end

local texture_names<const> = table.freeze({'Disabled.png', 'Edit.png', 'Enabled.png', 'Font.spritefont', 'Friends.png',
                                           'Header Loading.png', 'Link.png', 'List.png', 'Search.png', 'Toggle Off Auto.png',
                                           'Toggle Off.png', 'Toggle On Auto.png', 'Toggle On.png', 'User.png', 'Users.png'})
local tag_names<const> = table.freeze({'00.png', '01.png', '02.png', '03.png', '04.png', '05.png', '06.png', '07.png', '08.png',
                                       '09.png', '10.png', '11.png', '12.png', '13.png', '14.png', '15.png', '16.png', '17.png',
                                       '18.png', '19.png', '0A.png', '0B.png', '0C.png', '0D.png', '0E.png', '0F.png', '1A.png',
                                       '1B.png', '1C.png', '1D.png', '1E.png', '1F.png'})
local tab_names<const> = table.freeze({'Self.png', 'Vehicle.png', 'Online.png', 'Players.png', 'World.png', 'Game.png',
                                       'Stand.png'})
local file_map<const> = {
	['Textures'] = texture_names,
	['Tags'] = tag_names,
	['Tabs'] = tab_names
}

local bools = {
	['is_downloading'] = false,
	['prevent_redownloads'] = true,
	['verbose'] = false,
	['combine_profiles'] = false
}

local headers = menu.list(menu.my_root(), 'Headers', {}, '')
local themes = menu.list(menu.my_root(), 'Themes', {}, '')
local theme_config = menu.list(themes, 'Configuration', {}, '')
theme_config:toggle('Combine Profiles', {},
                    'Allows you to save the current state of the active profile with a clean version of a theme.', function(s)
	bools['combine_profiles'] = s
end, false)
themes:divider('Theme List')

local settings_root = menu.list(menu.my_root(), 'Settings', {}, '')
settings_root:toggle('Verbose', {}, '', function(s)
	bools['verbose'] = s
end, false)
settings_root:action('Restart Script', {}, '', util.restart_script)
settings_root:action('Update Script', {}, '', function()
	auto_update_config.check_interval = 0
	auto_updater.run_auto_update(auto_update_config)
end)

local dirs<const> = {
	['stand'] = filesystem.stand_dir(),
	['theme'] = filesystem.stand_dir() .. 'Theme\\',
	['header'] = filesystem.stand_dir() .. 'Headers\\Custom Header',
	['resources'] = filesystem.resources_dir() .. 'ProfileHelper\\'
}

local make_dirs<const> = {'Lua Scripts', 'Custom Header', 'Theme\\Custom', 'Theme\\Tabs'}

local function log(msg)
	if bools['verbose'] then
		util.toast(msg)

		-- local log_path = dirs['resources'] .. '\\log.txt'
		-- local log_file = io.open(log_path, 'a+')
		-- log_file:write('[' .. os.date('%x %I:%M:%S %p') .. '] ' .. msg .. '\n')
		-- log_file:close()
	end
end
local function get_resource_dir_by_name(theme_name, file_path)
	return dirs['resources'] .. theme_name .. '\\' .. file_path
end
local function should_copy(file_path)
	return io.exists(file_path) and io.isfile(file_path) and bools['prevent_redownloads']
end
local function get_theme_path(theme_name)
	return 'Themes/' .. theme_name
end
local function get_theme_url_path(theme_name, file_name)
	return get_theme_path(theme_name) .. '/' .. file_name
end
local function get_req_path(theme_name, file_name)
	local path = 'Themes/' .. theme_name .. '/'
	if file_name == nil then
		return path
	end

	return path .. file_name
end
local function convert_path(path, to_backslashes)
	if to_backslashes then
		return path:gsub('/', '\\')
	end

	return path:gsub('\\', '/')
end
local function get_local_path(theme_name, file_name)
	local base_path = dirs['resources'] .. theme_name .. '\\'
	if file_name == nil then
		return base_path
	end

	local file_map<const> = {
		['header'] = 'Header.bmp',
		['footer'] = 'Footer.bmp',
		['subheader'] = 'Subheader.bmp',
		['profile'] = theme_name .. '.txt'
	}

	if file_map[file_name] ~= nil then
		return base_path .. file_map[file_name]
	end

	local is_texture = texture_names[file_name] ~= nil
	local is_tag = tag_names[file_name] ~= nil
	local is_tab = tab_names[file_name] ~= nil
	if is_texture or is_tag or is_tab then
		local folder = 'Theme\\'
		if is_tag then
			folder = folder .. 'Custom'
		elseif is_tab then
			folder = folder .. 'Tabs'
		end

		return base_path .. folder .. file_name
	end

	return base_path .. file_name
end
local function trigger_command(command, args)
	local input = command
	if args then
		input = command .. ' ' .. args
	end

	menu.trigger_commands(input)
end
local function trigger_command_by_ref(path, args)
	local ref = menu.ref_by_path(path, 44)
	if not ref:isValid() then
		return false
	end

	if args == nil then
		menu.trigger_command(ref)
	else
		menu.trigger_command(ref, args)
	end

	return true
end
local function hide_header()
	trigger_command_by_ref('Stand>Settings>Appearance>Header>Header>Be Gone')
end
local function use_custom_header()
	trigger_command_by_ref('Stand>Settings>Appearance>Header>Header>Custom')
end
local function clear_headers()
	for _, path in io.listdir(dirs['header']) do
		io.remove(path)
	end
end
local function clean_profile_name(profile_name)
	return string.gsub(string.gsub(profile_name, '%-', ''), ' ', ''):lower()
end
local function get_active_profile_name()
	local meta_state_path = filesystem.stand_dir() .. 'Meta State.txt'
	local file = io.open(meta_state_path, 'rb')

	if file == nil then
		return file
	end

	local str = file:read('*a')
	file:close()

	if str:startswith('Active Profile:') then
		local active_profile_name = str:gsub('[\n\r]', ''):split(': ')[2]
		return active_profile_name
	end

	return nil
end

local function load_profile(profile_name)
	local original_name = profile_name
	profile_name = clean_profile_name(profile_name)

	util.yield(500)
	trigger_command_by_ref('Stand>Profiles')
	util.yield(100)
	trigger_command_by_ref('Stand')
	util.yield(100)
	trigger_command_by_ref('Stand>Profiles')
	util.yield(500)

	if bools['combine_profiles'] then
		local active_profile_name = clean_profile_name(get_active_profile_name())
		for k, v in util.read_colons_and_tabs_file(dirs['stand'] .. 'Profiles\\' .. profile_name .. '.txt') do
			if k:startswith('Stand>Settings>Appearance') or k:startswith('Stand>Lua Scripts') then
				local ref = menu.ref_by_path(k .. '>' .. v, 43)
				if not ref:isValid() then
					trigger_command_by_ref(k, v)
				else
					trigger_command_by_ref(k .. '>' .. v)
				end
			end
			util.yield()
		end
		util.yield(100)
		trigger_command('save' .. active_profile_name)
	else
		if not trigger_command_by_ref('Stand>Profiles>' .. original_name .. '>Active') then
			util.toast('Failed to set ' .. original_name .. ' as the active profile. You may need to do this yourself.')
		end
		util.yield(100)
		trigger_command('load' .. profile_name)
		util.yield(1000)
	end

	util.toast('we are here')
	trigger_command_by_ref('Stand>Lua Scripts')
	util.yield(250)
	trigger_command_by_ref('Stand>Lua Scripts>ProfileHelper-dev')
	-- menu.focus(menu.ref_by_path('Stand>Lua Scripts>ProfileHelper-dev', 44))
	trigger_command('clearstandnotifys')
end
local function download_theme(theme_name, deps)
	for k, v in make_dirs do
		if v == 'Lua Scripts' and #deps == 0 then
			goto continue
		end
		io.makedirs(dirs['resources'] .. theme_name .. '\\' .. v)
		::continue::
	end

	local profile_path = dirs['stand'] .. 'Profiles\\' .. theme_name .. '.txt'
	local resource_profile_path = get_local_path(theme_name, 'profile')
	if should_copy(resource_profile_path) then
		downloader:copy_file(resource_profile_path, profile_path)
		log('Profile: copied')
	else
		downloader:download_file(get_req_path(theme_name, theme_name .. '.txt'), {profile_path, resource_profile_path}, function()
			log('Profile: downloaded')
		end)
	end

	local resource_footer_path = get_resource_dir_by_name(theme_name, 'Footer.bmp')
	if should_copy(resource_footer_path) then
		-- log('Footer: copied')
	else
		downloader:download_file(get_theme_url_path(theme_name, 'Footer.bmp'), {resource_footer_path}, function()
			log('Footer: downloaded')
		end, nil, nil)
	end
	util.yield(250)

	local resource_subheader_path = get_resource_dir_by_name(theme_name, 'Subheader.bmp')
	if should_copy(resource_subheader_path) then
		-- log('Subheader: copied')
	else
		downloader:download_file(get_theme_url_path(theme_name, 'Subheader.bmp'), {resource_subheader_path}, function()
			log('Subheader: downloaded')
		end, nil, nil)
	end
	util.yield(250)

	-- header.bmp
	local header_path = get_resource_dir_by_name(theme_name, 'Header.bmp')
	if should_copy(header_path) then
		-- log('Header: copied')
	else
		hide_header()
		downloader:download_file(get_theme_url_path(theme_name, 'Header.bmp'), {header_path}, function()
			log('Header: downloaded')
		end, nil, function()
			-- headerX.bmp
			header_path = get_resource_dir_by_name(theme_name, 'Header1.bmp')
			downloader:download_file(get_theme_url_path(theme_name, 'Header1.bmp'), {header_path}, function()
				local exists = true
				local i = 2
				while exists do
					util.yield(100)
					downloader:download_file(get_theme_url_path(theme_name, 'Header' .. i .. '.bmp'),
					                         {get_resource_dir_by_name(theme_name, 'Header' .. i .. '.bmp')}, function()
						log('Custom header: downloaded header ' .. i)
					end, nil, function()
						exists = false
					end)
					i = i + 1
				end
			end, nil, function()
				-- custom headers dir
				-- todo: store headers locally when using this method
				clear_headers()
				util.yield(250)
				if downloader:download_directory(get_theme_url_path(theme_name, 'Custom Header'), dirs['header']) then
					util.yield(1000)
					use_custom_header()
					log('Using custom header (3)')
				else
					log('Using no header (4)')
				end
			end)
		end)
	end

	for k1, v1 in file_map do
		local d = 0
		local c = 0
		local url_path = 'Theme/'
		if k1 == 'Tags' then
			url_path = 'Theme/Custom/'
		elseif k1 == 'Tabs' then
			url_path = 'Theme/Tabs/'
		end

		for k2, v2 in v1 do
			local paths = {get_resource_dir_by_name(theme_name, convert_path(url_path, true) .. v2),
                  filesystem.stand_dir() .. convert_path(url_path, true) .. v2}
			if should_copy(paths[1]) then
				downloader:copy_file(paths[1], paths[2])
				log(k1 .. ': copied ' .. v2)
				c = c + 1
			else
				downloader:download_file(get_req_path(theme_name, url_path) .. v2, paths, function()
					log(k1 .. ': downloaded custom ' .. v2)
				end, nil, function()
					downloader:download_file(get_req_path('Stand', url_path) .. v2, paths, function()
						log(k1 .. ': downloaded default ' .. v2)
					end, nil, nil)
				end)
				d = d + 1
			end
		end
		log(string.format('%s: %d downloaded, %d copied', k1, d, c))
		util.yield(250)
	end

	if #deps > 0 then
		local d = 0
		for _, dep in deps do
			-- dont cache scripts
			downloader:download_file('Dependencies/' .. dep, filesystem.scripts_dir() .. dep, function()
				d = d + 1
			end)
		end
		log(string.format('Lua Scripts: %d downloaded', d))
	end

	util.yield(1000)

	trigger_command('reloadtextures')
	trigger_command('reloadfont')

	load_profile(theme_name)
end

local function download_themes(update)
	local function parse_list(out)
		local list = out:split('\n')
		for _, v in list do
			if v == '' then
				goto continue
			end

			local parts = v:split(';')
			local theme_name = parts[1]
			local theme_author = 'Made by ' .. parts[2]
			local deps = {}

			if type(parts[3]) == 'string' and string.len(parts[3]) > 0 then
				if parts[3]:contains(',') then
					for _, v in parts[3]:split(',') do
						table.insert(deps, v)
					end
				else
					table.insert(deps, parts[3])
				end
			end

			themes:action(theme_name, {}, theme_author, function(click_type)
				if bools['is_downloading'] then
					menu.show_warning(themes, click_type,
					                  'A download has already started. You may need to wait for the theme to finish downloading. Proceed?',
					                  function()
						bools['is_downloading'] = false
					end)
					return
				end

				bools['is_downloading'] = true
				download_theme(theme_name, deps)
				bools['is_downloading'] = false
			end)
			::continue::
		end
	end

	local function download_list()
		downloader:download_file('credits.txt', {}, function(body, headers, status_code)
			log('Creating theme cache')

			local file = io.open(dirs['resources'] .. '\\themes.txt', 'wb')
			file:write(body)
			file:close()

			pcall(parse_list, body)
		end, function()
			log('Failed to download themes list.')
		end)
	end

	local file = io.open(dirs['resources'] .. '\\themes.txt', 'r')
	if file ~= nil then
		if update then
			local children = menu.get_children(themes)
			for k, v in children do
				if v.menu_name == 'Configuration' then
					goto continue
				end

				v:delete()
				::continue::
			end

			download_list()
			return
		end

		-- log('Found local theme cache')
		parse_list(file:read('*a'))
		file:close()
	else
		download_list()
	end
end
menu.action(theme_config, 'Update List', {}, '', function()
	download_themes(true)
end)

util.toast('Please be mindful to maintain backups of profiles and textures as needed.')
io.makedirs(dirs['resources'])
download_themes()

util.keep_running()
