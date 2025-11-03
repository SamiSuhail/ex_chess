defmodule ExChessServer.GameServer do
  use GenServer

  def child_spec(init_state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_state]},
    }
  end

  def start_link(init_state \\ nil) do
    GenServer.start_link(__MODULE__, init_state)
  end

  def connect(server_pid, color) do
    GenServer.call(server_pid, {:connect, color})
  end

  def subscribe(server_pid) do
    GenServer.call(server_pid, :subscribe)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state || %{game: ExChess.start_game(), subscribers: []}}
  end

  @impl true
  def handle_call({:connect, color}, {player_pid, _}, state = %{}) do
    Process.monitor(player_pid)
    updated_state = Map.put(state, player_pid, color)
    publish_event({:player_connected, color})
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(:subscribe, {subscriber_pid, _}, state = %{subscribers: subscriber_pids}) do
    updated_state = Map.put(state, :subscribers, [subscriber_pid | subscriber_pids])
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_info(
        {:publish_event, event},
        state = %{subscribers: subscribers}
      ) do
    for subscriber <- subscribers do
      send(subscriber, event)
    end

    {:noreply, state}
  end

  def handle_info(
        {:DOWN, _ref, :process, client_pid, _reason},
        state = %{subscribers: subscribers}
      ) do
    updated_subscribers = subscribers |> Enum.filter(fn pid -> pid != client_pid end)
    updated_state = Map.put(state, :subscribers, updated_subscribers)
    color = Map.get(state, client_pid)
    publish_event({:player_disconnected, color})
    {:noreply, updated_state}
  end

  defp publish_event(event), do: send(self(), {:publish_event, event})
end
