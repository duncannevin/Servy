defmodule HttpServerTest do
  alias Servy.HttpServer
  use ExUnit.Case

  import Servy.HttpServer

  test "accepts a requests on port 8080" do
    spawn(HttpServer, :start, [8080])

    {:ok, response} = HTTPoison.get "http://localhost:8080/wildthings"

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end

  test "accepts multiple request on port 8080" do
    spawn(HttpServer, :start, [8080])

    values = [
      "http://localhost:8080/bears",
      "http://localhost:8080/bears/1",
      "http://localhost:8080/bears?id=2"
    ]
    |> Enum.map(& Task.async(HTTPoison, :get, [&1]))
    |> Enum.map(& Task.await(&1))
    |> Enum.map(fn ({:ok, result}) -> {Map.get(result, "status_code"), Map.get(result, "body")} end)

    bears_html = """
    <h1>AllTheBears!</h1>
    <ul>
      <li>Smokey-Black</li>
      <li>Paddington-Brown</li>
      <li>Snow-Polar</li>
      <li>Brutus-Grizzly</li>
      <li>Roscoe-Panda</li>
      <li>Kenai-Grizzly</li>
      <li>Teddy-Brown</li>
      <li>Scarface-Grizzly</li>
      <li>Rosie-Black</li>
      <li>Iceman-Polar</li>
    </ul>
    """

    bear_html1 = """
    <h1>Show Bear</h1>
    <p>
    Teddy is hibernating.
    </p>
    """

    bear_html2 = """
    <h1>Show Bear</h1>
    <p>
    Smokey is not hibernating.
    </p>
    """

    values == [
      {200, bears_html},
      {200, bear_html1},
      {200, bear_html2}
    ]
  end
end
