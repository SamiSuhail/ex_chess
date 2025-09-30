defmodule ExChessCore.State.BoardManager do
  alias ExChessCore.MoveContext
  alias ExChess.{Board, Square, Piece}

  @spec put_updated(MoveContext.t()) :: MoveContext.t()
  def put_updated(move_context = %MoveContext{valid?: false}), do: move_context

  def put_updated(move_context = %MoveContext{board: board}) do
    %MoveContext{move_context | updated_board: board}
    |> move_piece()
    |> maybe_unset_en_passant_target()
    |> maybe_promote()
    |> maybe_castle()
  end

  defp move_piece(
         move_context = %MoveContext{
           updated_board: updated_board,
           color: color,
           square: square,
           target_square: target_square,
           piece: piece_type,
         }
       ) do
    updated_board =
      updated_board
      |> Board.unset(square)
      |> Board.set(target_square, Piece.new(piece_type, color))

    %MoveContext{move_context | updated_board: updated_board}
  end

  defp maybe_unset_en_passant_target(
         move_context = %MoveContext{
           updated_board: updated_board,
           piece: :p,
           square: square,
           target_square: target_square,
           move_type: :en_passant,
         }
       ) do
    updated_board =
      Board.unset(updated_board, Square.new(target_square.file, square.rank))

    %MoveContext{move_context | updated_board: updated_board}
  end

  defp maybe_unset_en_passant_target(move_context), do: move_context

  defp maybe_promote(
         move_context = %MoveContext{
           updated_board: updated_board,
           target_square: target_square,
           promotion: promotion,
           color: color,
           piece: :p,
         }
       )
       when target_square.rank in [0, 7] do
    updated_board =
      Board.set(updated_board, target_square, Piece.new(promotion, color))

    %MoveContext{move_context | updated_board: updated_board}
  end

  defp maybe_promote(move_context), do: move_context

  defp maybe_castle(
         move_context = %MoveContext{
           updated_board: updated_board,
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

    updated_board =
      Board.unset(updated_board, Square.new(rook_from_file, target_rank))
      |> Board.set(Square.new(rook_to_file, target_rank), Piece.new(:r, color))

    %MoveContext{move_context | updated_board: updated_board}
  end

  defp maybe_castle(move_context), do: move_context
end
