defmodule ExChessServer do
  alias ExChessServer.GameSupervisor

  @spec start() :: {:ok, pid()}
  def start() do
    GameSupervisor.start_child()
  end
end
