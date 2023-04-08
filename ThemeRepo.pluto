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
  source_url = 'https://raw.githubusercontent.com/stagnate6628/stand-themerepo/main/ThemeRepo.lua',
  script_relpath = SCRIPT_RELPATH,
  verify_file_begins_with = '--',
  check_interval = 86400,
  silent_updates = true,
  dependencies = {{
    name = 'ThemeRepoLib',
    source_url = 'https://raw.githubusercontent.com/stagnate6628/stand-themerepo/main/lib/ThemeRepoLib.lua',
    script_relpath = 'lib/ThemeRepoLib.lua',
    verify_file_begins_with = '-- ThemeRepoLib.lua',
    is_required = true
  }}
}

--auto_updater.run_auto_update(auto_update_config)
--[[for _, dependency in auto_update_config.dependencies do
  if dependency.is_required then
    if dependency.loaded_lib == nil then
      util.toast('Error loading lib ' .. dependency.name, TOAST_ALL)
    else
      local var_name = dependency.name
      _G[var_name] = dependency.loaded_lib
    end
  end
end
]]
require 'lib/ThemeRepoLib'

local io, lib, util = io, lib, util
math.randomseed(util.current_unix_time_seconds()) -- apparently this is good

local tree_version<const> = 45
local path_map<const> = {'Root', 'Theme', 'Tags', 'Tabs', 'Custom Header', 'Lua Scripts'}
local make_dirs<const> = {'Lua Scripts', 'Custom Header', 'Theme\\Custom', 'Theme\\Tabs'}

local bools = {
  ['is_downloading'] = false,
  ['is_header_downloading'] = false,
  ['prevent_redownloads'] = true,
  ['debug'] = true,
  ['combine_profiles'] = false
}

local dirs<const> = {
  ['stand'] = filesystem.stand_dir(),
  ['theme'] = filesystem.stand_dir() .. 'Theme\\',
  ['header'] = filesystem.stand_dir() .. 'Headers\\Custom Header\\',
  ['resources'] = filesystem.resources_dir() .. 'ThemeRepo\\'
}

local root = menu.my_root()
-- headers
local header_root = menu.list(root, 'Headers', {}, '')
local header_config = header_root:list('Configuration', {}, '')
-- themes
local theme_root = menu.list(root, 'Themes', {}, '')
local theme_config = theme_root:list('Configuration', {}, '')

theme_config:toggle('Re-use Local Assets', {}, '', function(s)
  bools['prevent_redownloads'] = s
end, true)
theme_config:toggle('Combine Profiles', {}, '', function(s)
  bools['combine_profiles'] = s
end, false)

local lang_list<const> = { "Chinese (Simplified) - 简体中文", "Dutch - Nederlands", "English (UK)", "English (US)",
  "French - Français", "German - Deutsch", "Korean - 한국어", "Lithuanian - Lietuvių", "Polish - Polski",
  "Portuguese - Português", "Russian - русский", "Spanish - Español", "Turkish - Türkçe", "Horny English",
  "Engwish", "Howny Engwish" }
local lang_map <const> = { 'langzh', 'langnl', 'langenuk', 'langenus', 'langfr', 'langde', 'langko', 'langlt', 'langpl',
  'langpt', 'langru', 'langes', 'langtr', 'langsex', 'languwu', 'langhornyuwu' }
local lang_index = 3 -- english uk

theme_config:list_action('Language', {}, 'Some theme fonts may not support a language.', lang_list, function(index)
  lang_index = index
  util.toast('[ThemeRepo] Profile language set to ' .. lang_list[lang_index])
end)

local function log(msg)
  if not bools['debug'] then
    return
  end

  local log_path = dirs['resources'] .. 'log.txt'
  if not io.exists(log_path) then
    io.open(log_path, 'wb'):close()
  end

  local log_file = io.open(log_path, 'a+')
  log_file:write('[' .. os.date('%x %I:%M:%S %p') .. '] ' .. msg .. '\n')
  log_file:close()
end
local function should_copy(file_path)
  return io.exists(file_path) and io.isfile(file_path) and bools['prevent_redownloads']
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
local function get_active_profile_name()
  local file = util.read_colons_and_tabs_file(dirs['stand'] .. 'Meta State.txt')
  return file['Active Profile'] or 'Main'
end
local function load_profile(profile_name)
  log('Loading ' .. profile_name)

  reload_textures()
  reload_font()

  lib:trigger_command_by_ref('Stand>Profiles')
  util.yield(100)
  lib:trigger_command_by_ref('Stand')
  util.yield(100)
  lib:trigger_command_by_ref('Stand>Profiles')

  lib:trigger_command_by_ref('Stand>Lua Scripts')
  util.yield(100)
  lib:trigger_command_by_ref('Stand')
  util.yield(100)
  lib:trigger_command_by_ref('Stand>Lua Scripts')

  if bools['combine_profiles'] then
    for k, v in util.read_colons_and_tabs_file(
        dirs['resources'] .. 'Themes\\' .. profile_name .. '\\' .. profile_name .. '.txt') do
      if k:startswith('Stand>Settings>Appearance') or k:startswith('Stand>Lua Scripts') or
          k:startswith('Players>Settings>Tags') then
        local ref = menu.ref_by_path(k .. '>' .. v, tree_version)
        if not ref:isValid() then
          lib:trigger_command_by_ref(k, v)
        else
          ref:trigger()
        end
      end
      util.yield()
    end
    if lang_index != 3 then
      lib:trigger_command(lang_map[lang_index])
    end
    lib:trigger_command_by_ref('Stand>Profiles>' .. get_active_profile_name() .. '>Save')
  else
    local ref = menu.ref_by_path('Stand>Profiles>' .. profile_name)
    ref:refByRelPath('Active'):trigger()

    if lang_index != 3 then
      lib:trigger_command(lang_map[lang_index])
      -- todo: remove stand>lua scripts>ThemeRepo if not using default config
      ref:refByRelPath('Save'):trigger()
    end

    ref:refByRelPath('Load'):trigger()
    ref:refByRelPath('Load'):trigger()
  end

  -- this works sometimes :]
  menu.ref_by_path('Self>Movement', tree_version):focus()

  log('Done!')
  util.toast('Done!')
end
local function download_theme(theme_name, deps)
  log('Starting ' .. theme_name)

  for k, v in make_dirs do
    if v == 'Lua Scripts' and #deps == 0 then
      goto continue
    end
    io.makedirs(dirs['resources'] .. 'Themes\\' .. theme_name .. '\\' .. v)
    ::continue::
  end

  lib:empty_dir(dirs['theme'])
  lib:empty_dir(dirs['header'])
  io.makedirs(dirs['theme'] .. 'Custom')
  io.makedirs(dirs['theme'] .. 'Tabs')

  local req_url = {}
  table.insert(req_url, 'Themes/' .. theme_name) -- 1=root
  table.insert(req_url, req_url[1] .. '/Theme') -- 2=theme
  table.insert(req_url, req_url[2] .. '/Custom') -- 3=tag_names
  table.insert(req_url, req_url[2] .. '/Tabs') -- 4=tabs
  table.insert(req_url, req_url[1] .. '/Custom Header') -- 5=custom header
  table.insert(req_url, req_url[1] .. '/Lua Scripts') -- 6=lua scripts

  for k1, v1 in req_url do
    local i = 0
    local j = 0

    lib:make_request(v1, function(body, headers, status_code)
      if status_code == 404 then
        return
      end

      local success, body = pcall(soup.json.decode, body)
      if not success then
        log('Failed to parse json response [' .. k1 .. ']')
        return
      end

      j = #body
      for k2, v2 in body do
        if v2.type == 'dir' then
          j -= 1
          continue
        end

        -- v2.path is nil on ratelimit
        local paths = {dirs['resources'] .. v2.path:gsub('/', '\\')}
        local file_name = v2.name

        log(string.format('Downloading %s at path %s', v2.name, v2.path))

        -- o.o
        if k1 == 1 then -- root
          if lib:get_ext(file_name) == 'txt' and not bools['combine_profiles'] then
            table.insert(paths, dirs['stand'] .. 'Profiles\\' .. file_name)
          end
        elseif k1 == 2 then -- theme
          table.insert(paths, dirs['theme'] .. file_name)
        elseif k1 == 3 then -- custom/tags
          table.insert(paths, dirs['theme'] .. 'Custom\\' .. file_name)
        elseif k1 == 4 then -- tabs
          table.insert(paths, dirs['theme'] .. 'Tabs\\' .. file_name)
        elseif k1 == 5 then -- custom header
          hide_header()
          table.insert(paths, dirs['header'] .. file_name)
        elseif k1 == 6 then -- lua scripts
          table.insert(paths, filesystem.scripts_dir() .. file_name)
        end

        if should_copy(paths[1]) and paths[2] != nil then
          lib:copy_file(paths[1], paths[2])
        else
          lib:download_file(v2.path, paths)
        end
        i += 1
      end
    end)

    repeat
      util.yield(250)
      log(string.format('Waiting at path %s: %d/%d', v1, i, j))
    until i == j

    util.toast(string.format('[ThemeRepo] Finished path %s (%d/6)', path_map[k1], k1))
  end

  load_profile(theme_name)
end
local function empty_list(ref)
  for ref:getChildren() as child do
    if child:getType() == COMMAND_ACTION then
      child:delete()
    end
  end
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

      local action_name = theme_name
			if filesystem.is_dir(dirs['resources'] .. 'Themes\\' .. theme_name) then
        action_name = '[I] ' .. theme_name
      end
      
      theme_root:action(action_name, {}, '', function(click_type)
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

  local path = dirs['resources'] .. 'themes.txt'
  local function download_list()
    lib:download_file('themes.txt', {path}, function(body, headers, status_code)
      log(if not update then 'Creating themes cache' else 'Updating themes cache')
      parse_list(body)
    end)
  end

  local file = io.open(path, 'r')
  if file != nil then
    if update then
      empty_list(theme_root)
      download_list()
      lib:trigger_command_by_ref('Stand>Lua Scripts>ThemeRepo>Themes')
      return
    else
      log('Found local theme list cache')
    end

    parse_list(file:read('*a'))
    file:close()
  else
    download_list()
  end
end
theme_config:action('Update List', {}, '', function()
  download_themes(true)
end)

local function download_headers(update)
  local function parse_list(out)
    local list = out:split('\n')
    for _, v in list do
      if v == '' then
        goto continue
      end
      
      local action_name = v
      if filesystem.is_dir(dirs['resources'] .. 'Headers\\' .. v) then
        action_name = '[I] ' .. v
      end
    
      header_root:action(action_name, {}, '', function(click_type)
        if bools['is_header_downloading'] then
          menu.show_warning(header_root, click_type,
              'A download has already started. You may need to wait for the header to finish downloading. Proceed?',
              function()
                bools['is_header_downloading'] = false
              end)
          return
        end

        bools['is_header_downloading'] = true

        lib:empty_dir(dirs['header'])

        lib:make_request('Headers/' .. v, function(body, headers, status_code)
          local success, body = pcall(soup.json.decode, body)
          if not success then
            log('Failed to parse json response [headers]')
            return
          end

          io.makedirs(dirs['resources'] .. 'Headers\\' .. v .. '\\')

          local i = 0
          for _, v2 in body do
            local paths = {dirs['resources'] .. 'Headers\\' .. v .. '\\' .. v2.name, dirs['header'] .. v2.name}
            if should_copy(paths[1]) then
              lib:copy_file(paths[1], paths[2])
              log(string.format('Copied header %s (%d/%d)', v2.name, i + 1, #body))
            else
              lib:download_file(v2.path, paths, function()
                log(string.format('Downloaded header %s (%d/%d)', v2.name, i + 1, #body))
              end)
            end
            i += 1
          end

          repeat
            util.yield(250)
          until i == #body

          if menu.ref_by_path('Stand>Settings>Appearance>Header>Header', tree_version).value == 200 then
            hide_header()
          end
          use_custom_header()

          bools['is_header_downloading'] = false

          if math.random() > 0.8 then
            util.toast('Tip: Make sure to save the current profile to load the Custom Header on start.')
          end
          log('Done!')
          util.toast('Done!')
        end)
      end)

      ::continue::
    end
  end

  local path = dirs['resources'] .. 'headers.txt'
  local function download_list()
    lib:download_file('headers.txt', {path}, function(body, headers, status_code)
      log(if not update then 'Creating headers cache' else 'Updating headers cache')
      parse_list(body)
    end)
  end

  local file = io.open(path, 'r')
  if file != nil then
    if update then
      empty_list(header_root)
      download_list()
      lib:trigger_command_by_ref('Stand>Lua Scripts>ThemeRepo>Headers')
      return
    else
      log('Found local header list cache')
    end

    parse_list(file:read('*a'))
    file:close()
  else
    download_list()
  end
end
header_config:action('Update List', {}, '', function()
  download_headers(true)
end)

local helpers = menu.list(menu.my_root(), 'Helpers', {}, '')
helpers:list_action('Reset', {}, '', { 'Default textures and font', 'Default headers' }, function(index, menu_name, prev_index, click_type)
	if index == 1 then
		lib:empty_dir(dirs['theme'])
		reload_textures()
		reload_font()
		return
	elseif index == 2 then
		lib:empty_dir(dirs['header'])
  	hide_header()
	end
end)
local shortcuts = helpers:list('Shortcuts', {}, '')
shortcuts:link(menu.ref_by_path('Stand>Profiles'))
shortcuts:link(menu.ref_by_path('Stand>Lua Scripts'))

helpers:toggle('Debug', {}, 'Logs detailed output to a log file and enables the developer preset.', function(s)
  if s then
    lib:trigger_command_by_ref('Stand>Lua Scripts>Settings>Presets>Developer')
  else
    lib:trigger_command_by_ref('Stand>Lua Scripts>Settings>Presets>User')
  end

  bools['debug'] = s
end, false)
helpers:action('Restart Script', {}, '', util.restart_script)
helpers:action('Update Script', {}, '', function()
  auto_update_config.check_interval = 0
  auto_updater.run_auto_update(auto_update_config)
end)

-- not meant to be visible in a public rel
if bools['debug'] then
	local folders = helpers:list('Folders', {}, '')
	folders:action('Stand Folder', {}, '', function()
	  util.open_folder(dirs['stand'])
	end)
	folders:action('Theme Folder', {}, '', function()
	  util.open_folder(dirs['theme'])
	end)
	folders:action('Headers Folder', {}, '', function()
	  util.open_folder(dirs['header'])
	end)
	folders:action('Profiles Folder', {}, '', function()
	  util.open_folder(dirs['stand'] .. 'Profiles')
	end)
	folders:action('Script Resources Folder', {}, '', function()
	  util.open_folder(dirs['resources'])
	end)
end

-- idk if this is even a good method
if math.random() > 0.8 then
  util.toast('[ThemeRepo] Remember to maintain backups of textures as needed.')
end

io.makedirs(dirs['resources'])
io.makedirs(dirs['resources'] .. '\\Themes')
io.makedirs(dirs['resources'] .. '\\Headers')

download_themes()
download_headers()

root:hyperlink('Credits', 'https://github.com/stagnate6628/stand-themerepo/wiki/Credits')

util.keep_running()
