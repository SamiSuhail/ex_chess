defmodule ExChess.Game do
  alias ExChess.Board

  @type t() :: %__MODULE__{
          board: Board.t(),
        }
  @enforce_keys [:board]
  defstruct [:board]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      board: Board.new(),
    }
end
