local themeRepo_dir = filesystem.resources_dir() .. 'themeRepo themes\\'

local header_file = filesystem.stand_dir() ..'Headers\\Custom Header\\themeRepo.png'

local profile_file = filesystem.stand_dir() ..'Profiles\\themeRepo.txt'

local theme_dir = filesystem.stand_dir() ..'Theme\\'

local my_root = menu.my_root()

if not filesystem.is_dir(themeRepo_dir) then
    filesystem.mkdirs(themeRepo_dir)
end

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
        themeReferences[#themeReferences + 1] = menu.action(root, theme_name, {'loadTheme'.. theme_name}, '', function()
            if not filesystem.is_dir(theme_path) then util.toast('Theme not found.') end

            applyHeader(theme_name)
            applyTheme(theme_name)
            applyProfile(theme_name)
        end)
    end
end

local local_themes_root local_themes_root = menu.list(my_root, 'Local themes', {}, 'Apply themes you have locally.', function()
    for i = 1, #themeReferences do
        menu.delete(themeReferences[i])
        themeReferences[i] = nil
    end
    loadThemes(local_themes_root)
end)

loadThemes(local_themes_root)

local themeRepo_root themeRepo_root = menu.list(my_root, 'Theme Repository', {}, 'Download popular themes from the theme repository to make them available in your local themes.')

local function downloadFile(webPath, dirPath, fileName)
    async_http.init('raw.githubusercontent.com', '/Jerrrry123/ThemeRepo/main/Themes/'.. webPath .. fileName, function(fileContent)
        local f = assert(io.open(dirPath .. fileName, 'wb'))
        f:write(fileContent)
        f:close()
    end, function()
        util.toast('Failed to download.')
    end)
    async_http.dispatch()
end

local function count(str, pattern)
    return select(2, string.gsub(str, pattern, ''))
end

local function downloadTheme(webPath, dirPath)
    if not filesystem.is_dir(dirPath) then
        filesystem.mkdirs(dirPath)
    end

    async_http.init('api.github.com', '/repos/Jerrrry123/ThemeRepo/contents/Themes/'.. string.sub(webPath, 1, #webPath - 1), function(res)
        util.toast(res)
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
    end, function()
        util.toast('Failed to download.')
    end)
    async_http.dispatch()
end

menu.action(themeRepo_root, 'Discord', {}, 'Made by lev', function()
    downloadTheme('Discord/', themeRepo_dir ..'Discord\\')
end)

util.keep_running()