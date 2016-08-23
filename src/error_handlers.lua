local find = string.find
local format = string.format

local TYPE_PLAIN = "text/plain"
local TYPE_JSON = "application/json"
local TYPE_XML = "application/xml"
local TYPE_HTML = "text/html"

local text_template = "%s"
local json_template = '{"message":"%s"}'
local xml_template = '<?xml version="1.0" encoding="UTF-8"?>\n<error><message>%s</message></error>'
local html_template = '<html><head><title>Error</title></head><body><h1>Error</h1><p>%s.</p></body></html>'

local BODIES = {
  s300 = "Multiple Choices",
  s301 = "Moved Permanently",
  s302 = "Found",
  s303 = "See Other",
  s304 = "Not Modified",
  s305 = "Use Proxy",
  s306 = "Switch Proxy",
  s307 = "Temporary Redirect",
  s308 = "Permanent Redirect",
  s400 = "Bad Request",
  s401 = "Unauthorized",
  s402 = "Payment Required",
  s403 = "Forbidden",
  s404 = "Not Found",
  s405 = "Method Not Allowed",
  s406 = "Not Acceptable",
  s407 = "Proxy Authentication Required",
  s408 = "Request Timeout",
  s409 = "Conflict",
  s410 = "Gone",
  s411 = "Length Required",
  s412 = "Precondition Failed",
  s413 = "Payload Too Large",
  s414 = "URI Too Long",
  s415 = "Unsupported Media Type",
  s416 = "Range Not Satisfiable",
  s417 = "Expectation Failed",
  s418 = "I'm a teapot",
  s421 = "Misdirected Request",
  s422 = "Unprocessable Entity",
  s423 = "Locked",
  s424 = "Failed Dependency",
  s426 = "Upgrade Required",
  s428 = "Precondition Required",
  s429 = "Too Many Requests",
  s431 = "Request Header Fields Too Large",
  s451 = "Unavailable For Legal Reasons",
  s500 = "Internal Server Error",
  s501 = "Not Implemented",
  s502 = "Bad Gateway",
  s503 = "Service Unavailable",
  s504 = "Gateway Timeout",
  s505 = "HTTP Version Not Supported",
  s506 = "Variant Also Negotiates",
  s507 = "Insufficient Storage",
  s508 = "Loop Detected",
  s510 = "Not Extended",
  s511 = "Network Authentication Required",
  default = "%d"
}

local _M = {}

local function parse_accept_header(ngx)
  local accept_header = ngx.req.get_headers()["accept"]
  local template, content_type

  if accept_header == nil then
    template = json_template
    content_type = TYPE_JSON
  elseif find(accept_header, TYPE_HTML, nil, true) then
    template = html_template
    content_type = TYPE_HTML
  elseif find(accept_header, TYPE_PLAIN, nil, true) then
    template = text_template
    content_type = TYPE_PLAIN
  elseif find(accept_header, TYPE_XML, nil, true) then
    template = xml_template
    content_type = TYPE_XML
  else
    template = json_template
    content_type = TYPE_JSON
  end

  return template, content_type
end

local function transform_custom_status_codes(status_code)
  -- Non-standard 4XX HTTP codes will be returned as 400 Bad Request
  if status_code > 451 and status_code < 500 then
    status_code = 400
  end

  return status_code
end

function _M.headers(ngx)
  local _, content_type = parse_accept_header(ngx)
  ngx.status = transform_custom_status_codes(ngx.status)

  ngx.header["Content-Type"] = content_type
  ngx.header["Server"] = nil
end

function _M.body(ngx)
  local message
  local template, _ = parse_accept_header(ngx)
  local status = transform_custom_status_codes(ngx.status)

  message = BODIES["s"..status] and BODIES["s"..status] or format(BODIES.default, status)
  ngx.say(format(template, message))
end

return _M
