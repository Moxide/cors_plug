defmodule CORSPlug do
  import Plug.Conn

  def defaults do
    [
      origin:      "*",
      credentials: true,
      max_age:     "1728000",
      headers:     ["Authorization", "Content-Type", "Accept", "Origin",
                    "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken",
                    "Keep-Alive", "X-Requested-With", "If-Modified-Since",
                    "X-CSRF-Token"],
      expose:      [],
      methods:     ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    ]
  end

  def init(_options) do
    defaults() |> Keyword.merge(Application.get_env(:cors_plug, :options))
  end

  defp get_origin({:system, var}), do: System.get_env(var)
  defp get_origin(regexp), do: regexp

  defp get_max_age({:system, var}), do: System.get_env(var)
  defp get_max_age(age) when is_integer(age), do: Integer.to_string(age)
  defp get_max_age(age), do: age

  def call(conn, options) do
    conn = put_in(conn.resp_headers, conn.resp_headers ++ headers(conn, options))
    case conn.method do
      "OPTIONS" -> conn |> send_resp(204, "") |> halt
      _method   -> conn
    end
  end

  # headers specific to OPTIONS request
  defp headers(conn = %Plug.Conn{method: "OPTIONS"}, options) do
    headers(%{conn | method: nil}, options) ++ [
      {"access-control-max-age", get_max_age(options[:max_age]) },
      {"access-control-allow-headers", allowed_headers(options[:headers], conn)},
      {"access-control-allow-methods", Enum.join(options[:methods], ",")}
    ]
  end

  # universal headers
  defp headers(conn, options) do
    [
      {"access-control-allow-origin", origin(options[:origin], conn)},
      {"access-control-expose-headers", Enum.join(options[:expose], ",")},
      {"access-control-allow-credentials", "#{options[:credentials]}"}
    ]
  end

  # Allow all requested headers
  defp allowed_headers(["*"], conn) do
    get_req_header(conn, "access-control-request-headers")
    |> List.first
  end

  defp allowed_headers(key, _conn) do
    Enum.join(key, ",")
  end

  # normalize non-list to list
  defp origin(key, conn) when not is_list(key) do
    origin(List.wrap(key), conn)
  end

  # return "*" if origin list is ["*"]
  defp origin(["*"], _conn) do
    "*"
  end

  # return request origin if in origin list, otherwise "null" string
  # see: https://www.w3.org/TR/cors/#access-control-allow-origin-response-header
  defp origin(origins, conn) when is_list(origins) do
    req_origin = get_req_header(conn, "origin") |> List.first
    case check_origin(origins, req_origin) do
      {:error, :not_found} -> "null"
      valid_origin         -> valid_origin
    end
  end

  defp check_origin(_, req_origin) when is_nil(req_origin), do: {:error, :not_found}
  defp check_origin([], _req_origin), do: {:error, :not_found}
  defp check_origin([raw_origin|tail], req_origin) do
     {:ok, r} = raw_origin
     |> get_origin
     |> Regex.compile
     if Regex.match?(r, req_origin) do
       req_origin
     else
       check_origin(tail, req_origin)
     end
  end
end
