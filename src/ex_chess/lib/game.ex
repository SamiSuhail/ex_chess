defmodule ExChess.Game do
  alias ExChess.{Board, Move}

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

  @spec move(t(), Move.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        _move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    updated_board =
      board
      |> Board.set(to, piece)
      |> Board.unset(from)

    %__MODULE__{game | board: updated_board}
  end
end
