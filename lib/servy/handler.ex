defmodule Servy.Handler do
@moduledoc "Handles HTTP requests."

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, apply_emoji: 1, put_resp_content_length: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.Routes, only: [route: 1]

  alias Servy.Conv

  @doc "Transforms the request into a resonse."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_resp_content_length
    |> apply_emoji
    |> format_response
  end

  defp format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(%Conv{resp_headers: resp_headers}) do
    (Map.to_list(resp_headers)
    |> Enum.map(fn {key, val} -> "#{key}: #{val}" end)
    |> Enum.join("\r\n")) <> "\r"
  end
end
