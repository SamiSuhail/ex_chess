defmodule ExChessCore.MoveGeneration do
  alias ExChess.{Game, Board, Move, Square, Piece}
  alias ExChessCore.{MoveContext, MoveEvaluation}

  @spec stream(
          Piece.color(),
          Board.t(),
          Game.en_passant_file(),
          Game.castling_rights(),
          Piece.t(),
          Square.t()
        ) ::
          Enumerable.t(Square.t())
  def stream(color, board, en_passant_file, castling_rights, piece, square) do
    targets(piece, square)
    |> Enum.to_list()
    |> Stream.filter(fn target_square ->
      game = %Game{
        status: :continue,
        active_color: color,
        board: board,
        castling_rights: castling_rights,
        en_passant_file: en_passant_file,
        halfmove_clock: 0,
        repetition_history: %{},
      }

      move = Move.new(square, target_square)
      move_context = MoveContext.new(game, move)

      match?(
        %MoveContext{valid?: true},
        MoveEvaluation.run(move_context)
      )
    end)
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

  defp targets(piece, from_square) do
    patterns(piece)
    |> Stream.map(fn {file_shift, rank_shift} ->
      Square.shift(from_square, file_shift, rank_shift)
    end)
  end

  defp patterns(%Piece{type: :k}), do: @king_patterns
  defp patterns(%Piece{type: :n}), do: @knight_patterns
  defp patterns(%Piece{type: :r}), do: @rook_patterns
  defp patterns(%Piece{type: :b}), do: @bishop_patterns
  defp patterns(%Piece{type: :q}), do: @queen_patterns
  defp patterns(%Piece{type: :p, color: :white}), do: @pawn_patterns_white
  defp patterns(%Piece{type: :p, color: :black}), do: @pawn_patterns_black
  defp patterns(_), do: []
end
