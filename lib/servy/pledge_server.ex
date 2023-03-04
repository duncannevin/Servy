defmodule Servy.PledgeServer do

  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct  cache_size: 3, pledges: []
  end

  #Client interface functions
  def start_link(_arg) do
    IO.puts "Starting the pledge server"
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amt) do
    GenServer.call @name, {:create_pledge, name, amt}
  end

  def recent_pledges do
    GenServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenServer.call @name, :total_pledged
  end

  def clear do
    GenServer.cast @name, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  # Server callbacks

  def init(state) do
    {:ok, %{state | pledges: fetch_recent_pledges_from_service()}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    {:noreply, %{state | cache_size: size}}
  end

  def handle_call(:total_pledged, _from, state) do
    {:reply, Enum.map(state.pledges, & elem(&1, 1)) |> Enum.sum, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amt}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amt)
    IO.puts "#{name} pledged #{amt}"
    new_state = %{state | pledges: [{name, amt} | state.pledges] |> Enum.take(state.cache_size)}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.puts "Can't touch this! #{inspect message}"
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amt) do
    # CODE HERE SENDS THE PLEDGE TO AN EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [{"wilma", 100}, {"fred", 999}]
  end
end

# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start()

# send pid, {:stop, :hammertime}

# IO.inspect PledgeServer.create_pledge "larry", 10
# IO.inspect PledgeServer.create_pledge "moe", 20
# IO.inspect PledgeServer.create_pledge "curly", 30
# IO.inspect PledgeServer.create_pledge "daisy", 40
# IO.inspect PledgeServer.create_pledge "grace", 50

# IO.inspect "total: #{inspect PledgeServer.total_pledged()}"

# IO.puts "recent pledges: #{ inspect PledgeServer.recent_pledges()}"

# IO.inspect Process.info(pid, :messages)
