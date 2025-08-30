defmodule ExChess.Board do
  alias ExChess.{Square, Piece}
  @type t() :: %{Square.t() => Piece.t()}

  @starting_position [
                       {0, 0, :r, :white},
                       {1, 0, :n, :white},
                       {2, 0, :b, :white},
                       {3, 0, :q, :white},
                       {4, 0, :k, :white},
                       {5, 0, :b, :white},
                       {6, 0, :n, :white},
                       {7, 0, :r, :white},
                       {0, 1, :p, :white},
                       {1, 1, :p, :white},
                       {2, 1, :p, :white},
                       {3, 1, :p, :white},
                       {4, 1, :p, :white},
                       {5, 1, :p, :white},
                       {6, 1, :p, :white},
                       {7, 1, :p, :white},
                       {0, 6, :p, :black},
                       {1, 6, :p, :black},
                       {2, 6, :p, :black},
                       {3, 6, :p, :black},
                       {4, 6, :p, :black},
                       {5, 6, :p, :black},
                       {6, 6, :p, :black},
                       {7, 6, :p, :black},
                       {0, 7, :r, :black},
                       {1, 7, :n, :black},
                       {2, 7, :b, :black},
                       {3, 7, :q, :black},
                       {4, 7, :k, :black},
                       {5, 7, :b, :black},
                       {6, 7, :n, :black},
                       {7, 7, :r, :black},
                     ]
                     |> Map.new(fn {file, rank, piece_type, piece_color} ->
                       {Square.new(file, rank), Piece.new(piece_type, piece_color)}
                     end)

  @spec new() :: t()
  def new(), do: @starting_position

  @spec get(t(), Square.t()) :: Piece.t() | nil
  def get(board = %{}, square = %Square{}), do: Map.get(board, square)

  @spec square_empty?(t(), Square.t()) :: boolean()
  def square_empty?(board = %{}, square = %Square{}),
    do: is_nil(get(board, square))

  @spec set(t(), Square.t(), Piece.t()) :: t()
  def set(
        board = %{},
        square = %Square{},
        piece = %Piece{}
      ) do
    board |> Map.put(square, piece)
  end

  @spec unset(t(), Square.t()) :: t()
  def unset(
        board = %{},
        square = %Square{}
      ) do
    board |> Map.delete(square)
  end
end
