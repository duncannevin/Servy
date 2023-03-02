defmodule Servy.GenericServerHandRolled do

  def start(callback_module, initial_state, name) do

    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    IO.puts "\nWaiting for a message..."

    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        new_state = callback_module.handle_info(unexpected, state)
        listen_loop(new_state, callback_module)
    end
  end
end

defmodule Servy.PledgeServerHandRolled do

  alias Servy.GenericServerHandRolled

  @name :hand_rolled_pledge_server

  #Client interface functions
  def start do
    IO.puts "Starting the pledge server"
    GenericServerHandRolled.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amt) do
    GenericServerHandRolled.call @name, {:create_pledge, name, amt}
  end

  def recent_pledges do
    GenericServerHandRolled.call @name, :recent_pledges
  end

  def total_pledged do
    GenericServerHandRolled.call @name, :total_pledged
  end

  def clear do
    GenericServerHandRolled.cast @name, :clear
  end

  # Server callbacks

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    {Enum.map(state, & elem(&1, 1)) |> Enum.sum, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amt}, state) do
    {:ok, id} = send_pledge_to_service(name, amt)
    IO.puts "#{name} pledged #{amt}"
    new_state = [{name, amt} | state] |> Enum.take(3)
    {id, new_state}
  end

  def handle_info(message, state) do
    IO.puts "Can't touch this hand rolled thing! #{inspect message}"
    state
  end

  defp send_pledge_to_service(_name, _amt) do
    # CODE HERE SENDS THE PLEDGE TO AN EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
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
