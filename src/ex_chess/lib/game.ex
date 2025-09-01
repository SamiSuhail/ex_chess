defmodule ExChess.Game do
  alias ExChess.{SpecialRules, Board, Move, Square, Piece}

  @type error() :: {:error, :invalid_move}
  @type t() :: %__MODULE__{
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
  @enforce_keys [:board]
  defstruct [:board, special_rules: SpecialRules.new()]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      board: Board.new(),
    }

  @spec move(t(), Move.t()) :: t() | error()
  def move(
        game = %__MODULE__{board: board, special_rules: special_rules},
        move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    if valid_move?(board, piece, move, special_rules) do
      updated_board =
        board
        |> maybe_unset_en_passant_target(piece, move)
        |> Board.set(to, piece)
        |> Board.unset(from)

      updated_special_rules =
        special_rules
        |> put_en_passant_file(piece, move)

      %__MODULE__{game | board: updated_board, special_rules: updated_special_rules}
    else
      {:error, :invalid_move}
    end
  end

  defp maybe_unset_en_passant_target(
         board = %{},
         _piece = %Piece{type: :p},
         _move = %Move{from: from, to: to}
       )
       when from.file != to.file do
    if Board.square_empty?(board, to) do
      Board.unset(board, Square.new(to.file, from.rank))
    else
      board
    end
  end

  defp maybe_unset_en_passant_target(board = %{}, _piece = %Piece{}, _move = %Move{}), do: board

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{type: :p}, %Move{
         from: from,
         to: to,
       })
       when abs(to.rank - from.rank) == 2,
       do: %SpecialRules{special_rules | en_passant_file: to.file}

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{}, %Move{}),
    do: %SpecialRules{special_rules | en_passant_file: nil}

  @spec list_legal_moves(t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %__MODULE__{board: board, special_rules: special_rules},
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    patterns(piece)
    |> Enum.map(fn {file_shift, rank_shift} ->
      Square.shift(from_square, file_shift, rank_shift)
    end)
    |> Enum.filter(fn to_square ->
      valid_move?(board, piece, Move.new(from_square, to_square), special_rules)
    end)
  end

  defp valid_move?(_board = %{}, _piece = nil, _move = %Move{}, _special_rules = %SpecialRules{}),
    do: false

  defp valid_move?(_board = %{}, _piece, _move = %Move{to: to}, _special_rules = %SpecialRules{})
       when to.file not in 0..7 or to.rank not in 0..7,
       do: false

  defp valid_move?(board = %{}, piece = %Piece{}, move = %Move{}, special_rules = %SpecialRules{}) do
    target_piece = Board.get(board, move.to)

    not Piece.same_color?(piece, target_piece) and
      patterns(piece)
      |> valid_move_pattern?(move) and
      (piece_rules_followed?(piece, move, board) or
         special_piece_rules_followed?(piece, move, board, special_rules))
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

  @rook_patterns [
                   {0, 1},
                   {1, 0},
                   {0, -1},
                   {-1, 0},
                 ]
                 |> Enum.flat_map(fn {file_direction, rank_direction} ->
                   1..7
                   |> Enum.map(fn distance ->
                     {file_direction * distance, rank_direction * distance}
                   end)
                 end)

  @bishop_patterns [
                     {1, 1},
                     {1, -1},
                     {-1, 1},
                     {-1, -1},
                   ]
                   |> Enum.flat_map(fn {file_direction, rank_direction} ->
                     1..7
                     |> Enum.map(fn distance ->
                       {file_direction * distance, rank_direction * distance}
                     end)
                   end)

  @queen_patterns Enum.concat(@rook_patterns, @bishop_patterns)

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
  defp patterns(%Piece{type: :r}), do: @rook_patterns
  defp patterns(%Piece{type: :b}), do: @bishop_patterns
  defp patterns(%Piece{type: :q}), do: @queen_patterns
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
    direction = pawn_direction(color)

    cond do
      # taking
      from.file != to.file ->
        not Board.square_empty?(board, to)

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

  defp piece_rules_followed?(
         %Piece{type: piece},
         move = %Move{},
         board = %{}
       )
       when piece in [:r, :b, :q] do
    linear_path_free?(board, move)
  end

  defp piece_rules_followed?(%Piece{}, %Move{}, %{}), do: true

  defp pawn_direction(:white), do: 1
  defp pawn_direction(:black), do: -1

  defp linear_path_free?(board = %{}, %Move{from: from, to: to}) do
    file_direction = linear_direction(from.file, to.file)
    rank_direction = linear_direction(from.rank, to.rank)

    first_square = Square.shift(from, file_direction, rank_direction)

    linear_path_free?(board, first_square, to, file_direction, rank_direction)
  end

  defp linear_direction(from, to) when to < from, do: -1
  defp linear_direction(from, to) when to > from, do: 1
  defp linear_direction(_, _), do: 0

  defp linear_path_free?(board, square, target_square, file_direction, rank_direction) do
    cond do
      Square.same_location?(square, target_square) ->
        true

      not Board.square_empty?(board, square) ->
        false

      true ->
        linear_path_free?(
          board,
          Square.shift(square, file_direction, rank_direction),
          target_square,
          file_direction,
          rank_direction
        )
    end
  end

  defp special_piece_rules_followed?(
         %Piece{type: :p, color: color},
         %Move{from: from, to: to},
         %{},
         %SpecialRules{
           en_passant_file: en_passant_file,
         }
       ),
       do:
         to.file == en_passant_file and to.file != from.file and
           from.rank == en_passant_rank(color)

  defp special_piece_rules_followed?(%Piece{}, %Move{}, %{}, %SpecialRules{}), do: false

  defp en_passant_rank(:white), do: 4
  defp en_passant_rank(:black), do: 3
end
