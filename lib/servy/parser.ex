defmodule Servy.Parser do
  @moduledoc """
  Parses requests into usable data for Servy.
  """

  def parse(request) do
    request
    |> String.split("\n")
    |> List.first
    |> String.split(" ")
    |> to_conv
    |> add_param_map
  end

  defp to_conv([method, path, _]) do
    %{method: method, path: path, resp_body: "", status: nil, param_map: nil}
  end

  defp add_param_map(conv) do
    destructure([_path, param_string], String.split(conv.path, "?"))

    case param_string do
      nil -> conv
      _ -> %{conv | param_map: extract_params(param_string)}
    end
  end

  defp extract_params(path) do
    path
    |> String.split("&")
    |> Enum.map(fn (param) -> String.split(param, "=") end)
    |> Enum.map(fn ([head|[tail]]) -> {head, tail} end)
    |> Map.new
  end
end
