require('lib/downloader')
local inspect = require('lib/inspect')

local texture_names<const> = table.freeze({'Disabled.png', 'Edit.png', 'Enabled.png', 'Font.spritefont', 'Friends.png',
                                           'Header Loading.png', 'Link.png', 'List.png', 'Search.png', 'Toggle Off Auto.png',
                                           'Toggle Off.png', 'Toggle On Auto.png', 'Toggle On.png', 'User.png', 'Users.png'})
local tag_names<const> = table.freeze({'00.png', '01.png', '02.png', '03.png', '04.png', '05.png', '06.png', '07.png', '08.png',
                                       '09.png', '10.png', '11.png', '12.png', '13.png', '14.png', '15.png', '16.png', '17.png',
                                       '18.png', '19.png', '0A.png', '0B.png', '0C.png', '0D.png', '0E.png', '0F.png', '1A.png',
                                       '1B.png', '1C.png', '1D.png', '1E.png', '1F.png'})
local tab_names<const> = table.freeze({'Self.png', 'Vehicle.png', 'Online.png', 'Players.png', 'World.png', 'Game.png',
                                       'Stand.png'})

local bools = {
		['is_downloading'] = false,
		['prevent_redownloads'] = true,
		['verbose'] = false,
		['combine_profiles'] = false,
		['preview'] = false,
		['is_header_downloading'] = false
}

local dirs<const> = {
		['stand'] = filesystem.stand_dir(),
		['theme'] = filesystem.stand_dir() .. 'Theme\\',
		['header'] = filesystem.stand_dir() .. 'Headers\\Custom Header\\',
		['resources'] = filesystem.resources_dir() .. 'ProfileHelper\\'
}

local root = menu.my_root()

-- headers
local header_root = menu.list(root, 'Headers', {}, '')
local header_config = menu.list(header_root, 'Configuration', {}, '')

header_root:action('Install from Zip', {}, '', function()
end)
header_root:divider('List')
-- themes

local theme_root = menu.list(root, 'Themes', {}, '')
local theme_config = menu.list(theme_root, 'Configuration', {}, '')
theme_root:action('Install from Zip', {}, '', function()
end)
theme_root:divider('List')

local make_dirs<const> = {'Lua Scripts', 'Custom Header', 'Theme\\Custom', 'Theme\\Tabs'}

local function log(msg)
		local prefix = '[ProfileHelper] '

		if not bools.verbose then
				util.toast(prefix .. msg)
				return
		end

		local log_path = dirs['resources'] .. '\\log.txt'
		local log_file = io.open(log_path, 'a+')
		log_file:write('[' .. os.date('%x %I:%M:%S %p') .. '] ' .. msg .. '\n')
		log_file:close()
end
local function get_resource_dir_by_name(theme_name, file_path)
		return dirs['resources'] .. theme_name .. '\\' .. file_path
end
local function should_copy(file_path)
		return io.exists(file_path) and io.isfile(file_path) and bools['prevent_redownloads']
end
local function get_theme_dir(theme_name, path)
		local base = dirs.resources .. 'Themes\\' .. theme_name .. '\\'
		if path then
				return base .. path
		end

		return base
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
		local base_path = dirs['resources'] .. 'Themes\\' .. theme_name .. '\\'
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
local function reload_font()
		trigger_command_by_ref('Stand>Settings>Appearance>Font & Text>Reload Font')
end
local function reload_textures()
		trigger_command_by_ref('Stand>Settings>Appearance>Textures>Reload Textures')
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
		local meta_state_path = dirs['stand'] .. 'Meta State.txt'
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
local function get_profile_path()
		return filesystem.stand_dir() .. 'Profiles\\'
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

		trigger_command_by_ref('Stand>Lua Scripts')
		util.yield(250)
		trigger_command_by_ref('Stand>Lua Scripts>ProfileHelper')
		util.yield(100)
		trigger_command('clearstandnotifys')
		util.yield(100)
		trigger_command('reloadtextures')
		util.yield(100)
		trigger_command('reloadfont')

		if math.random() > 0.5 and not bools.combine_profiles then
				util.toast('Tip: Set the ' .. original_name .. ' as active to have it load on startup. (Stand>Profiles>' .. original_name ..
					           '>Active)')
		end

		util.log('WE ARE DONE')
end
local function download_theme(theme_name, deps)
		for k, v in make_dirs do
				if v == 'Lua Scripts' and #deps == 0 then
						goto continue
				end
				io.makedirs(dirs['resources'] .. 'Themes\\' .. theme_name .. '\\' .. v)
				::continue::
		end

		local function does_json_exist()
				return io.exists(dirs.resources .. 'Themes\\' .. theme_name .. '\\theme.json')
		end

		local function write_json(json)
				util.log('Writing json')
				local file, err = io.open(dirs.resources .. 'Themes\\' .. theme_name .. '\\theme.json', 'wb')
				if err then
						util.log('Failed to read file')
						return
				end

				local _, err = file:write(json)
				if err then
						util.log('Failed to write file')
						return
				end

				local success, err = file:close()
				if not success and err then
						util.log('Failed to close file handle')
						return
				end

				return
		end

		local function read_json()
				local file = io.open(dirs.resources .. 'Themes\\' .. theme_name .. '\\theme.json', 'r')
				local json = file:read('a')
				file:close()
				return json
		end

		local dir_list = {}
		if not does_json_exist() then
				utils:make_request('Themes/' .. theme_name, function(body, headers, status_code)
						local success, body = pcall(soup.json.decode, body)
						if not success then
								util.log('Failed to decode json [1]')
								return
						end

						for k, v in body do
								if v.type == 'dir' or v.size == 0 then
										table.insert(dir_list, v.path)
										table.remove(body, k)
										util.log('Inserting ' .. v.path)
								end
						end

						write_json(soup.json.encode(body, true))
				end)
		end

		if #dir_list > 0 then
				-- traverse a dir and get files
				local function combine_json(old_json, new_json)
						if type(old_json) == 'string' then
								util.log('Decoding old json')
								old_json = soup.json.decode(old_json)
						end

						if type(new_json) == 'string' then
								util.log('Decoding new json')
								new_json = soup.json.decode(new_json)
						end

						for k, v in new_json do
								table.insert(old_json, v)
						end

						return old_json
				end

				for k, v in dir_list do
						utils:make_request(v, function(body, headers, status_code)
								local success, body = pcall(soup.json.decode, body)
								if not success then
										util.toast('Failed to decode json [3]')
										return
								end

								for k, v in body do
										if v.type == 'dir' or v.size == 0 then
												table.insert(dir_list, v.path)
												table.remove(body, k)
												util.log('Inserting (2) ' .. v.path)
										end
								end

								local json = combine_json(read_json(), body)
								write_json(soup.json.encode(json, true))
						end)
				end
		end

		local function get_ext(file_name)
				local split = string.split(file_name, '.')
				return split[#split]
		end

		log('Compiled list')
		
		local success, json = pcall(soup.json.decode, read_json())
		if not success then
				log('Failed to decode json [2]')
				return
		end

		log('Starting json parse')

		clear_headers()
		log('Emptied headers')
		hide_header()

		local i = 0
		for k, v in json do
				local ext = get_ext(v.name)

				if v.path:contains('Custom Header') and (ext == 'png' or ext == 'gif') then
						local paths = {dirs.header .. v.name, get_theme_dir(theme_name, 'Custom Header\\' .. v.name)}
						utils:download_file(v.path, paths, function()
								util.log('Downloaded header ' .. v.name)
						end)
				elseif table.contains(texture_names, v.name) ~= nil then
						local paths = {get_theme_dir(theme_name, convert_path(v.path, true)), dirs.theme .. v.name}
						utils:download_file(v.path, paths, function()
								util.log('Downloaded custom texture ' .. v.name)
						end, nil, function()
								utils:download_file('Themes/Stand/Theme/' .. v.name, paths, function()
										util.log('Downloaded default texture ' .. v.name)
								end)
						end)
				elseif table.contains(tag_names, v.name) ~= nil then
						local paths = {get_theme_dir(theme_name, convert_path(v.path, true)), dirs.theme .. 'Custom\\' .. v.name}
						utils:download_file(v.path, paths, function()
								util.log('Downloaded custom tag' .. v.name)
						end, nil, function()
								utils:download_file('Themes/Stand/Theme/Custom/' .. v.name, paths, function()
										util.log('Downloaded default tag ' .. v.name)
								end)
						end)
				elseif table.contains(tab_names, v.name) ~= nil then
						local paths = {get_theme_dir(theme_name, convert_path(v.path, true)), dirs.theme .. 'Tabs\\' .. v.name}
						utils:download_file(v.path, paths, function()
								util.log('Downloaded custom tab ' .. v.name)
						end, nil, function()
								utils:download_file('Themes/Stand/Theme/Tabs/' .. v.name, paths, function()
										util.log('Downloaded default tab ' .. v.name)
								end)
						end)
				elseif ext == 'txt' then
						local paths = {dirs.stand .. 'Profiles\\' .. v.name, get_theme_dir(theme_name, v.name)}
						utils:download_file(v.path, paths, function()
								util.log('Downloaded profile ' .. v.name)
						end)
				else
						util.log('Dont know what to do with ' .. v.name .. ' at ' .. v.path)
				end

				i = i + 1
		end

		repeat
				util.log('YIELDING UNTIL FINISH|' .. i .. ';' .. #json)
				util.yield()
		until i == #json

		reload_textures()
		reload_font()
		load_profile(theme_name)

		util.toast('Looks like we are done downloading everything!')
		util.log('WE APPARENTLY FINISHED')
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

						theme_root:action(theme_name, {}, theme_author, function(click_type)
								if bools['is_downloading'] then
										theme_root:show_warning(click_type,
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

		local path = dirs['resources'] .. '\\themes.txt'
		local function download_list()
				utils:download_file('themes.txt', {path}, function(body, headers, status_code)
						log('Creating theme cache')

						local file = io.open(path, 'wb')
						file:write(body)
						file:close()

						pcall(parse_list, body)
				end, function()
						log('Failed to download themes list.')
				end)
		end

		local file = io.open(path, 'r')
		if file ~= nil then
				if update then
						log('Request to update theme list')
						local children = menu.get_children(theme_root)
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

				log('Found local theme cache')
				parse_list(file:read('*a'))
				file:close()
		else
				download_list()
		end
end
menu.action(theme_config, 'Update List', {}, '', function()
		download_themes(true)
end)

io.makedirs(dirs['resources'])
download_themes()

-- local reset_root = menu.list(settings_root, 'Reset', {}, '')
-- reset_root:action('Default Textures and Font', {}, '', function()
-- 		for _, path in io.listdir(dirs['theme']) do
-- 				if io.isfile(path) then
-- 						io.remove(path)
-- 				end

-- 				if io.isdir(path) then
-- 						for _, path2 in io.listdir(path) do
-- 								io.remove(path2)
-- 						end
-- 				end
-- 		end

-- 		reload_textures()
-- 		reload_font()
-- end)
-- reset_root:action('Default Headers', {}, '', function()
-- 		clear_headers()
-- 		hide_header()
-- end)

util.keep_running()
menu.action(menu.my_root(), 'restart', {}, '', function()
		trigger_command('emptylog')
		util.restart_script()
end)