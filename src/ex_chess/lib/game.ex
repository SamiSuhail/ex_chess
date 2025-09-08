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
        move = %Move{}
      ) do
    piece = Board.get(board, move.from)

    if valid_move?(board, piece, move, special_rules) do
      updated_board = update_board(board, piece, move)

      updated_special_rules =
        special_rules
        |> put_en_passant_file(piece, move)
        |> maybe_put_castles(move.from)

      %__MODULE__{game | board: updated_board, special_rules: updated_special_rules}
    else
      {:error, :invalid_move}
    end
  end

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{type: :p}, %Move{
         from: from,
         to: to,
       })
       when abs(to.rank - from.rank) == 2,
       do: %SpecialRules{special_rules | en_passant_file: to.file}

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{}, %Move{}),
    do: %SpecialRules{special_rules | en_passant_file: nil}

  defp maybe_put_castles(special_rules = %SpecialRules{castles: castles}, from_square = %Square{}) do
    indexes =
      case from_square do
        # white
        %Square{file: 0, rank: 0} -> [0]
        %Square{file: 7, rank: 0} -> [1]
        %Square{file: 4, rank: 0} -> [0, 1]
        # black
        %Square{file: 0, rank: 7} -> [2]
        %Square{file: 7, rank: 7} -> [3]
        %Square{file: 4, rank: 7} -> [2, 3]
        _ -> []
      end

    updated_castles =
      Enum.reduce(indexes, castles, fn index, castles -> put_elem(castles, index, false) end)

    %SpecialRules{special_rules | castles: updated_castles}
  end

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
      valid_move?(
        board,
        piece,
        Move.new(from_square, to_square),
        special_rules,
        skip_move_patterns?: true,
        skip_move_detail?: true
      )
    end)
  end

  defp valid_move?(_board, _piece, _move, _special_rules, _opts \\ [])

  defp valid_move?(_board, _piece = nil, _move, _special_rules, _opts),
    do: false

  defp valid_move?(_board, _piece, _move = %Move{to: to}, _special_rules, _opts)
       when to.file not in 0..7 or to.rank not in 0..7,
       do: false

  defp valid_move?(
         board = %{},
         piece = %Piece{},
         move = %Move{},
         special_rules = %SpecialRules{},
         opts
       ) do
    target_piece = Board.get(board, move.to)

    skip_move_patterns? = Keyword.get(opts, :skip_move_patterns?, false)
    skip_move_detail? = Keyword.get(opts, :skip_move_detail?, false)
    skip_check? = Keyword.get(opts, :skip_check?, false)

    include_special_rules? = Keyword.get(opts, :include_special_rules?, true)

    not Piece.same_color?(piece, target_piece) and
      (skip_move_patterns? or
         patterns(piece)
         |> valid_move_pattern?(move)) and
      (skip_move_detail? or valid_move_detail?(move, piece)) and
      (piece_rules_followed?(piece, move, board) or
         (include_special_rules? and
            special_piece_rules_followed?(piece, move, board, special_rules))) and
      (skip_check? or check_respected?(board, piece, move))
  end

  defp check_respected?(
         board = %{},
         piece = %Piece{color: color},
         move = %Move{}
       ) do
    updated_board = update_board(board, piece, move)

    {king_square, _king} =
      Enum.find(updated_board, fn {_, curr_piece} ->
        curr_piece.type == :k and curr_piece.color == color
      end)

    king_attacked? =
      Enum.filter(updated_board, fn {_, curr_piece} -> curr_piece.color != color end)
      |> Enum.any?(fn {square, enemy_piece} ->
        valid_move?(
          updated_board,
          enemy_piece,
          Move.new(square, king_square),
          SpecialRules.new(),
          include_special_rules?: false,
          skip_move_detail?: true,
          skip_check?: true
        )
      end)

    not king_attacked?
  end

  defp update_board(board = %{}, piece = %Piece{}, move = %Move{}) do
    board
    |> maybe_unset_en_passant_target(piece, move)
    |> Board.set(move.to, piece)
    |> Board.unset(move.from)
    |> maybe_promote(move.to, move.detail, piece.color)
    |> maybe_castle(piece, move)
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

  defp maybe_promote(board, square, _detail = {:promotion, piece_type}, piece_color),
    do: Board.set(board, square, Piece.new(piece_type, piece_color))

  defp maybe_promote(board, _square, _detail, _piece_color), do: board

  defp maybe_castle(board, %Piece{type: :k}, %Move{from: from, to: to})
       when abs(to.file - from.file) < 2,
       do: board

  defp maybe_castle(board, %Piece{type: :k, color: color}, %Move{to: to}) do
    {rook_from_file, rook_to_file} =
      case to.file do
        2 -> {0, 3}
        6 -> {7, 5}
      end

    Board.unset(board, Square.new(rook_from_file, to.rank))
    |> Board.set(Square.new(rook_to_file, to.rank), Piece.new(:r, color))
  end

  defp maybe_castle(board, _piece, _move), do: board

  @valid_pawn_promotion_types [:q, :r, :b, :n]
  defp valid_move_detail?(%Move{to: to, detail: detail}, %Piece{type: :p})
       when to.rank in [0, 7] do
    case detail do
      {:promotion, piece_type} -> piece_type in @valid_pawn_promotion_types
      _ -> false
    end
  end

  defp valid_move_detail?(%Move{detail: detail}, %Piece{type: :p}), do: is_nil(detail)

  defp valid_move_detail?(%Move{}, %Piece{}), do: true

  @king_patterns [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1},
    # castle
    {-2, 0},
    {2, 0},
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

  defp piece_rules_followed?(%Piece{type: :k}, %Move{from: from, to: to}, _board = %{}),
    do: abs(to.file - from.file) <= 1

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

  defp special_piece_rules_followed?(
         %Piece{type: :k, color: color},
         move = %Move{from: from, to: to},
         board = %{},
         %SpecialRules{castles: castles}
       )
       when abs(to.file - from.file) == 2 do
    king_starting_position?(color, from) and
      king_and_rook_not_moved?(castles, to) and
      castle_path_clear?(board, move)
  end

  defp special_piece_rules_followed?(%Piece{}, %Move{}, %{}, %SpecialRules{}), do: false

  defp en_passant_rank(:white), do: 4
  defp en_passant_rank(:black), do: 3

  defp king_starting_position?(:white, %Square{file: 4, rank: 0}), do: true
  defp king_starting_position?(:black, %Square{file: 4, rank: 7}), do: true
  defp king_starting_position?(_, _), do: false

  defp king_and_rook_not_moved?(
         {
           white_queenside?,
           white_kingside?,
           black_queenside?,
           black_kingside?
         },
         to = %Square{}
       ),
       do:
         (to.rank == 0 and to.file == 2 and white_queenside?) or
           (to.rank == 0 and to.file == 6 and white_kingside?) or
           (to.rank == 7 and to.file == 2 and black_queenside?) or
           (to.rank == 7 and to.file == 6 and black_kingside?)

  defp castle_path_clear?(board, %Move{from: from, to: to}) do
    file_shifts =
      if to.file == 2,
        do: -1..-3//-1,
        else: 1..2

    Enum.all?(
      file_shifts,
      &Board.square_empty?(board, Square.shift(from, &1, 0))
    )
  end
end
