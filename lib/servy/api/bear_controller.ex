defmodule Servy.Api.BearController do

  import Servy.Plugins, only: [put_resp_content_type: 2]
  alias Servy.Conv
  alias Servy.Wildthings

  def index(conv) do
    json = Servy.Wildthings.list_bears()
    |> Poison.encode!

    conv = put_resp_content_type(conv, "application/json")

    %{conv | status: 200, resp_body: json}
  end

  def create(%Conv{body: %{"name" => name, "type" => type}} = conv) do
    bear = Wildthings.create_bear(name, type)

    {_, json} = %{status: "created", msg: "Created a #{bear.type} bear named #{bear.name}"}
    |> Poison.encode

    conv = put_resp_content_type(conv, "application/json")

    %{conv | status: 201, resp_body: json}
  end
end
