defmodule Servy.Parser do
  @moduledoc """
  Parses requests into usable data for Servy.
  """

  alias Servy.Conv

  def parse(request) do
    [top, body] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    destructure([_, query_param_string], String.split(path, "?"))

    headers = parse_headers(header_lines)

    %Conv{
      method: method,
      path: path,
      param_map: URI.decode_query(query_param_string || "", %{}),
      body: parse_body(headers["Content-Type"], body),
      headers: headers
    }
  end

  @doc """
  Parses the body for url encoded form data.

  ## Examples
    iex> body = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_body("application/x-www-form-urlencoded", body)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_body("application/x-www-form-urlencoded", "")
    %{}
  """
  def parse_body("application/x-www-form-urlencoded", body) do
    body
    |> String.trim
    |> URI.decode_query(%{})
  end

  def parse_body(_, _), do: %{}

  def parse_headers(_header_strings, headers \\ %{})

  def parse_headers([], headers), do: headers

  def parse_headers([header_string | tail], headers) do
    [header_key, header_value] = String.split(header_string, ": ")
    parse_headers(tail, Map.put(headers, header_key, header_value))
  end
end
