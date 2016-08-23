[![Build Status](https://travis-ci.org/nvmlabs/kong-custom-error-handlers.svg?branch=master)](https://travis-ci.org/nvmlabs/kong-custom-error-handlers)

# kong-custom-error-handler
A module that provides more extensive error handling.

This luarock module is similar in function to the core error handlers in Kong but does not leak any information about the technology stack. It aims to provide a consistent message format for all errors, including custom NGINX errors.

The error handlers support four content types:
- 'application/json' (default)
- 'application/xml'
- 'text/html'
- 'text/plain'

The body does not contain any references to 'upstream servers' and simply contains the HTTP status name.

Custom 4XX HTTP statuses used by NGINX (greater than 451) are returned as 400 Bad Request.

---

## Installation
Clone the repository, navigate to the root folder and run:
```
make install
```

It can be used as a drop-in replacement for the `kong.core.error_handlers`

Edit your ```kong.yaml``` to route the desired HTTP codes to the custom error handlers like so:
```
location / {
  ...
  error_page 305 418 421 494 500 502 504 /custom-error-handlers;
  location = /custom-error-handlers {
    internal;
    header_filter_by_lua_block {
      require("kong.custom.error_handlers").headers(ngx)
    }
    content_by_lua_block {
      require("kong.custom.error_handlers").body(ngx)
    }
  }
}
```

Restart Kong.

## Development
This module requires Lua 5.1 and the associated version of luarocks. Once you have these installed, to get the development dependencies run the following command:

```
make dev
```

