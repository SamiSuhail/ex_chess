defmodule ExChessServerTest.Arrange do
  alias ExChessServerTest.Client

  def server() do
    {:ok, pid} = ExChessServer.start()
    pid
  end

  def connected_client(server_pid, color) do
    {:ok, client_pid} = Client.start_link(server_pid, color)
    :ok = Client.connect(client_pid)
    client_pid
  end
end

defmodule ExChessServerTest.Client do
  use GenServer

  def start_link(server_pid, color) do
    GenServer.start_link(__MODULE__, {server_pid, color})
  end

  def connect(client_pid) do
    GenServer.call(client_pid, :connect)
  end

  @impl true
  def init({server_pid, color}) do
    {:ok, %{server: server_pid, color: color}}
  end

  @impl true
  def handle_call(:connect, _from, state = %{server: server_pid, color: color}) do
    result = ExChessServer.connect(server_pid, color)
    {:reply, result, state}
  end
end
