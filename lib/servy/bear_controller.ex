defmodule Servy.BearController do
  @moduledoc """
  Controller for all things bear related.
  """

  import Servy.PageHandler, only: [get_page: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  @templates_path Path.expand("../../templates", __DIR__)

  def index(%Conv{} = conv) do
    bears = Wildthings.list_bears()
    |> Enum.sort(& Bear.order_asc_by_name(&1, &2))

    %{conv | status: 200, resp_body: BearView.index(bears)}
  end

  defp bear_item(%Bear{name: name, type: type}) do
    "<li>#{name} - #{type}</li>"
  end

  def show(%Conv{} = conv, %{"id" => "new"}) do
    get_page("form")
    |> handle_file(conv)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    case bear do
      nil -> %{conv | status: 404, resp_body: "Bear #{id} not found!"}
      _ -> %{conv | status: 200, resp_body: BearView.show(bear)}
    end
  end

  def create(%Conv{body: %{"name" => name, "type" => type}} = conv) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}"}
  end

  def delete(%Conv{} = conv, %{"id" => id}) do
    bears = Wildthings.delete_bear(id)
    |> Enum.sort(& Bear.order_asc_by_name(&1, &2))
    |> Enum.map(& bear_item(&1))
    |> Enum.join

    %{conv | status: 200, resp_body: "<ul>#{bears}</ul>"}
  end

end
