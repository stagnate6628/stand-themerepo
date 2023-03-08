-- ProfileHelperLib.lua 
local function handle_ratelimit(status_code)
	if status_code == 403 then
			util.toast('You are currently ratelimited by Github. You can let it expire or a use a vpn.')
			return
	end
end
local function is_404(status_code)
	return status_code == 404
end
-- https://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
local function get_dirname_from_path(path)
	if type(path) ~= 'string' then
			return nil
	end

	return path:match('(.*[/\\])')
end
local function write_file(path, body)
	io.makedirs(get_dirname_from_path(path))

	-- todo: check for size ?

	local file = io.open(path, 'wb')
	file:write(body)
	file:close()
end
local function get_github_auth()
	local file = io.open(filesystem.resources_dir() .. 'ProfileHelper\\.github', 'r')
	local token = file:read('a')
	file:close()

	if type(token) == 'string' and token:startswith('ghp_') and token:len() == 40 then
			return token
	end

	return nil
end

lib = {}

function lib:download_file(url_path, file_path, on_success, on_fail, on_not_found)
	local resp = false

	async_http.init('https://raw.githubusercontent.com', '/stagnate6628/stand-profile-helper/main/' .. url_path,
									function(body, headers, status_code)
			resp = true
			handle_ratelimit(status_code)

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
			resp = true
			pcall(on_fail)
	end)
	local token = get_github_auth()
	if token then
			async_http.add_header('Authorization', 'Bearer ' .. token)
	end

	async_http.dispatch()

	repeat
			util.yield()
	until resp
end

function lib:make_request(url_path, callback)
	local resp = false
	async_http.init('https://api.github.com', '/repos/stagnate6628/stand-profile-helper/contents/' .. url_path,
									function(body, headers, status_code)
			resp = true
			handle_ratelimit(status_code)

			pcall(callback, body, headers, status_code)
	end)

	local token = get_github_auth()
	if token then
			async_http.add_header('Authorization', 'Bearer ' .. token)
	end

	async_http.dispatch()

	repeat
			util.yield()
	until resp
end

function lib:copy_file(from, to)
	io.copyto(from, to)
end

function lib:empty_dir(dir)
	for _, path1 in io.listdir(dir) do
			if io.isfile(path1) then
					io.remove(path1)
			end

			if io.isdir(path1) then
					for _, path2 in io.listdir(path1) do
							io.remove(path2)
					end
			end
	end
end

function lib:get_ext(file_name)
	local split = string.split(file_name, '.')
	return split[#split]
end

function lib:trigger_command(command, args)
local input = command
if args then
		input = command .. ' ' .. args
end

menu.trigger_commands(input)
end

function lib:trigger_command_by_ref(path, args)
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

return lib