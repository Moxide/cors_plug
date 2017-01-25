CorsPlug
========
[![Build Status](https://travis-ci.org/mschae/cors_plug.svg)](https://travis-ci.org/mschae/cors_plug)
[![Hex.pm](https://img.shields.io/hexpm/v/cors_plug.svg)]()
[![Hex.pm](https://img.shields.io/hexpm/l/cors_plug.svg)]()

An [Elixir Plug](http://github.com/elixir-lang/plug) to add [CORS](http://www.w3.org/TR/cors/).

## Usage

1. Add this plug to your `mix.exs` dependencies:

```elixir
def deps do
  # ...
  {:cors_plug, "~> 1.1"},
  #...
end
```

When used together with the awesomeness that's the [Phoenix Framework](http://www.phoenixframework.org/)
please note that putting the CORSPlug in a pipeline won't work as they are only invoked for
matched routes.

I therefore recommend to put it in `lib/your_app/endpoint.ex`:

```elixir
defmodule YourApp.Endpoint do
  use Phoenix.Enpoint, otp_app: :your_app

  # ...
  plug CORSPlug

  plug YourApp.Router
end
```

Alternatively you can add options routes, as suggested by @leighhalliday

```elixir
scope "/api", PhoenixApp do
  pipe_through :api

  resources "/articles", ArticleController
  options   "/articles", ArticleController, :options
  options   "/articles/:id", ArticleController, :options
end
```

## Configuration

This plug will return the following headers:

On preflight (`OPTIONS`) requests:

* Access-Control-Allow-Origin
* Access-Control-Allow-Credentials
* Access-Control-Max-Age
* Access-Control-Allow-Headers
* Access-Control-Allow-Methods

On `GET`, `POST`, ... requests:

* Access-Control-Allow-Origin
* Access-Control-Expose-Headers
* Access-Control-Allow-Credentials

```cors_plug``` may be customized in your configuration files (```config.exs```, ```dev.exs```, ...etc.).

For instance (**these are the default values**) :

```elixir
config :cors_plug, :options,
  origin:      "*",
  credentials: true,
  max_age:     1728000,
  headers:     ["Authorization", "Content-Type", "Accept", "Origin",
                "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken",
                "Keep-Alive", "X-Requested-With", "If-Modified-Since",
                "X-CSRF-Token"],
  expose:      [],
  methods:     ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
```

You can configure allowed origins as follows:

```elixir
config :cors_plug, :options,
  origin:      ["http://example1.com", "http://example2.com"]
```

Alternatively, you can use a regex:

```elixir
config :cors_plug, :options,
  origin:      ~r/https?.*example\d?\.com$/
```

## License

Copyright 2014 Michael Schaefermeyer

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
