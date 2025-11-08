defmodule ExChessCore.State.BoardManager do
  alias ExChessCore.MoveContext
  alias ExChess.{Board, Square, Piece}

  @spec put_updated(MoveContext.t()) :: MoveContext.t()
  def put_updated(move_context = %MoveContext{valid?: false}), do: move_context

  def put_updated(move_context = %MoveContext{board: board}) do
    %MoveContext{move_context | updated_board: board, board_diff: []}
    |> unset_piece()
    |> set_piece()
    |> maybe_unset_en_passant_target()
    |> maybe_move_rook_for_castle()
  end

  defp unset_piece(
         move_context = %MoveContext{
           updated_board: updated_board,
           board_diff: board_diff,
           square: square,
         }
       ) do
    {updated_board, board_diff}
    |> unset(square)
    |> put_in_move_context(move_context)
  end

  defp set_piece(
         move_context = %MoveContext{
           updated_board: updated_board,
           board_diff: board_diff,
           color: color,
           target_square: target_square,
           piece: piece_type,
           promotion: promotion,
         }
       ) do
    if piece_type == :p and target_square.rank in [0, 7] do
      set({updated_board, board_diff}, target_square, Piece.new(promotion, color))
    else
      set({updated_board, board_diff}, target_square, Piece.new(piece_type, color))
    end
    |> put_in_move_context(move_context)
  end

  defp maybe_unset_en_passant_target(
         move_context = %MoveContext{
           updated_board: updated_board,
           board_diff: board_diff,
           piece: :p,
           square: square,
           target_square: target_square,
           move_type: :en_passant,
         }
       ) do
    {updated_board, board_diff}
    |> unset(Square.new(target_square.file, square.rank))
    |> put_in_move_context(move_context)
  end

  defp maybe_unset_en_passant_target(move_context), do: move_context

  defp maybe_move_rook_for_castle(
         move_context = %MoveContext{
           updated_board: updated_board,
           board_diff: board_diff,
           piece: :k,
           color: color,
           target_square: %Square{rank: target_rank},
           move_type: move_type,
         }
       )
       when move_type in [:castle_queenside, :castle_kingside] do
    {rook_from_file, rook_to_file} =
      case move_type do
        :castle_queenside -> {0, 3}
        :castle_kingside -> {7, 5}
      end

    {updated_board, board_diff}
    |> unset(Square.new(rook_from_file, target_rank))
    |> set(Square.new(rook_to_file, target_rank), Piece.new(:r, color))
    |> put_in_move_context(move_context)
  end

  defp maybe_move_rook_for_castle(move_context), do: move_context

  defp put_in_move_context({updated_board, updated_board_diff}, move_context = %MoveContext{}) do
    %MoveContext{move_context | updated_board: updated_board, board_diff: updated_board_diff}
  end

  defp set({board, board_diff}, square, piece) do
    {Board.set(board, square, piece), [{square, piece} | board_diff]}
  end

  defp unset({board, board_diff}, square) do
    {Board.unset(board, square), [{square, nil} | board_diff]}
  end
end
