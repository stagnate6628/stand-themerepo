local texture_names<const> = {"Disabled", "Edit", "Enabled", "Friends", "Header Loading", "Link", "List", "Search",
                              "Toggle Off Auto", "Toggle Off", "Toggle On Auto", "Toggle On", "User", "Users"}
local tag_names<const> = {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14",
                          "15", "16", "17", "18", "19", "0A", "0B", "0C", "0D", "0E", "0F", "1A", "1B", "1C", "1D",
                          "1E", "1F"}
local tab_names<const> = {"Self", "Vehicle", "Online", "Players", "World", "Game", "Stand"}

local stand_dir = filesystem.stand_dir()
local theme_dir = stand_dir .. "Theme\\"
local header_dir = stand_dir .. "Headers\\Custom Header\\"
local resource_dir = filesystem.resources_dir() .. 'stand-profile-helper\\'

local home = menu.my_root()
local themes = home:list("Themes", {}, "")
local settings = home:list("Settings", {}, "")

local use_default_assets = true
local show_logs = true
settings:toggle("Use Default Assets on Fallback", {},
    "If a theme is missing tags/textures, then automatically download the default Stand assets and use those instead.",
    function(on)
        use_default_assets = on
    end, true)
settings:toggle("Download Status", {}, "Display the download status with toasts", function(on)
    show_logs = on
end, true)
settings:action("Update Themes", {},
    "Updates the list of available themes to download. If there were no changes, then you may need to wait for the API to update or there were truly no changes.",
    function()
        download_themes()
    end)

function hyperlink_option(option, path)
    if not filesystem.is_dir(path) then
        filesystem.mkdir(path)
    end

    settings:hyperlink(option, "file:///" .. path, "Opens the directory shown below")
end

hyperlink_option("Open Themes Folder", theme_dir)
hyperlink_option("Open Profiles Folder", stand_dir .. "Profiles")
hyperlink_option("Open Custom Header Folder", header_dir)
hyperlink_option("Open Lua Scripts Folder", filesystem.scripts_dir())
hyperlink_option("Open Script Resources Folder", resource_dir)

settings:action("Restart Script", {}, "", function()
    util.restart_script()
end)

function download_themes()
    local children = menu.get_children(themes)
    if #children > 0 then
        for k, v in pairs(children) do
            v:delete()
        end
    end

    local downloading = true
    async_http.init('raw.githubusercontent.com', '/stagnate6628/stand-profile-helper/main/credits.txt',
        function(res, _, status_code)
            if res:match('API rate limit exceeded') or status_code ~= 200 then
                util.toast("You are currently ratelimited by Github. You can let it expire or a use a vpn.")
                downloading = false
                return
            end

            local profile = res:split('\n')
            for _, v in pairs(profile) do
                if v == "" then
                    goto continue
                end

                local parts = v:split(';')
                local theme_name = parts[1]
                local theme_author = parts[2] or unknown
                local deps = {}

                if type(parts[3]) == "string" and parts[3]:endswith(".lua") then
                    table.insert(deps, parts[3])
                end

                themes:action(theme_name, {}, "Made by " .. theme_author, function()
                    download_theme(theme_name, deps)
                end)
                ::continue::
            end
            downloading = false
        end, function()
            log("failed to download themes")
            downloading = false
        end)
    async_http.dispatch()

    while downloading do
        util.yield()
    end
end

if SCRIPT_MANUAL_START and not SCRIPT_SILENT_START then
    if not filesystem.exists(resource_dir) then
        filesystem.mkdir(resource_dir)
    end

    util.toast(
        "It is recommended to backup any profiles, textures, and headers before selecting a theme. You have been warned.")
end
download_themes()

function download_file(url_path, file_path)
    local downloading = true
    async_http.init('raw.githubusercontent.com', '/stagnate6628/stand-profile-helper/main/' .. url_path,
        function(body, _, status_code)
            local file = assert(io.open(file_path, 'wb'))
            file:write(body)
            file:close()
            downloading = false
        end, function()
            downloading = false
        end)
    async_http.dispatch()

    while downloading do
        util.yield()
    end
end

function does_remote_file_exist(url_path)
    local downloading = true
    local exists
    async_http.init('raw.githubusercontent.com', '/stagnate6628/stand-profile-helper/main/' .. url_path,
        function(body, headers, status_code)
            if body:match("404: Not Found") or status_code == 404 then
                exists = false
            else
                exists = true
            end
            downloading = false
        end, function()
            exists = false
            downloading = false
        end)
    async_http.dispatch()

    while downloading do
        util.yield()
    end

    return exists
end

function download_theme(theme_name, dependencies)
    filesystem.mkdir(resource_dir .. theme_name)

    local profile_path = get_profile_path_by_name(theme_name)
    local font_path = theme_dir .. "Font.spritefont"

    download_file('Themes/' .. theme_name .. '/' .. theme_name .. '.txt', profile_path)
    if does_profile_exist_by_name(theme_name) then
        log('Downloading profile')
    end

    local font_url_path = 'Themes/Stand/Font.spritefont'
    if does_remote_file_exist('Themes/' .. theme_name .. '/Font.spritefont') then
        font_url_path = 'Themes/' .. theme_name .. '/' .. 'Font.spritefont'
        log('Downloading custom font')
    else
        log('Downloading default font')
    end
    download_file(font_url_path, font_path)

    local footer_url_path = 'Themes/' .. theme_name .. '/Footer.bmp'
    if does_remote_file_exist(footer_url_path) then
        log('Downloading footer')
        download_file(footer_url_path, resource_dir .. theme_name .. '\\Footer.bmp')
    end

    local subheader_exists = false
    local subheader_url_path = 'Themes/' .. theme_name .. '/Subheader.bmp'
    if does_remote_file_exist(subheader_url_path) then
        subheader_exists = true
        log('Downloading subheader')
        download_file(subheader_url_path, resource_dir .. theme_name .. '\\Subheader.bmp')
    end

    local header_url_path = 'Themes/' .. theme_name .. '/Header.bmp'
    local animated_header_url_path = 'Themes/' .. theme_name .. '/Header1.bmp'
    if does_remote_file_exist(header_url_path) then
        log("Using custom header (1)")
        hide_header()
        if not subheader_exists then
            empty_headers_dir()
            download_file(header_url_path, header_dir .. 'Header.bmp')
            custom_header()
        else
            download_file(header_url_path, resource_dir .. theme_name .. '/Header.bmp')
        end
    elseif does_remote_file_exist(animated_header_url_path) then
        log("Using custom header (2)")
        local i = 1
        download_file(animated_header_url_path, resource_dir .. theme_name .. '/Header1.bmp')
        log("Downloading header " .. i)
        i = i + 1

        trigger_command_by_ref("Stand>Settings>Appearance>Header>Header>Be Gone")
        animated_header_url_path = 'Themes/' .. theme_name .. '/Header' .. i .. '.bmp'

        while does_remote_file_exist(animated_header_url_path) do
            log("Downloading header " .. i)
            download_file(animated_header_url_path, resource_dir .. theme_name .. '/Header' .. i .. '.bmp')
            i = i + 1

            animated_header_url_path = 'Themes/' .. theme_name .. '/Header' .. i .. '.bmp'
            util.yield(100)
        end
    else
        local header_url_png_path = 'Themes/' .. theme_name .. '/Header.png'
        if does_remote_file_exist(header_url_png_path) then
            empty_headers_dir()
            log("Using custom header (3)")
            download_file(header_url_png_path, header_dir .. theme_name .. '.png')
            hide_header()
            custom_header()
        else
            empty_headers_dir()
            local exists
            local downloading = true
            async_http.init('https://api.github.com', '/repos/stagnate6628/stand-profile-helper/contents/Themes/' ..
                theme_name .. '/Custom Header', function(body, headers, status_code)
                if body:match("API rate limit exceeded") then
                    util.toast("You are currently ratelimited by Github. You can let it expire or a use a vpn.")
                elseif body:match("404: Not Found") or status_code == 404 then
                    exists = false
                else
                    exists = true

                    local json = require("json")
                    body = json.decode(body)

                    for k, v in pairs(body) do
                        download_file(v.path, header_dir .. v.name)
                        log("Downloading " .. v.name)
                    end
                end
                downloading = false
            end, function()
                exists = false
                downloading = false
            end)
            async_http.dispatch()

            while downloading do
                util.yield()
            end

            hide_header()
            if exists then
                log("Using custom header (4)")
                custom_header()
            else
                log("Not using custom header")
            end
        end
    end

    for i, texture_name in pairs(texture_names) do
        local texture_url_path = 'Themes/' .. theme_name .. '/Theme/' .. texture_name .. '.png'
        if not does_remote_file_exist(texture_url_path) then
            log('Downloading default texture ' .. texture_name)
            texture_url_path = 'Themes/Stand/Theme/' .. texture_name .. '.png'
        else
            log('Downloading custom texture ' .. texture_name)
        end
        download_file(texture_url_path, theme_dir .. texture_name .. '.png')

        util.yield(250)

        i = i + 1
        if i == #texture_names then
            log("Reloading textures (1)")
            trigger_command("reloadtextures")
        end
    end

    for j, tag_name in pairs(tag_names) do
        local tag_url_path = 'Themes/' .. theme_name .. '/Theme/Custom/' .. tag_name .. '.png'
        if not does_remote_file_exist(tag_url_path) then
            log('Downloading default tag ' .. tag_name)
            tag_url_path = 'Themes/Stand/Theme/Custom/' .. tag_name .. '.png'
        else
            log('Downloading custom tag ' .. tag_name)
        end
        download_file(tag_url_path, theme_dir .. "Custom\\" .. tag_name .. '.png')

        util.yield(250)

        j = j + 1
        if j == #tag_names then
            tags_done = true
            log("Reloading textures (2)")
            trigger_command("reloadtextures")
        end
    end

    for k, tab_name in pairs(tab_names) do
        local tab_url_path = 'Themes/' .. theme_name .. '/Theme/Tabs/' .. tab_name .. '.png'
        if not does_remote_file_exist(tab_url_path) then
            log('Downloading default tab ' .. tab_name)
            tab_url_path = 'Themes/Stand/Theme/Tabs/' .. tab_name .. '.png'
        else
            log('Downloading custom tab ' .. tab_name)
        end
        download_file(tab_url_path, theme_dir .. "Tabs\\" .. tab_name .. '.png')

        util.yield(250)

        k = k + 1
        if i == #tab_names then
            tabs_done = true
            log("Reloading textures (3)")
            trigger_command("reloadtextures")
        end
    end

    if filesystem.is_regular_file(font_path) then
        log("Reloading font")
        util.yield(500)
        trigger_command("reloadfont")
    end

    for _, script in pairs(dependencies) do
        local dep_url_path = 'Dependencies/' .. script
        if does_remote_file_exist(dep_url_path) then
            download_file(dep_url_path, filesystem.scripts_dir() .. script)
            log('Downloaded dependency ' .. script)
        end
    end

    load_profile(theme_name)
end

function log(msg)
    if not show_logs then
        return
    end

    util.toast(msg)

    local log_path = resource_dir .. "\\log.txt"
    local log_file = io.open(log_path, "a+")
    log_file:write("[" .. os.date("%c") .. "] " .. msg .. "\n")
    log_file:close()
end

function hide_header()
    trigger_command_by_ref("Stand>Settings>Appearance>Header>Header>Be Gone")
end

function custom_header()
    trigger_command_by_ref("Stand>Settings>Appearance>Header>Header>Custom")
end

function load_profile(profile_name)
    util.yield(500)
    trigger_command_by_ref("Stand>Profiles")
    util.yield(100)
    trigger_command_by_ref("Stand")
    util.yield(100)
    trigger_command_by_ref("Stand>Profiles")
    util.yield(500)
    if not trigger_command_by_ref("Stand>Profiles>" .. profile_name .. ">Active") then
        util.toast("Failed to set " .. profile_name .. " as the active profile. You may need to do this yourself.")
    end
    util.yield(100)
    trigger_command("load" .. string.gsub(profile_name, "%-", ""))
    util.yield(500)
    trigger_command_by_ref("Stand>Lua Scripts")
    util.yield(100)
    trigger_command_by_ref("Stand>Lua Scripts>stand-profile-helper")
    util.yield(100)
    trigger_command("clearstandnotifys")
end

function get_profile_path_by_name(profile_name)
    return stand_dir .. "Profiles\\" .. profile_name .. ".txt"
end

function does_profile_exist_by_name(profile_name)
    local profile_path = get_profile_path_by_name(profile_name)
    return filesystem.exists(profile_path) and filesystem.is_regular_file(profile_path)
end

function empty_headers_dir()
    local files = filesystem.list_files(header_dir)

    for _, path in ipairs(files) do
        if filesystem.is_regular_file(path) then
            io.remove(path)
        end
    end
end

function trigger_command(command, args)
    if args then
        menu.trigger_commands(command .. " " .. args)
        return
    end

    menu.trigger_commands(command)
end

function trigger_command_by_ref(ref)
    local _ref = menu.ref_by_path(ref, 43)
    if not _ref:isValid() then
        return false
    end

    menu.trigger_command(_ref)
    return true
end

util.keep_running()
