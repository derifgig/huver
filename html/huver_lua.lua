-- Get base path from environment or default
local base_path = os.getenv("BASE_PATH") or "/data"

-- Helper: log debug
local function debug(msg)
	ngx.log(ngx.DEBUG, msg)
end

-- Helper: render HTML page
local function render_html(title, body)
	ngx.header.content_type = "text/html"
	ngx.say([[
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>]] .. title .. [[</title>
            <link rel="stylesheet" href="/style.css">
            <link rel="icon" href="/favicon.ico" type="image/x-icon">
            <script src="/timestamp.js" defer></script>
        </head>
        <body>
        <h1>]] .. title .. [[</h1>
        ]] .. body .. [[
        </body>
        </html>
    ]])
end

-- Show latest files list
local function show_latest()
	local handle = io.popen("ls -t " .. base_path .. "/*.html")
	local result = handle:read("*a")
	handle:close()

	local rows = {}
	local count = 0

	for file_path in result:gmatch("[^\r\n]+") do
		local attr = io.popen("stat -c '%Y' " .. file_path):read("*a")
		local timestamp = tonumber(attr) or 0

		local file = file_path:match(".*/(.*)")
		local id = file:match("-(%w+).html$")
		local name_only = file:match("^(.-)%.html$") or file

		if id then
			local link = "<span style='opacity:0.6;'>(" .. id .. ")</span>"
			local display_name = name_only:gsub("-%w+$", "") .. " " .. link

			-- ВСТАВКА timestamp в span с data-ts
			local date_html = string.format("<span class='js-timestamp' data-ts='%d'>...</span>", timestamp)

			table.insert(
				rows,
				"<tr><td>" .. date_html .. "</td><td><a href='/" .. id .. "'>" .. display_name .. "</a></td></tr>"
			)

			count = count + 1
			if count >= 50 then
				break
			end
		end
	end

	local body = [[
        <form method="get" action="/">
            <input type="text" name="id" placeholder="Enter ID">
            <input type="submit" value="Search">
        </form>
        <table>
            <thead><tr><th>Time</th><th>File</th></tr></thead>
            <tbody>]] .. table.concat(rows, "\n") .. [[</tbody>
        </table>
    ]]

	render_html("Huver: Latest reports", body)
end

-- Show file by ID
local function show_file(id)
	ngx.log(ngx.DEBUG, "Looking for file with ID: " .. id)

	local handle = io.popen("ls " .. base_path .. "/*" .. id .. ".html")
	local result = handle:read("*a")

	handle:close()

	for file_path in result:gmatch("[^\r\n]+") do
		local file = file_path:match(".*/(.*)")
		local found_id = file:match("-(%w+).html$")
		if found_id == id then
			local f = io.open(file_path, "r")
			if f then
				local content = f:read("*a")
				f:close()

				local body = [[
          <main>]] .. content .. [[
          </main>
          <footer><a href="/">Back to list</a></footer>
          </body>
          </html>
        ]]
				render_html("Report: " .. id, body)
				return
			else
				ngx.log(ngx.ERR, "Failed to open file: " .. file_path)
				render_html(
					"Huver: Failed to open file " .. id,
					"<p>Failed to open file by ID <strong>" .. id .. "</strong>.</p>"
				)
				return
			end
		end
	end
	render_html("Huver: File Not Found" .. id, "<p>No file found with ID <strong>" .. id .. "</strong>.</p>")
end

-- Entry point
local args = ngx.req.get_uri_args()
local id = ngx.var.uri:match("^/(%w+)$")

debug("Request URI: " .. ngx.var.uri)

if ngx.var.uri == "/" then
	if args.id and args.id ~= "" then
		show_file(args.id)
	else
		show_latest()
	end
elseif id then
	show_file(id)
else
	render_html("Huver: Invalid Request", "<p>Invalid URL or parameters.</p>")
end
