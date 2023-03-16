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
  silent_updates = true,
  dependencies = {{
    name = 'ProfileHelperLib',
    source_url = 'https://raw.githubusercontent.com/stagnate6628/stand-profile-helper/main/lib/ProfileHelperLib.lua',
    script_relpath = 'lib/ProfileHelperLib.lua',
    verify_file_begins_with = '-- ProfileHelperLib.lua ',
    is_required = true
  }}
}
auto_updater.run_auto_update(auto_update_config)
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
                                           'Header Loading.png', 'Link.png', 'List.png', 'Search.png',
                                           'Toggle Off Auto.png', 'Toggle Off.png', 'Toggle On Auto.png',
                                           'Toggle On.png', 'User.png', 'Users.png'})
local tag_names<const> = table.freeze({'00.png', '01.png', '02.png', '03.png', '04.png', '05.png', '06.png', '07.png',
                                       '08.png', '09.png', '10.png', '11.png', '12.png', '13.png', '14.png', '15.png',
                                       '16.png', '17.png', '18.png', '19.png', '0A.png', '0B.png', '0C.png', '0D.png',
                                       '0E.png', '0F.png', '1A.png', '1B.png', '1C.png', '1D.png', '1E.png', '1F.png'})
local tab_names<const> = table.freeze({'Self.png', 'Vehicle.png', 'Online.png', 'Players.png', 'World.png', 'Game.png',
                                       'Stand.png'})
local file_map<const> = {
  ['Theme'] = texture_names,
  ['Tag'] = tag_names,
  ['Tab'] = tab_names
}

local bools = {
  ['is_downloading'] = false,
  ['prevent_redownloads'] = true,
  ['verbose'] = true,
  ['combine_profiles'] = false
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

  util.toast(prefix .. msg)

  if bools['verbose'] then
    local log_path = dirs['resources'] .. '\\log.txt'
    if not io.exists(log_path) then
      local file = io.open(log_path, 'wb')
      file:close()
    end

    local log_file = io.open(log_path, 'a+')
    log_file:write('[' .. os.date('%x %I:%M:%S %p') .. '] ' .. msg .. '\n')
    log_file:close()
  end
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
  local files = io.listdir(dirs['header'])
  local count = #files

  for k, v in files do
    io.remove(v)
    count = count - 1
    util.yield(5)
  end

  repeat
    util.yield()
  until count == 0
end
local function clean_profile_name(profile_name)
  return profile_name:gsub('%-', ''):gsub('&', ''):gsub(' ', ''):lower()
end
local function get_active_profile_name()
  local meta_state_path = dirs['stand'] .. 'Meta State.txt'
  local file = util.read_colons_and_tabs_file(meta_state_path)

  if file['Active Profile'] then
    return file['Active Profile']
  end

  return 'Main'
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
        local path = k .. '>' .. v
        local ref = menu.ref_by_path(path, 44)
        if not ref:isValid() then
          lib:trigger_command_by_ref(k, v)
        else
          lib:trigger_command_by_ref(path)
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

  lib:empty_dir(dirs['theme'])
  clear_headers()

  local base_path = 'Themes/' .. theme_name
  lib:make_request(base_path, function(body, headers, status_code)
    if status_code == 404 then
      return
    end

    local success, body = pcall(soup.json.decode, body)
    if not success then
      log('Failed to parse json [1]')
    end

    for k, v in body do
      if v.type == 'file' then
        local paths = {dirs['resources'] .. convert_path(v.path, true)}
        if v.name == theme_name .. '.txt' then
          table.insert(paths, dirs['stand'] .. 'Profiles\\' .. v.name)
          if should_copy(paths[1]) then
            lib:copy_file(paths[1], paths[2])
            log('Copied ' .. theme_name .. '.txt')
          else
            lib:download_file(v.path, paths, function()
              log('Downloaded ' .. theme_name .. '.txt')
            end)
          end
        else
          if should_copy(paths[1]) then
            log('Skipped download for ' .. v.name)
          else
            lib:download_file(v.path, paths, function()
              log('Downloaded file ' .. v.name)
            end)
          end
        end
      end
    end
  end)

  local i = 0
  local count = 0
  lib:make_request(base_path .. '/Custom Header', function(body, headers, status_code)
    if status_code == 404 then
      return
    end

    local success, body = pcall(soup.json.decode, body)
    if not success then
      log('Failed to parse json response [2]')
      return
    end

    hide_header()

    count = #body
    for k, v in body do
      local paths = {dirs['resources'] .. convert_path(v.path, true), dirs['header'] .. v.name}
      if should_copy(paths[1]) then
        lib:copy_file(paths[1], paths[2])
        log('Copied header ' .. v.name)
        i = i + 1
      else
        lib:download_file(v.path, paths, function()
          i = i + 1
          log('Downloaded header ' .. v.name .. ' (' .. i .. '/' .. #body .. ')')
        end)
      end
    end
  end)

  repeat
    util.yield(250)
    -- util.log('yield=' .. string.format('%d/%d', i, count))
  until i == count

  for k1, v1 in file_map do
    local i, s = 0, 0
    for k2, v2 in v1 do
      local path = base_path .. '/Theme/'
      local paths = {}

      if k1 == 'Tag' then
        path = path .. 'Custom/'
        table.insert(paths, dirs['theme'] .. 'Custom\\' .. v2)
      elseif k1 == 'Tab' then
        path = path .. 'Tabs/'
        table.insert(paths, dirs['theme'] .. 'Tabs\\' .. v2)
      else
        table.insert(paths, dirs['theme'] .. v2)
      end

      path = path .. v2
      table.insert(paths, dirs['resources'] .. convert_path(path, true))

      if should_copy(paths[2]) then
        lib:copy_file(paths[2], paths[1])
        s = s + 1
      else
        lib:download_file(path, paths, function()
          i = i + 1
        end)
      end
    end
    if i ~= 0 and s ~= 0 then
      util.toast(string.format('%ss: Downloaded %d, copied %d', k1, i, s))
    end
  end

  reload_font()
  reload_textures()

  -- lua scripts=scripts that draw for theme
  lib:make_request(base_path .. '/Lua Scripts', function(body, headers, status_code)
    -- no required luas
    if status_code == 404 then
      return
    end

    local success, body = pcall(soup.json.decode, body)
    if not success then
      log('Failed to parse json response [3]')
    end

    for k, v in body do
      lib:download_file(v.path, filesystem.scripts_dir() .. v.name, function()
        log('Downloaded lua script ' .. v.name)
      end)
    end
  end)

  -- deps=shared scripts that can be used across different profiles
  if #deps > 0 then
    for k, v in deps do
      lib:download_file('Dependencies/' .. v, filesystem.scripts_dir() .. v, function()
        log('Downloaded dependency ' .. v)
      end)
    end
  end

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
      lib:trigger_command_by_ref('Stand>Lua Scripts>ProfileHelper>Themes')
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

      menu.action(header_root, v, {}, '', function(click_type)
        if bools['is_header_downloading'] then
          menu.show_warning(header_root, click_type,
              'A download has already started. You may need to wait for the header to finish downloading. Proceed?',
              function()
                bools['is_header_downloading'] = false
              end)
          return
        end

        bools['is_header_downloading'] = true
        clear_headers()
        lib:make_request('Headers/' .. v, function(body, headers, status_code)
          local success, body = pcall(soup.json.decode, body)
          if not success then
            log('Failed to decode json response [5]')
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
                i = i + 1
              end)
            end
          end

          repeat
            util.yield(250)
          until i == #body

          local ref = menu.ref_by_path('Stand>Settings>Appearance>Header>Header', 44)
          if menu.get_value(ref) == 200 then
            hide_header()
          end
          use_custom_header()

          bools['is_header_downloading'] = false

          if math.random() > 0.5 then
            util.toast('Tip: Make sure to save the current profile to load the Custom Header on start.')
          end
        end)
      end)

      ::continue::
    end
  end

  local function download_list()
    local path = dirs['resources'] .. 'headers.txt'
    lib:download_file('headers.txt', path, function(body, headers, status_code)
      log('Creating headers cache')

      local file = io.open(path, 'wb')
      file:write(body)
      file:close()

      pcall(parse_list, body)
    end, function()
      log('Failed to download headers list')
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
      lib:trigger_command_by_ref('Stand>Lua Scripts>ProfileHelper>Headers')
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
end, true)
helpers:action('Restart Script', {}, '', util.restart_script)
helpers:action('Update Script', {}, '', function()
  util.toast('Checking for updates')
  auto_update_config.check_interval = 0
  auto_updater.run_auto_update(auto_update_config)
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

if SCRIPT_MANUAL_START or SCRIPT_SILENT_START then
  util.toast('[ProfileHelper] Remember to maintain backups of textures as needed.')

  io.makedirs(dirs['resources'])
  io.makedirs(dirs['resources'] .. '\\Themes')
  io.makedirs(dirs['resources'] .. '\\Headers')

  download_themes()
  download_headers()
end

util.keep_running()
