defmodule Servy.HttpClient do
  alias Servy.Conv

  def call(conv, host \\ "localhost", port \\ 8080)
  def call(%Conv{} = conv, host, port) do
      host_network = String.to_charlist(host)
      {:ok, sock} = :gen_tcp.connect(host_network, port, [:binary, packet: :raw, active: false])
      :ok = :gen_tcp.send(sock, Conv.to_string(conv) <> "\n")
      {:ok, response} = :gen_tcp.recv(sock, 0)
      :ok = :gen_tcp.close(sock)
      response
  end
end
