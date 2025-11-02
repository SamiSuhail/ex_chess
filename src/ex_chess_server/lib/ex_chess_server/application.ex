defmodule ExChessServer.Application do
  @moduledoc false
  alias ExChessServer.GameSupervisor

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameSupervisor,
    ]

    opts = [strategy: :one_for_one, name: ExChessServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
