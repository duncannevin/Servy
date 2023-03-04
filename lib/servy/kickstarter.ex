defmodule Servy.Kickstarter do
  use GenServer

  @name :http_server

  def start_link(_arg) do
    IO.puts "Starting the kickstarter..."
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    IO.puts "Starting the HTTP server..."
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts "HttpServer exited (#{inspect reason})"
    server_pid = start_server()
    {:noreply, server_pid}
  end

  def start_server do
    IO.puts "Starting the HTTP server..."
    server_pid = spawn_link(Servy.HttpServer, :start, [8080])
    Process.register(server_pid, @name)
    server_pid
  end

  def get_server, do: Process.whereis(@name)
end
