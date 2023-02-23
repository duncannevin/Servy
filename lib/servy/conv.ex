defmodule Servy.Conv do
  defstruct method: "",
  path: "",
  resp_body: "",
  status: nil,
  param_map: %{},
  body: %{},
  headers: %{},
  resp_headers: %{"Content-Type" => "text/html"}

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  def to_string(%Servy.Conv{} = conv) do
    """
    #{conv.method} #{conv.path} HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    #{headers_to_string(conv.headers)}\r
    \r
    #{body_to_string(conv.body)}
    """
  end

  defp body_to_string(body), do: Poison.encode!(body)

  defp headers_to_string(headers) do
    headers
    |> Map.to_list
    |> Enum.map(& "#{elem(&1, 0)}: #{elem(&1, 1)}")
    |> Enum.join("\r\n")
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
