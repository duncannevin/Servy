defmodule Servy.PledgeServer do

  @name :pledge_server

  #Client interface functions

  def start do
    IO.puts "Starting the pledge server"

    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amt) do
    send @name, {self(), :create_pledge, name, amt}

    receive do
      {:response, status} -> status
    end

  end

  def recent_pledges() do
    send @name, {self(), :recent_pledges}

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send @name, {self(), :total_pledged}

    receive do
      {:response, total} -> total
    end
  end

  # Server functions

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {sender, :create_pledge, name, amt} ->
        {:ok, id} = send_pledge_to_service(name, amt)
        IO.puts "#{name} pledged #{amt}"
        new_state = [{name, amt} | state] |> Enum.take(3)
        IO.inspect new_state
        send sender, {:response, id}
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        IO.puts "Sent pledges to: #{inspect sender}"
        send sender, {:response, state}
        listen_loop(state)
      {sender, :total_pledged} ->
        total = Enum.map(state, & elem(&1, 1)) |> Enum.sum
        send sender, {:response, total}
        listen_loop(state)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state)
    end

  end


  defp send_pledge_to_service(_name, _amt) do
    # CODE HERE SENDS THE PLEDGE TO AN EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

PledgeServer.start()

# send pid, {:stop, :hammertime}

# IO.inspect PledgeServer.create_pledge "larry", 10
# IO.inspect PledgeServer.create_pledge "moe", 20
# IO.inspect PledgeServer.create_pledge "curly", 30
# IO.inspect PledgeServer.create_pledge "daisy", 40
# IO.inspect PledgeServer.create_pledge "grace", 50

# IO.inspect "total: #{inspect PledgeServer.total_pledged()}"

# IO.puts "recent pledges: #{ inspect PledgeServer.recent_pledges()}"

# IO.inspect Process.info(pid, :messages)
