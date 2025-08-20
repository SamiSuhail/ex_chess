defmodule ExChess.Game do
  alias ExChess.Board

  @type t() :: %__MODULE__{
          board: Board.t(),
        }
  @enforce_keys [:board]
  defstruct [:board]
end
