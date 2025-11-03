defmodule ExChessServer do
  alias ExChess.Piece
  alias ExChessServer.{GameSupervisor, GameServer}

  @spec start() :: {:ok, pid()}
  def start() do
    GameSupervisor.start_child()
  end

  @spec connect(pid(), Piece.color()) :: :ok
  def connect(server_pid, color) do
    GameServer.connect(server_pid, color)
  end

  @spec subscribe_events(pid()) :: :ok
  def subscribe_events(server_pid) do
    GameServer.subscribe(server_pid)
  end
end
