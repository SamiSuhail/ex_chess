defmodule ExChess.Game do
  alias ExChess.{Board, Move, Square, Piece}

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

    if valid_move?(board, piece, move) do
      updated_board =
        board
        |> Board.set(to, piece)
        |> Board.unset(from)

      %__MODULE__{game | board: updated_board}
    else
      {:error, :invalid_move}
    end
  end

  @spec list_legal_moves(t(), Square.t()) :: [Square.t()]
  def list_legal_moves(%__MODULE__{board: board}, from_square = %Square{}) do
    piece = Board.get(board, from_square)

    patterns(piece)
    |> Enum.map(fn {file_shift, rank_shift} ->
      Square.shift(from_square, file_shift, rank_shift)
    end)
    |> Enum.filter(fn to_square ->
      valid_move?(board, piece, Move.new(from_square, to_square))
    end)
  end

  defp valid_move?(_board = %{}, _piece = nil, _move = %Move{}), do: false

  defp valid_move?(_board = %{}, _piece, _move = %Move{to: to})
       when to.file not in 0..7 or to.rank not in 0..7,
       do: false

  defp valid_move?(board = %{}, piece = %Piece{}, move = %Move{}) do
    target_piece = Board.get(board, move.to)

    not Piece.same_color?(piece, target_piece) and
      patterns(piece)
      |> valid_move_pattern?(move) and
      piece_rules_followed?(piece, move, board)
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

  @pawn_patterns_white [
    {0, 1},
    {0, 2},
    {1, 1},
    {-1, 1},
  ]

  @pawn_patterns_black [
    {0, -1},
    {0, -2},
    {1, -1},
    {-1, -1},
  ]

  defp patterns(%Piece{type: :k}), do: @king_patterns
  defp patterns(%Piece{type: :n}), do: @knight_patterns
  defp patterns(%Piece{type: :p, color: :white}), do: @pawn_patterns_white
  defp patterns(%Piece{type: :p, color: :black}), do: @pawn_patterns_black
  defp patterns(_), do: []

  defp valid_move_pattern?(patterns, %Move{from: from, to: to}) do
    patterns
    |> Enum.any?(fn {file_shift, rank_shift} ->
      Square.shift(from, file_shift, rank_shift)
      |> Square.same_location?(to)
    end)
  end

  defp piece_rules_followed?(
         %Piece{type: :p, color: color},
         %Move{from: from, to: to},
         board = %{}
       ) do
    direction = direction(color)

    cond do
      # taking
      from.file != to.file ->
        true

      # one rank advance
      abs(to.rank - from.rank) == 1 ->
        Board.square_empty?(board, to)

      # two rank advance
      true ->
        from.rank in [1, 6] and
          Board.square_empty?(board, to) and
          Board.square_empty?(board, from |> Square.shift(0, direction))
    end
  end

  defp piece_rules_followed?(%Piece{}, %Move{}, %{}), do: true

  defp direction(:white), do: 1
  defp direction(:black), do: -1
end
