require('lib/ProfileHelperLib')
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
menu.toggle(header_config, 'Preview on Focus', {}, '', function(s)
		bools['preview'] = s
end, false)
-- themes

local theme_root = menu.list(root, 'Themes', {}, '')
local theme_config = menu.list(theme_root, 'Configuration', {}, '')
theme_config:toggle('Re-use Local Assets', {}, '', function(s)
		bools['prevent_redownloads'] = s
end, true)
theme_config:toggle('Combine Profiles', {}, '', function(s)
		bools['combine_profiles'] = s
end, false)

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
local function convert_path(path, to_backslashes)
		if to_backslashes then
				return path:gsub('/', '\\')
		end

		return path:gsub('\\', '/')
end
local function hide_header()
		lib:trigger_command_by_ref('Stand>Settings>Appearance>Header>Header>Be Gone')
end
local function use_custom_header()
		lib:trigger_command_by_ref('Stand>Settings>Appearance>Header>Header>Custom')
end
local function reload_font()
		lib:trigger_command_by_ref('Stand>Settings>Appearance>Font & Text>Reload Font')
end
local function reload_textures()
		lib:trigger_command_by_ref('Stand>Settings>Appearance>Textures>Reload Textures')
end
local function clear_headers()
		for _, path in io.listdir(dirs['header']) do
				io.remove(path)
		end
end
local function clean_profile_name(profile_name)
		return profile_name:gsub('%-', ''):gsub(' ', ''):lower()
end
local function get_active_profile_name()
		local meta_state_path = dirs['stand'] .. 'Meta State.txt'
		local file = io.open(meta_state_path, 'rb')

		if file == nil then
				return nil
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
		lib:trigger_command_by_ref('Stand>Profiles')
		util.yield(100)
		lib:trigger_command_by_ref('Stand')
		util.yield(100)
		lib:trigger_command_by_ref('Stand>Profiles')
		util.yield(500)

		if bools['combine_profiles'] then
				local active_profile_name = clean_profile_name(get_active_profile_name())
				for k, v in util.read_colons_and_tabs_file(dirs['stand'] .. 'Profiles\\' .. profile_name .. '.txt') do
						if k:startswith('Stand>Settings>Appearance') or k:startswith('Stand>Lua Scripts') then
								local ref = menu.ref_by_path(k .. '>' .. v, 43)
								if not ref:isValid() then
										lib:trigger_command_by_ref(k, v)
								else
										lib:trigger_command_by_ref(k .. '>' .. v)
								end
						end
						util.yield()
				end
				util.yield(100)
				lib:trigger_command('save' .. active_profile_name)
		else
				if not lib:trigger_command_by_ref('Stand>Profiles>' .. original_name .. '>Active') then
						util.toast('Failed to set ' .. original_name .. ' as the active profile. You may need to do this yourself.')
				end
				util.yield(100)
				lib:trigger_command('load' .. profile_name)
				util.yield(1000)
		end

		lib:trigger_command_by_ref('Stand>Lua Scripts')
		util.yield(250)
		lib:trigger_command_by_ref('Stand>Lua Scripts>ProfileHelper')
		util.yield(100)
		lib:trigger_command('clearstandnotifys')
		util.yield(100)
		reload_textures()
		reload_font()

		if math.random() > 0.5 and not bools.combine_profiles then
				util.toast('Tip: Mark the ' .. original_name .. ' as Active to have it load on startup. (Stand>Profiles>' .. original_name ..
					           '>Active)')
		end

		util.toast('Done!')
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
				lib:make_request('Themes/' .. theme_name, function(body, headers, status_code)
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
						lib:make_request(v, function(body, headers, status_code)
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

				log('Compiled json list')
		end

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
				local ext = lib:get_ext(v.name)
				local paths = {dirs['resources'] .. convert_path(v.path, true)}

				-- TODO: push fix for deps not downloading since lua scripts rework
				if v.path:contains('Custom Header') and (ext == 'png' or ext == 'gif') then
						local paths = {dirs.header .. v.name, get_theme_dir(theme_name, 'Custom Header\\' .. v.name)}
						if should_copy(paths[1]) then
								lib:copy_file(paths[1], paths[2])
								util.log('COPIED ' .. paths[1] .. ' to ' .. paths[2])
						else
								lib:download_file(v.path, paths, function()
										util.log('Downloaded header ' .. v.name)
								end)
						end
				elseif table.contains(texture_names, v.name) ~= nil then
						table.insert(paths, dirs['theme'] .. v.name)
						if should_copy(paths[1]) then
								lib:copy_file(paths[1], paths[2])
								util.log('COPIED ' .. paths[1] .. ' to ' .. paths[2])
						else
								lib:download_file(v.path, paths, function()
										util.log('Downloaded custom texture ' .. v.name)
								end)
						end
				elseif table.contains(tag_names, v.name) ~= nil then
						table.insert(paths, dirs['theme'] .. 'Custom\\' .. v.name)
						if should_copy(paths[1]) then
								lib:copy_file(paths[1], paths[2])
								util.log('COPIED ' .. paths[1] .. ' to ' .. paths[2])
						else
								lib:download_file(v.path, paths, function()
										util.log('Downloaded custom tag ' .. v.name)
								end)
						end
				elseif table.contains(tab_names, v.name) ~= nil then
						table.insert(paths, dirs['theme'] .. 'Tabs\\' .. v.name)
						if should_copy(paths[1]) then
								lib:copy_file(paths[1], paths[2])
								util.log('COPIED ' .. paths[1] .. ' to ' .. paths[2])
						else
								lib:download_file(v.path, paths, function()
										util.log('Downloaded custom tab ' .. v.name)
								end)
						end
				elseif ext == 'txt' then
						table.insert(paths, dirs['stand'] .. 'Profiles\\' .. v.name)
						if should_copy(paths[1]) then
								lib:copy_file(paths[1], paths[2])
								util.log('COPIED ' .. paths[1] .. ' to ' .. paths[2])
						else
								lib:download_file(v.path, paths, function()
										util.log('Downloaded profile ' .. v.name)
								end)
						end
				else
						util.log('Dont know what to do with ' .. v.name .. ' at ' .. v.path)
				end

				i = i + 1
		end

		repeat
				util.yield()
		until i == #json

		reload_textures()
		reload_font()
		load_profile(theme_name)

		util.toast('Looks like we are done downloading everything!')
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
										menu.show_warning(theme_root, click_type,
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
				lib:download_file('themes.txt', {path}, function(body, headers, status_code)
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

local function download_headers(update)
		local function parse_list(out)
				local list = out:split('\n')
				for _, v in list do
						if v == '' then
								goto continue
						end

						local function cb()
								while bools['is_header_downloading'] do
										util.yield()
								end

								bools['is_header_downloading'] = true

								clear_headers()
								lib:make_request('Headers/' .. v, function(body, headers, status_code)
										body = soup.json.decode(body)

										local i = 1
										for k, v in body do
												lib:download_file(v.path, dirs['header'] .. v.name, function()
														log('Downloaded header ' .. v.name .. ' (' .. i .. '/' .. #body .. ')')
												end)
										end

										local ref = menu.ref_by_path('Stand>Settings>Appearance>Header>Header', 44)
										if menu.get_value(ref) == 200 then
												hide_header()
										end
										use_custom_header()

										bools['is_header_downloading'] = false
								end)
						end

						local ref = menu.action(header_root, v, {}, '', cb)
						menu.on_focus(ref, function()
								if bools['preview'] then
										cb()
								end
						end)
						menu.on_blur(ref, function()
								if bools['preview'] then
										clear_headers()
										hide_header()
								end
						end)

						::continue::
				end
		end

		local function download_list()
				downloader:download_file('headers.txt', {}, function(body, headers, status_code)
						log('Creating headers cache')

						local file = io.open(dirs['resources'] .. '\\headers.txt', 'wb')
						file:write(body)
						file:close()

						pcall(parse_list, body)
				end, function()
						log('Failed to download headers list.')
				end)
		end

		local file = io.open(dirs['resources'] .. '\\headers.txt', 'r')
		if file ~= nil then
				if update then
						local children = menu.get_children(header_root)
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

				log('Found local header cache')
				parse_list(file:read('*a'))
				file:close()
		else
				download_list()
		end
end

menu.action(header_config, 'Update List', {}, '', function()
		download_headers(true)
end)

local helpers = menu.list(menu.my_root(), 'Helpers', {}, '')
local reset = helpers:list('Reset', {}, '')

helpers:toggle('Debug Logging', {}, '', function(s)
		bools['verbose'] = s
end, false)
helpers:action('Restart Script', {}, '', util.restart_script)
helpers:action('Update Script', {}, '', function()

end)

reset:action('Default Textures and Font', {}, '', function()
		lib:empty_dir(dirs['theme'])
		reload_textures()
		reload_font()
end)
reset:action('Default Headers', {}, '', function()
		clear_headers()
		hide_header()
end)

-- 
if SCRIPT_MANUAL_START or SCRIPT_SILENT_START then
		io.makedirs(dirs['resources'])
		download_themes()
		download_headers()
end

util.keep_running()