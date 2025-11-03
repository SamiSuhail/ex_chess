defmodule ExChessServerTest.Arrange do
  alias ExChessServerTest.Client
  import ExUnit.Assertions

  def server() do
    {:ok, pid} = ExChessServer.start()
    pid
  end

  def connected_client(server_pid, color) do
    {:ok, client_pid} = Client.start_link(server_pid, color)
    :ok = Client.connect(client_pid)
    client_pid
  end

  def subscribe_events(server_pid) do
    :ok = ExChessServer.subscribe_events(server_pid)
    server_pid
  end

  def subscribe_client(client_id) do
    :ok = Client.subscribe(client_id)
    client_id
  end

  def disconnect_client(client_pid) do
    Process.flag(:trap_exit, true)
    Process.exit(client_pid, :kill)
    assert_receive {:EXIT, ^client_pid, _reason}
  end
end

defmodule ExChessServerTest.Assert do
  import ExUnit.Assertions

  def player_connected(color) do
    assert_receive {:player_connected, color}, 100
  end

  def player_disconnected(color) do
    assert_receive {:player_disconnected, color}, 100
  end

  def player_reconnected(color) do
    assert_receive {:player_reconnected, color}, 100
  end

  def subscribed(server_pid, client_pid) do
    %{subscribers: subscribers} = :sys.get_state(server_pid)
    assert client_pid in subscribers
  end

  def not_subscribed(server_pid, client_pid) do
    %{subscribers: subscribers} = :sys.get_state(server_pid)
    assert client_pid not in subscribers
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

  def subscribe(client_pid) do
    GenServer.call(client_pid, :subscribe)
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

  def handle_call(:subscribe, _from, state = %{server: server_pid, color: color}) do
    result = ExChessServer.subscribe_events(server_pid)
    {:reply, result, state}
  end
end
