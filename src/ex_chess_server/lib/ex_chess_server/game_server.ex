defmodule ExChessServer.GameServer do
  use GenServer

  def start_link(init_state \\ nil) do
    GenServer.start_link(__MODULE__, init_state)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state || ExChess.start_game()}
  end

  def child_spec(init_state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_state]},
    }
  end
end
