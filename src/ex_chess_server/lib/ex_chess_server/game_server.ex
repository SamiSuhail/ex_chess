defmodule ExChessServer.GameServer do
  alias ExChess.{Game, Piece}
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

  def move(server_pid, color, move) do
    GenServer.call(server_pid, {:move, color, move})
  end

  @impl true
  def init(init_state) do
    {:ok, init_state || %{game: ExChess.start_game(), subscribers: []}}
  end

  @impl true
  def handle_call({:connect, color}, {player_pid, _}, state = %{}) do
    Process.monitor(player_pid)

    event_type =
      if Map.get(state, color) do
        :player_reconnected
      else
        :player_connected
      end

    updated_state = Map.put(state, color, player_pid)
    publish_event({event_type, color})
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(:subscribe, {subscriber_pid, _}, state = %{subscribers: subscriber_pids}) do
    updated_state = Map.put(state, :subscribers, [subscriber_pid | subscriber_pids])
    Process.monitor(subscriber_pid)
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(
        {:move, color, move},
        {caller_pid, _},
        state = %{game: game = %Game{active_color: active_color}}
      ) do
    cond do
      color != active_color ->
        {:reply, {:error, :opponent_turn}, state}

      Map.get(state, color) != caller_pid ->
        {:reply, {:error, :player_not_connected}, state}

      not is_pid(Map.get(state, Piece.flip_color(color))) ->
        {:reply, {:error, :waiting_for_opponent}, state}

      true ->
        case ExChess.move(game, move) do
          :error ->
            {:reply, :error, state}

          updated_game ->
            publish_event({:player_move, color})
            updated_state = Map.put(state, :game, updated_game)
            {:reply, :ok, updated_state}
        end
    end
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

  @impl true
  def handle_info(
        {:DOWN, _ref, :process, client_pid, _reason},
        state = %{subscribers: subscribers}
      ) do
    updated_subscribers = subscribers |> Enum.filter(fn pid -> pid != client_pid end)
    updated_state = Map.put(state, :subscribers, updated_subscribers)

    color =
      cond do
        Map.get(state, :white) == client_pid -> :white
        Map.get(state, :black) == client_pid -> :black
        true -> nil
      end

    color && publish_event({:player_disconnected, color})

    {:noreply, updated_state}
  end

  defp publish_event(event), do: send(self(), {:publish_event, event})
end
