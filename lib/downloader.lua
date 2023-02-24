function does_remote_file_exist(url_path)
    local downloading = true
    local exists

    async_http.init("https://raw.githubusercontent.com", "/stagnate6628/stand-profile-helper/main/" .. url_path,
        function(body, headers, status_code)
            downloading = false
            if body == "API rate limit exceeded" or status_code == 429 then
                util.toast(
                    "You are currently being ratelimited by GitHub. You can let the duration expire or a use a vpn.")
                util.stop_script()
            elseif body:match("404: Not Found") or status_code == 404 then
                exists = false
            else
                exists = true
            end
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

function download_file(url_path, file_paths)
    local downloading = true
    local exists

    async_http.init("https://raw.githubusercontent.com", "/stagnate6628/stand-profile-helper/main/" .. url_path,
        function(body, headers, status_code)
            if body == "API rate limit exceeded" or status_code == 429 then
                util.toast(
                    "You are currently being ratelimited by GitHub. You can let the duration expire or a use a vpn.")
                util.stop_script()
            elseif body:match("404: Not Found") or status_code == 404 then
                exists = false
            else
                exists = true
            end

            downloading = false

            if exists and file_paths and type(file_paths) == "table" then
                for _, path in file_paths do
                    io.makedirs(get_dirname_from_path(path))
                    local file = io.open(path, "wb")
                    if file ~= nil then
                        file:write(body)
                        file:close()
                    end
                end
            end
        end, function()
            exists = false
            downloading = false
        end)
    async_http.dispatch()

    while downloading do
        util.yield()
    end
end

function download_directory(url_path, dump_directory)
    io.makedirs(get_dirname_from_path(dump_directory))
    
    local downloading = true
    local exists
    async_http.init("https://api.github.com", "/repos/stagnate6628/stand-profile-helper/contents/" .. url_path,
        function(body, headers, status_code)
            if body == "API rate limit exceeded" or status_code == 429 then
                util.toast("You are currently ratelimited by Github. You can let it expire or a use a vpn.")
                util.stop_script()
            elseif body == "404: Not Found" or status_code == 404 then
                exists = false
            else
                exists = true
                body = soup.json.decode(body)

                for k, v in body do
                    download_file(v.path, {dump_directory .. "\\" .. v.name})
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

    return exists
end

function copy_file(from, to)
    if io.isfile(from) and io.exists(from) then
        io.copyto(from, to)
    end
end

function get_file_name_from_path(path)
    local split = path:split('/')
    local file_name = split[#split]

    if file_name ~= nil and type(file_name) == "string" then
        return file_name
    end

    return nil
end

-- https://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
function get_dirname_from_path(path)
    return path:match("(.*[/\\])")
end