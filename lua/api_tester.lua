-- api_tester.lua

local api = {}

-- Function to send HTTP request
local function send_request(method, url, headers, body)
  local curl_command = string.format(
    "curl -X %s -s -w '\\n%%{http_code}' %s %s '%s'",
    method,
    headers and "-H '" .. table.concat(headers, "' -H '") .. "'" or "",
    body and "-d '" .. body .. "'" or "",
    url
  )

  local handle = io.popen(curl_command)
  local result = handle:read("*a")
  handle:close()

  local response_body, status_code = result:match("(.-)%s(%d+)$")
  return response_body, tonumber(status_code)
end

-- Function to create a new buffer for API testing
function api.create_test_buffer()
  vim.cmd("enew")
  vim.bo.filetype = "api_test"
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.bo.swapfile = false

  -- Set up key mappings
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<leader>r",
    ':lua require("api_tester").send_request()<CR>',
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<leader>c",
    ':lua require("api_tester").clear_response()<CR>',
    { noremap = true, silent = true }
  )

  -- Add initial content
  local lines = {
    "# API Test",
    "Method: GET",
    "URL: https://api.example.com/endpoint",
    "Headers:",
    "  Content-Type: application/json",
    "Body:",
    "{",
    '  "key": "value"',
    "}",
    "---",
    "Response:",
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

-- Function to parse the buffer content
local function parse_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local method, url, headers, body = "", "", {}, ""
  local parsing_headers, parsing_body = false, false

  for _, line in ipairs(lines) do
    if line:match("^Method:") then
      method = line:match("^Method:%s*(.+)")
    elseif line:match("^URL:") then
      url = line:match("^URL:%s*(.+)")
    elseif line:match("^Headers:") then
      parsing_headers = true
    elseif line:match("^Body:") then
      parsing_headers = false
      parsing_body = true
    elseif line:match("^%-%-%-") then
      break
    elseif parsing_headers and line:match("^%s+") then
      table.insert(headers, line:match("^%s*(.+)"))
    elseif parsing_body then
      body = body .. line .. "\n"
    end
  end

  return method, url, headers, body:sub(1, -2) -- Remove trailing newline from body
end

-- Function to send the request and update the buffer with the response
function api.send_request()
  local method, url, headers, body = parse_buffer()
  local response_body, status_code = send_request(method, url, headers, body)

  local response_lines = vim.split(response_body, "\n")
  table.insert(response_lines, 1, string.format("Status Code: %d", status_code))
  table.insert(response_lines, 1, "---")

  local start_line = vim.fn.search("^Response:")
  vim.api.nvim_buf_set_lines(0, start_line, -1, false, response_lines)
end

-- Function to clear the response
function api.clear_response()
  local start_line = vim.fn.search("^Response:")
  vim.api.nvim_buf_set_lines(0, start_line, -1, false, { "Response:" })
end

return api
