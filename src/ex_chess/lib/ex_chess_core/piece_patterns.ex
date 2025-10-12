defmodule ExChessCore.PiecePatterns do
  alias ExChess.{Board, Square, Piece}

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

  @rook_directions [
                     {0, 1},
                     {1, 0},
                     {0, -1},
                     {-1, 0},
                   ]
                   |> Enum.map(fn {file_direction, rank_direction} ->
                     1..7
                     |> Enum.map(fn distance ->
                       {file_direction * distance, rank_direction * distance}
                     end)
                   end)

  @bishop_directions [
                       {1, 1},
                       {1, -1},
                       {-1, 1},
                       {-1, -1},
                     ]
                     |> Enum.map(fn {file_direction, rank_direction} ->
                       1..7
                       |> Enum.map(fn distance ->
                         {file_direction * distance, rank_direction * distance}
                       end)
                     end)

  @queen_directions Enum.concat(@rook_directions, @bishop_directions)

  @spec targets(Board.t(), Piece.t(), Square.t()) :: Enumerable.t(Square.t())
  def targets(board, %Piece{type: piece}, from_square) when piece in [:r, :b, :q] do
    directions =
      case piece do
        :r -> @rook_directions
        :b -> @bishop_directions
        :q -> @queen_directions
      end

    directions
    |> Stream.flat_map(fn direction_shifts ->
      {_prev_piece, valid_targets} =
        direction_shifts
        |> Enum.reduce({nil, []}, fn
          {file_shift, rank_shift}, {nil, curr_valid_targets} ->
            square = Square.shift(from_square, file_shift, rank_shift)
            updated_valid_targets = [square | curr_valid_targets]
            curr_piece = Board.get(board, square)
            {curr_piece, updated_valid_targets}

          _square, {prev_piece, curr_valid_targets} ->
            {prev_piece, curr_valid_targets}
        end)

      valid_targets
    end)
  end

  def targets(_board, piece, from_square) do
    patterns(piece)
    |> Stream.map(fn {file_shift, rank_shift} ->
      Square.shift(from_square, file_shift, rank_shift)
    end)
  end

  defp patterns(%Piece{type: :k}), do: @king_patterns
  defp patterns(%Piece{type: :n}), do: @knight_patterns
  defp patterns(%Piece{type: :p, color: :white}), do: @pawn_patterns_white
  defp patterns(%Piece{type: :p, color: :black}), do: @pawn_patterns_black
  defp patterns(_), do: []
end
