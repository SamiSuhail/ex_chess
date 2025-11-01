defmodule ExChessServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_arg) do
    {:ok, ExChess.start_game()}
  end

  @impl true
  def handle_call({:move, move}, _from, game) do
    case ExChess.move(game, move) do
      {:error, _detail} = error ->
        {:reply, error, game}

      {:ok, diff} ->
        updated_game = ExChess.apply(game, diff)
        {:reply, diff, updated_game}
    end
  end

  def child_spec(_init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
    }
  end
end
