defmodule Servy.Handler do
@moduledoc "Handles HTTP requests."

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, apply_emoji: 1]
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
    |> apply_emoji
    |> format_response
  end

  defp format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
