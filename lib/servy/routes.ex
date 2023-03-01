defmodule Servy.Routes do
  @moduledoc """
  Handles servy routes.
  """

  import Servy.PageHandler, only: [get_page: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.SnapshotController
  alias Servy.Conv
  alias Servy.BearController

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.body)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
    SnapshotController.snapshots(conv)
  end

  def route(%Conv{method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep

    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/wildthings/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Wildthing #{id}"}
  end

  def route(%Conv{method: "GET", path: "/wildthings?" <> _param_string, param_map: param_map} = conv) when is_map_key(conv.param_map, "id") do
    %{conv | status: 200, resp_body: "Wildthing #{param_map["id"]}"}
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = %{"id" => id}
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears?" <> _param_string, param_map: param_map} = conv) when is_map_key(conv.param_map, "id") do
    BearController.show(conv, param_map)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, %{"id" => id})
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page_name} = conv) do
    get_page(page_name)
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No, #{path} here!"}
  end
end
