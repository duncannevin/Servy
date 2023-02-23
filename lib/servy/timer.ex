defmodule Servy.Timer do
  def remind(time, message) do
    time_in_ms = time * 1000
    spawn(fn () -> :timer.sleep(time_in_ms); IO.puts message end)
  end
end
