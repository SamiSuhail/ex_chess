defmodule ExChess.Board do
  @moduledoc """
  Exposes a set of types and functions to work with the game's chess board.
  """

  alias ExChess.{Square, Piece}

  @typedoc """
  A map with `ExChess.Square`s as keys and `ExChess.Piece`s as values.

  If a square on the board is occupied by no piece, it should not appear in the map's keys at all.

  This implementation is quite primitive and not very performant, so in later versions it will be replaced with a different board representation, probably bitboards.
  """
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

  @doc """
  Creates a new chess board in the starting position: rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR

  ## Examples

      iex> ExChess.Board.new()
      ...> |> ExChess.Fen.from_board()
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  """
  @spec new() :: t()
  def new(), do: @starting_position

  @doc """
  Returns an empty board.

  Currently not very useful, but the client code should not care about the fact the board is a map.

  ## Examples

      iex> ExChess.Board.empty()
      ...> |> ExChess.Fen.from_board()
      "8/8/8/8/8/8/8/8"
  """
  @spec empty() :: t()
  def empty(), do: %{}

  @doc """
  Gets the piece from `square` of `board`. Returns the `ExChess.Piece` or `nil` when not found.

  ## Examples

  ### Piece found

      iex> white_king_square = ExChess.Square.new(4, 0)
      iex> ExChess.Board.new()
      ...> |> ExChess.Board.get(white_king_square)
      %ExChess.Piece{type: :k, color: :white}

  ### Piece not found
      iex> ExChess.Board.empty()
      ...> |> ExChess.Board.get(ExChess.Square.new(0, 0))
      nil
  """
  @spec get(t(), Square.t()) :: Piece.t() | nil
  def get(board, square = %Square{}), do: Map.get(board, square)

  @doc """
  Returns `true` if `square` of `board` has no piece on it, otherwise `false`.

  ### Empty

      iex> ExChess.Board.empty()
      ...> |> ExChess.Board.square_empty?(ExChess.Square.new(0, 0))
      true

  ### Not empty

      iex> white_king_square = ExChess.Square.new(4, 0)
      iex> ExChess.Board.new()
      ...> |> ExChess.Board.square_empty?(white_king_square)
      false
  """
  @spec square_empty?(t(), Square.t()) :: boolean()
  def square_empty?(board, square = %Square{}),
    do: is_nil(get(board, square))

  @doc """
  Returns an updated `board` with `square`'s value set to `piece`.

  ## Examples

  ### Set piece on empty square

      iex> ExChess.Board.empty()
      ...> |> ExChess.Board.set(ExChess.Square.new(0, 0), ExChess.Piece.new(:k, :white))
      ...> |> ExChess.Fen.from_board()
      "8/8/8/8/8/8/8/K7"

  ### Set piece on occupied square

      iex> square = ExChess.Square.new(0, 0)
      iex> board = ExChess.Board.empty()
      ...> |> ExChess.Board.set(square, ExChess.Piece.new(:k, :white))
      iex> ExChess.Fen.from_board(board)
      "8/8/8/8/8/8/8/K7"
      iex> ExChess.Board.set(board, square, ExChess.Piece.new(:n, :black))
      ...> |> ExChess.Fen.from_board()
      "8/8/8/8/8/8/8/n7"
  """
  @spec set(t(), Square.t(), Piece.t()) :: t()
  def set(
        board,
        square = %Square{},
        piece = %Piece{}
      ) do
    board |> Map.put(square, piece)
  end

  @doc """
  Returns an updated `board` where the `square` and it's piece are unset.

  ## Examples

  ### Unset piece from occupied square

      iex> square = ExChess.Square.new(0, 0)
      iex> board = ExChess.Board.empty()
      ...> |> ExChess.Board.set(square, ExChess.Piece.new(:k, :white))
      iex> ExChess.Fen.from_board(board)
      "8/8/8/8/8/8/8/K7"
      iex> ExChess.Board.unset(board, square)
      ...> |> ExChess.Fen.from_board()
      "8/8/8/8/8/8/8/8"

  ### Unset piece from empty square

      iex> ExChess.Board.empty()
      ...> |> ExChess.Board.unset(ExChess.Square.new(0, 0))
      ...> |> ExChess.Fen.from_board()
      "8/8/8/8/8/8/8/8"
  """
  @spec unset(t(), Square.t()) :: t()
  def unset(
        board,
        square = %Square{}
      ) do
    board |> Map.delete(square)
  end

  @doc """
  Returns a list of all pieces of `color` on `board`.

  The returned element is a list of tuples where the first element is the `ExChess.Square`, and the second element is the `ExChess.Piece`.

  ## Examples

  ### Empty board

      iex> ExChess.Board.empty()
      ...> |> ExChess.Board.get_pieces_by_color(:white)
      []

  ### Board with pieces

      iex> ExChess.Fen.to_board("k7/1p6/8/8/8/8/8/8")
      ...> |> ExChess.Board.get_pieces_by_color(:black)
      [
        {%ExChess.Square{file: 0, rank: 7}, %ExChess.Piece{type: :k, color: :black}},
        {%ExChess.Square{file: 1, rank: 6}, %ExChess.Piece{type: :p, color: :black}}
      ]
  """
  @spec get_pieces_by_color(t(), Piece.color()) :: [{Square.t(), Piece.t()}]
  def get_pieces_by_color(board = %{}, color) do
    Enum.filter(board, fn {_square, piece} -> piece.color == color end)
  end
end
