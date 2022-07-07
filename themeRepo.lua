util.require_natives(1651208000)

local themeRepo_dir = filesystem.resources_dir() ..'themeRepo themes\\'

if not filesystem.is_dir(themeRepo_dir) then
    filesystem.mkdirs(themeRepo_dir)
end

local preview_dir = themeRepo_dir ..'Previews\\'

if not filesystem.is_dir(preview_dir) then
    filesystem.mkdirs(preview_dir)
end

local header_file = filesystem.stand_dir() ..'Headers\\Custom Header\\themeRepo.png'

local profile_file = filesystem.stand_dir() ..'Profiles\\themeRepo.txt'

local theme_dir = filesystem.stand_dir() ..'Theme\\'

local my_root = menu.my_root()



local function getFileName(fullPath, removePath, file_type)
    local path = string.sub(fullPath, #removePath + 1)
    return string.gsub(path, '.'.. file_type, '')
end

local function overWriteImage(oldImage, newImage)
    local stand_header = assert(io.open(oldImage, 'wb'))
    local theme_header = assert(io.open(newImage, 'rb'))

    local content = theme_header:read("*a")

    stand_header:write(content)

    stand_header:close()
    theme_header:close()
end

local header_hide_command = menu.ref_by_path('Stand>Settings>Appearance>Header>Header>Be Gone', 37)
local header_custom_command = menu.ref_by_path('Stand>Settings>Appearance>Header>Header>Custom', 37)
local function applyHeader(name)
    overWriteImage(header_file, themeRepo_dir .. name ..'\\'.. name ..'.png')

    menu.trigger_command(header_hide_command)
    menu.trigger_command(header_custom_command)
end

local reload_textures_command = menu.ref_by_path('Stand>Settings>Appearance>Textures>Reload Textures', 37)
local function applyTheme(name)
    local theme_theme_dir = themeRepo_dir .. name ..'\\Theme\\'

    local theme_files = filesystem.list_files(theme_theme_dir)
    for _, file in pairs(theme_files) do
        if filesystem.is_regular_file(file) and file:lower():find('.png') then
            overWriteImage(theme_dir .. string.gsub(file, theme_theme_dir, ''), file)
        end
    end

    local custom_dir = theme_theme_dir ..'Custom\\'
    local custom_files = filesystem.list_files(custom_dir)
    for _, file in pairs(custom_files) do
        if filesystem.is_regular_file(file) and file:lower():find('.png') then
            overWriteImage(theme_dir ..'Custom\\'.. string.gsub(file, custom_dir, ''), file)
        end
    end

    local tabs_dir = theme_theme_dir ..'Tabs\\'
    local tabs_files = filesystem.list_files(tabs_dir)
    for _, file in pairs(tabs_files) do
        if filesystem.is_regular_file(file) and file:lower():find('.png') then
            overWriteImage(theme_dir ..'Tabs\\'.. string.gsub(file, tabs_dir, ''), file)
        end
    end
    menu.trigger_command(reload_textures_command)
end

local active_profile_command = menu.ref_by_path('Stand>Profiles>themeRepo>Active', 37)
local load_profile_command = menu.ref_by_path('Stand>Profiles>themeRepo>Load', 37)
function applyProfile(name)
    local stand_profile = assert(io.open(profile_file, 'wb'))
    local theme_profile = assert(io.open(themeRepo_dir .. name ..'\\'.. name ..'.txt', 'rb'))

    local content = theme_profile:read("*a")

    stand_profile:write(content)

    stand_profile:close()
    theme_profile:close()

    menu.trigger_command(active_profile_command)
    menu.trigger_command(load_profile_command)
end

local themeReferences = {}
local function loadThemes(root)
    local themes = filesystem.list_files(themeRepo_dir)
    for _, theme_path in pairs(themes) do
        local theme_name = getFileName(theme_path, themeRepo_dir, 'lua')
        if theme_name == 'Previews' then
            goto continue
        end
        themeReferences[#themeReferences + 1] = menu.action(root, theme_name, {'loadTheme'.. theme_name}, '', function()
            if not filesystem.is_dir(theme_path) then util.toast('Theme not found.') end

            for _, file in pairs(filesystem.list_files(theme_path)) do
                if file:lower():match('.png') then
                    applyHeader(theme_name)
                end
                if file:lower():match('theme') then
                    applyTheme(theme_name)
                    util.yield(100)
                end
                if file:lower():match('.txt') then
                    applyProfile(theme_name)
                end

                if file:lower():match('.otf') or file:lower():match('.ttf') or file:lower():match('.fnt') then
                    util.toast('This theme has a custom font you can apply.')
                end
            end
        end)
        ::continue::
    end
end

local local_themes_root local_themes_root = menu.list(my_root, 'Local themes', {}, 'Apply themes you have locally.', function()
    for i = 1, #themeReferences do
        menu.delete(themeReferences[i])
        themeReferences[i] = nil
    end
    loadThemes(local_themes_root)
    util.toast('These options will overwrite your current header and theme icons so if you care about those you should make a backup before touching any options here.')
end)

loadThemes(local_themes_root)

local themeRepo_root

local function downloadFile(webPath, dirPath, fileName)
    local downloading = true
    async_http.init('raw.githubusercontent.com', '/Jerrrry123/ThemeRepo/main/'.. webPath .. fileName, function(fileContent)
        local f = assert(io.open(dirPath .. fileName, 'wb'))
        f:write(fileContent)
        f:close()
        downloading = false
    end, function()
        util.toast('Failed to download.')
        downloading = false
    end)
    async_http.dispatch()
    while downloading do util.yield() end
end

local function count(str, pattern)
    return select(2, string.gsub(str, pattern, ''))
end

local function startBusySpinner(message)
    HUD.BEGIN_TEXT_COMMAND_BUSYSPINNER_ON("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)
    HUD.END_TEXT_COMMAND_BUSYSPINNER_ON(5)
end

local function downloadTheme(webPath, dirPath)
    startBusySpinner('Downloading Theme')
    if not filesystem.is_dir(dirPath) then
        filesystem.mkdirs(dirPath)
    end

    if not filesystem.exists(filesystem.scripts_dir() ..'Pulsive.lua') and webPath:match('Pulsive') then
        downloadFile(filesystem.scripts_dir(), 'Dependencies/' ,'Pulsive.lua')
    end

    async_http.init('api.github.com', '/repos/Jerrrry123/ThemeRepo/contents/Themes/'.. string.sub(webPath, 1, #webPath - 1), function(res)
        if res:match('API rate limit exceeded') then
            util.toast('You have been ratelimited by Githubs API, but you can use a vpn to circumvent this.')
            HUD.BUSYSPINNER_OFF()
            return
        end

        for match in string.gmatch(res, '"name":".-",') do
            fileName = match:sub(9, #match - 2)
            if count(fileName, '%.') > 0 then
                downloadFile(webPath, dirPath, fileName)
            else
                local new_dirPath = dirPath .. fileName ..'\\'
                local new_webPath = webPath .. fileName ..'/'
                downloadTheme(new_webPath, new_dirPath)
            end
        end
        HUD.BUSYSPINNER_OFF()
    end, function()
        util.toast('Failed to download.')
        HUD.BUSYSPINNER_OFF()
    end)
    async_http.dispatch()
end

local theme_options = {}

local justPressed = {}
function is_key_just_down(keyCode)
    local isDown = util.is_key_down(keyCode)

    if isDown and not justPressed[keyCode] then
        justPressed[keyCode] = true
        return true
    elseif not isDown then
        justPressed[keyCode] = false
    end
    return false
end

local preview_on = false
local preview_toggle = false
local white = {r = 1, g = 1, b = 1, a = 1}
themeRepo_root = menu.list(my_root, 'Theme Repository', {}, 'Download popular themes from the theme repository to make them available in your local themes.', function()
    util.toast('Press shift to toggle the theme preview.')
    preview_on = true
    util.create_tick_handler(function()
        if is_key_just_down(0x10) then
            preview_toggle = not preview_toggle
        end
        if preview_toggle and preview_on then
            local index = tonumber(menu.get_active_list_cursor_text(true, false):sub(1, 1))
            if theme_options[index] == nil then return true end
            local name = menu.get_menu_name(theme_options[index])
            if theme_options[index + 1000] == nil then
                local preview_file = name ..'.PNG'
                local preview_path = preview_dir.. preview_file
                if not filesystem.exists(preview_path) then
                    downloadFile(preview_path, 'Previews/', preview_file)
                end
                theme_options[index + 1000] = directx.create_texture(preview_path)
            end

            directx.draw_texture(theme_options[index + 1000], 0.15, 0.15, 0.5, 0.5, 0.5, 0.2, 0, white)
        end
        return preview_on
    end)
end, function()
    preview_on = false
end)

local function parseMyRes(res)
    local parsed = {}

    repeat
        local i = res:find(';')
        local j = res:find('\n')
        if j == nil then
            j = #res
        end

        parsed[res:sub(0, i -1)] = res:sub(i + 1, j -1)
        res = res:sub(j + 1, #res)
    until res:find('\n') == nil

    local i = res:find(';')
    parsed[res:sub(0, i -1)] = res:sub(i + 1, #res)

    return parsed
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function()
      i += 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

async_http.init('raw.githubusercontent.com', '/Jerrrry123/ThemeRepo/main/credits.txt', function(res)
    if res:match('API rate limit exceeded') then
        util.toast('You have been ratelimited by Githubs API, but you can use a vpn to circumvent this.')
        return
    end

    local parsed = parseMyRes(res)

    for name, description in pairsByKeys(parsed) do
        theme_options[#theme_options + 1] = menu.action(themeRepo_root, name, {}, description, function()
            downloadTheme('Theme/'.. name ..'/', themeRepo_dir .. name ..'\\')
        end)
    end
end, function()
    util.toast('Failed to download.')
end)
async_http.dispatch()

util.keep_running()