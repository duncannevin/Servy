defmodule Servy.Routes do
  @moduledoc """
  Handles servy routes.
  """

  import Servy.PageHandler, only: [get_page: 1]
  import Servy.FileHandler, only: [handle_file: 2]

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
end
