require Logger

defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> add_param_map
    |> rewrite_path
    |> log
    |> route
    |> track
    |> apply_emoji
    |> format_response
  end

  def add_param_map(conv) do
    destructure([_path, param_string], String.split(conv.path, "?"))

    case param_string do
      nil -> conv
      _ -> %{conv | param_map: extract_params(param_string)}
    end
  end

  def apply_emoji(%{status: 200} = conv) do
    %{conv | resp_body: "\xF0\x9F\x9A\x80 " <> conv.resp_body <> " \xF0\x9F\x9A\x80"}
  end

  def apply_emoji(%{status: 404} = conv) do
    %{conv | resp_body: "\xF0\x9F\x98\xA1 " <> conv.resp_body <> " \xF0\x9F\x98\xA1"}
  end

  def apply_emoji(conv), do: conv

  def track(%{status: status, path: path, param_map: param_map, method: method} = conv) do
    Logger.info "[response] status: #{status} method: #{method}, path: #{path}, param_map: #{param_map_to_string(param_map)}"
    conv
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def log(%{path: path, param_map: param_map, method: method} = conv) do
    Logger.debug "[request] method: #{method}, path: #{path}, param_map: #{param_map_to_string(param_map)}"
    conv
  end

  def parse(request) do
    [method, path, _] = request
    |> String.split("\n")
    |> List.first
    |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil, param_map: nil}
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/wildthings/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Wildthing #{id}"}
  end

  def route(%{method: "GET", path: "/wildthings?" <> _param_string} = conv) when is_map_key(conv.param_map, "id") do
    %{conv | status: 200, resp_body: "Wildthing #{conv.param_map["id"]}"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Black, Grizzly, Brown"}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) when id == "new" do
    get_page("form")
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "GET", path: "/bears?" <> _param_string} = conv) when is_map_key(conv.param_map, "id") do
    %{conv | status: 200, resp_body: "Bear #{conv.param_map["id"]}"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!"}
  end

  def route(%{method: "GET", path: "/pages/" <> page_name} = conv) do
    get_page(page_name)
    |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No, #{path} here!"}
  end

  defp get_page(page_name) do
    Path.expand("../../pages", __DIR__)
      |> Path.join(page_name <> ".html")
      |> File.read
  end

  defp handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  defp handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: reason}
  end

  defp param_map_to_string(param_map) when param_map != nil, do: Enum.map_join(param_map, ", ", fn {key, val} -> ~s{"#{key}", "#{val}"} end)

  defp param_map_to_string(_param_map), do: "nil"

  defp extract_params(path) do
    path
    |> String.split("&")
    |> Enum.map(fn (param) -> String.split(param, "=") end)
    |> Enum.map(fn ([head|[tail]]) -> {head, tail} end)
    |> Map.new
  end

  defp format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end


request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___"
request = """
GET /sasquatch HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___form.html"

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___"

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___"

request = """
GET /bears/123 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___123"

request = """
GET /bears?id=zzzzzzzzzzzzzz HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___456"

request = """
GET /bears?foo=bar&id=11111111111111 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___"

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___8888"

request = """
GET /wildthings/8888 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___098"

request = """
GET /wildthings?foo=bar&id="098" HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
IO.puts "___"

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
