defmodule ExChess.Game do
  alias ExChess.{Board, Move, Piece}

  @type error() :: {:error, :invalid_move}
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

  @spec move(t(), Move.t()) :: t() | error()
  def move(
        game = %__MODULE__{board: board},
        move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    if valid_move?(piece, move) do
      updated_board =
        board
        |> Board.set(to, piece)
        |> Board.unset(from)

      %__MODULE__{game | board: updated_board}
    else
      {:error, :invalid_move}
    end
  end

  defp valid_move?(%Piece{type: piece_type}, move = %Move{}) do
    patterns(piece_type)
    |> valid_move_pattern?(move)
  end

  @king_patterns [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1},
  ]

  @knight_patterns [
    {-2, -1},
    {-2, 1},
    {-1, -2},
    {-1, 2},
    {1, -2},
    {1, 2},
    {2, -1},
    {2, 1},
  ]

  defp patterns(:k), do: @king_patterns
  defp patterns(:n), do: @knight_patterns

  defp valid_move_pattern?(patterns, %Move{from: from, to: to}) do
    patterns
    |> Enum.any?(fn {file_shift, rank_shift} ->
      from.file + file_shift == to.file and
        from.rank + rank_shift == to.rank
    end)
  end
end
