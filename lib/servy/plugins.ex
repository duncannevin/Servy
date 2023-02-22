require Logger

defmodule Servy.Plugins do

  @moduledoc """
  Plugins for Servy.
  """

  alias Servy.Conv

  def apply_emoji(%Conv{status: 200} = conv) do
    %{conv | headers: Map.put(conv.headers, "STATUS_EMOJI", "\xF0\x9F\x9A\x80")}
  end

  def apply_emoji(%Conv{status: 404} = conv) do
    %{conv | headers: Map.put(conv.headers, "STATUS_EMOJI", " \xF0\x9F\x98\xA1")}
  end

  def apply_emoji(%Conv{} = conv), do: conv

  def track(%Conv{status: status, path: path, param_map: param_map, method: method} = conv) do
    if Mix.env != :test do
      Logger.info "[response] status: #{status} method: #{method}, path: #{path}, param_map: #{param_map_to_string(param_map)}"
    end
    conv
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def log(%Conv{path: path, param_map: param_map, method: method} = conv) do
    if Mix.env == :dev do
      Logger.debug "[request] method: #{method}, path: #{path}, param_map: #{param_map_to_string(param_map)}"
    end
    conv
  end

  def param_map_to_string(param_map) when param_map != nil, do: Enum.map_join(param_map, ", ", fn {key, val} -> ~s{"#{key}", "#{val}"} end)

  def param_map_to_string(_param_map), do: "nil"

  def put_resp_content_type(%Conv{resp_headers: resp_headers} = conv, content_type) do
    %{conv | resp_headers: Map.put(resp_headers, "Content-Type", content_type)}
  end

  def put_resp_content_length(%Conv{resp_headers: resp_headers, resp_body: resp_body} = conv) do
    %{conv | resp_headers: Map.put(resp_headers, "Content-Length", Integer.to_string(byte_size(resp_body)))}
  end
end
