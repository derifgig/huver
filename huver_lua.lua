local base_path = "/usr/share/nginx/html/files" -- Путь для файлов

-- Функция для получения последних файлов
local function get_recent_files()
	local files = {}
	-- Получаем список файлов из base_path
	for file in io.popen("ls -t " .. base_path):lines() do
		if file:match("(%w+).html$") then
			local file_path = base_path .. "/" .. file
			local file_mod_time = os.date("%Y-%m-%d %H:%M:%S", lfs.attributes(file_path, "modification"))
			table.insert(files, { file = file, time = file_mod_time })
		end
	end

	-- Ограничиваем до 20 последних файлов
	local recent_files = {}
	for i = 1, math.min(20, #files) do
		table.insert(recent_files, files[i])
	end

	return recent_files
end

-- Функция для рендеринга страницы поиска и списка последних файлов
local function render_search_page()
	ngx.say([[
        <link rel="stylesheet" href="/style.css">
        <h2>🔍 Search by ID</h2>
        <form action="/" method="get">
            <input type="text" name="id" placeholder="Enter ID" required>
            <button type="submit">Search</button>
        </form>
        <h3>Last 20 Files:</h3>
        <table>
            <tr>
                <th>File</th>
                <th>Modification Date</th>
            </tr>
    ]])

	local recent_files = get_recent_files()
	for _, file in ipairs(recent_files) do
		-- Получаем только уникальный ID файла
		local file_id = file.file:match("([a-zA-Z0-9_-]+).html$")
		ngx.say("<tr><td><a href='/" .. file_id .. "'>" .. file.file .. "</a></td><td>" .. file.time .. "</td></tr>")
	end

	ngx.say("</table>")
end

-- Основной обработчик запроса
local file_id = ngx.var.file_id

if file_id then
	-- Если передан file_id, показываем файл
	-- Здесь мы убрали фиксированную часть имени файла, ищем только по уникальному ID
	local found_file = nil
	for file in io.popen("ls " .. base_path):lines() do
		if file:match(file_id .. ".html$") then
			found_file = file
			break
		end
	end

	if found_file then
		local file_path = base_path .. "/" .. found_file
		local file = io.open(file_path, "r")

		if file then
			ngx.header.content_type = "text/html; charset=utf-8"
			ngx.say(file:read("*a"))
			file:close()
		else
			ngx.status = ngx.HTTP_NOT_FOUND
			ngx.say("<h1>❌ File not found</h1>")
		end
	else
		ngx.status = ngx.HTTP_NOT_FOUND
		ngx.say("<h1>❌ File not found</h1>")
	end
else
	-- Отображаем страницу поиска
	render_search_page()
end
