defmodule ExChessServer.GameSupervisor do
  alias ExChessServer.GameServer
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(init_state \\ nil) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, init_state})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 3, max_seconds: 15)
  end
end
