-- sph-downloader.lua
local function handle_ratelimit(status_code)
		if status_code == 403 then
				util.toast('You are currently ratelimited by Github. You can let it expire or a use a vpn.')
				util.stop_script()
		end
end
local function is_404(status_code)
		return status_code == 404
end
local function write_file(path, body)
		-- io.makedirs(get_dirname_from_path(path))
		local file = io.open(path, 'wb')
		file:write(body)
		file:close()
end
-- https://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
local function get_dirname_from_path(path)
		if type(path) ~= 'string' then
				return nil
		end

		return path:match('(.*[/\\])')
end

downloader = {}

function downloader:download_file(url_path, file_path, on_success, on_fail, on_not_found)
		local downloading = true

		async_http.init('https://raw.githubusercontent.com', '/stagnate6628/stand-profile-helper/main/' .. url_path,
		                function(body, headers, status_code)
				handle_ratelimit(status_code)
				downloading = false

				if is_404(status_code) then
						pcall(on_not_found)
						return
				end

				if type(file_path) == 'string' then
						file_path = {file_path}
				end

				if type(file_path) == 'table' and #file_path > 0 then
						for _, path in file_path do
								pcall(write_file, path, body)
								pcall(on_success, body, headers, status_code)
						end
				else
						pcall(on_success, body, headers, status_code)
				end
		end, function()
				downloading = false
				pcall(on_fail)
		end)
		async_http.dispatch()

		while downloading do
				util.yield()
		end
end

function downloader:download_directory(url_path, dump_directory)
		io.makedirs(get_dirname_from_path(dump_directory))

		local downloading = true
		local exists
		async_http.init('https://api.github.com', '/repos/stagnate6628/stand-profile-helper/contents/' .. url_path,
		                function(body, headers, status_code)
				handle_ratelimit(status_code)
				downloading = false

				if is_404(status_code) then
						return
				end

				exists = true
				success, body = pcall(soup.json.decode, body)

				for _, v in body do
						downloader:download_file(v.path, dump_directory .. '\\' .. v.name)
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

function downloader:copy_file(from, to)
		io.copyto(from, to)
end

return downloader
