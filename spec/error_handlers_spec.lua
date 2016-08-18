local error_handlers = require "../src/error_handlers"
local format = string.format

describe("error handlers", function()
  local whatWasSaid = nil
  local messageFormat = nil
  local statusCodeTests = {}
  statusCodeTests[300] = { 300, "Multiple Choices"}
  statusCodeTests[301] = { 301, "Moved Permanently"}
  statusCodeTests[302] = { 302, "Found"}
  statusCodeTests[303] = { 303, "See Other"}
  statusCodeTests[304] = { 304, "Not Modified"}
  statusCodeTests[305] = { 305, "Use Proxy"}
  statusCodeTests[306] = { 306, "Switch Proxy"}
  statusCodeTests[307] = { 307, "Temporary Redirect"}
  statusCodeTests[308] = { 308, "Permanent Redirect"}
  statusCodeTests[400] = { 400, "Bad Request"}
  statusCodeTests[401] = { 401, "Unauthorized"}
  statusCodeTests[402] = { 402, "Payment Required"}
  statusCodeTests[403] = { 403, "Forbidden"}
  statusCodeTests[404] = { 404, "Not Found"}
  statusCodeTests[405] = { 405, "Method Not Allowed"}
  statusCodeTests[406] = { 406, "Not Acceptable"}
  statusCodeTests[407] = { 407, "Proxy Authentication Required"}
  statusCodeTests[408] = { 408, "Request Timeout"}
  statusCodeTests[409] = { 409, "Conflict"}
  statusCodeTests[410] = { 410, "Gone"}
  statusCodeTests[411] = { 411, "Length Required"}
  statusCodeTests[412] = { 412, "Precondition Failed"}
  statusCodeTests[413] = { 413, "Payload Too Large"}
  statusCodeTests[414] = { 414, "URI Too Long"}
  statusCodeTests[415] = { 415, "Unsupported Media Type"}
  statusCodeTests[416] = { 416, "Range Not Satisfiable"}
  statusCodeTests[417] = { 417, "Expectation Failed"}
  statusCodeTests[418] = { 418, "I'm a teapot"}
  statusCodeTests[421] = { 421, "Misdirected Request"}
  statusCodeTests[422] = { 422, "Unprocessable Entity"}
  statusCodeTests[423] = { 423, "Locked"}
  statusCodeTests[424] = { 424, "Failed Dependency"}
  statusCodeTests[426] = { 426, "Upgrade Required"}
  statusCodeTests[428] = { 428, "Precondition Required"}
  statusCodeTests[429] = { 429, "Too Many Requests"}
  statusCodeTests[431] = { 431, "Request Header Fields Too Large"}
  statusCodeTests[451] = { 451, "Unavailable For Legal Reasons"}
  statusCodeTests[500] = { 500, "Internal Server Error"}
  statusCodeTests[501] = { 501, "Not Implemented"}
  statusCodeTests[502] = { 502, "Bad Gateway"}
  statusCodeTests[503] = { 503, "Service Unavailable"}
  statusCodeTests[504] = { 504, "Gateway Timeout"}
  statusCodeTests[505] = { 505, "HTTP Version Not Supported"}
  statusCodeTests[506] = { 506, "Variant Also Negotiates"}
  statusCodeTests[507] = { 507, "Insufficient Storage"}
  statusCodeTests[508] = { 508, "Loop Detected"}
  statusCodeTests[510] = { 510, "Not Extended"}
  statusCodeTests[511] = { 511, "Network Authentication Required"}
  statusCodeTests[494] = { 400, "Bad Request"}
  statusCodeTests[495] = { 400, "Bad Request"}
  statusCodeTests[496] = { 400, "Bad Request"}
  statusCodeTests[497] = { 400, "Bad Request"}
  statusCodeTests[1000] = { 1000, "1000"}

  setup(function()
    _G.ngx = {}
    _G.ngx.header = {}
    _G.ngx.req = {}
    _G.ngx.say = function(said)
      whatWasSaid = said
    end
  end)

  describe("text/plain", function()
    setup(function()
      _G.ngx.req.get_headers = function()
        return {
          accept = "text/plain"
        }
      end

      messageFormat = "%s\n"
    end)

    for k, v in pairs( statusCodeTests ) do
      it("should return "..k, function()
        _G.ngx.status = k

        error_handlers.headers(_G.ngx)
        error_handlers.body(_G.ngx)
        assert.equal(v[1], _G.ngx.status)
        assert.equal(format(messageFormat, v[2]), whatWasSaid)
      end)
    end
  end)

  describe("application/json", function()
    setup(function()
      _G.ngx.req.get_headers = function()
        return {
          accept = "application/json"
        }
      end

      messageFormat = '{"message":"%s"}\n'
    end)

    for k, v in pairs( statusCodeTests ) do
      it("should return "..k, function()
        _G.ngx.status = k

        error_handlers.headers(_G.ngx)
        error_handlers.body(_G.ngx)
        assert.equal(v[1], _G.ngx.status)
        assert.equal(format(messageFormat, v[2]), whatWasSaid)
      end)
    end
  end)

  describe("application/xml", function()
    setup(function()
      _G.ngx.req.get_headers = function()
        return {
          accept = "application/xml"
        }
      end

      messageFormat = '<?xml version="1.0" encoding="UTF-8"?>\n<error><message>%s</message></error>\n'
    end)

    for k, v in pairs( statusCodeTests ) do
      it("should return "..k, function()
        _G.ngx.status = k

        error_handlers.headers(_G.ngx)
        error_handlers.body(_G.ngx)
        assert.equal(v[1], _G.ngx.status)
        assert.equal(format(messageFormat, v[2]), whatWasSaid)
      end)
    end
  end)

  describe("text/html", function()
    setup(function()
      _G.ngx.req.get_headers = function()
        return {
          accept = "text/html"
        }
      end

      messageFormat = '<html><head><title>Error</title></head><body><h1>Error</h1><p>%s.</p></body></html>\n'
    end)

    for k, v in pairs( statusCodeTests ) do
      it("should return "..k, function()
        _G.ngx.status = k

        error_handlers.headers(_G.ngx)
        error_handlers.body(_G.ngx)
        assert.equal(v[1], _G.ngx.status)
        assert.equal(format(messageFormat, v[2]), whatWasSaid)
      end)
    end
  end)
end)
