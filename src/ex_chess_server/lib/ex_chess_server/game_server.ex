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

  @impl true
  def init(init_state) do
    {:ok, init_state || %{game: ExChess.start_game()}}
  end

  @impl true
  def handle_call({:connect, color}, {player_pid, _}, state = %{}) do
    updated_state = Map.put(state, color, player_pid)
    {:reply, :ok, updated_state}
  end
end
