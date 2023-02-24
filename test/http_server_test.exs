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

    parent = self()

    spawn(fn -> send(parent, HTTPoison.get "http://localhost:8080/wildthings") end)
    spawn(fn -> send(parent, HTTPoison.get "http://localhost:8080/wildthings") end)
    spawn(fn -> send(parent, HTTPoison.get "http://localhost:8080/wildthings") end)

    res1 = receive do {:ok, response} -> {response.status_code, response.body} end
    res2 = receive do {:ok, response} -> {response.status_code, response.body} end
    res3 = receive do {:ok, response} -> {response.status_code, response.body} end

    assert res1 == {200, "Bears, Lions, Tigers"}
    assert res2 == {200, "Bears, Lions, Tigers"}
    assert res3 == {200, "Bears, Lions, Tigers"}
  end
end
