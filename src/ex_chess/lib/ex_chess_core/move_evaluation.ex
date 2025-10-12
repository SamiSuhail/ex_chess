defmodule ExChessCore.MoveEvaluation do
  alias ExChess.{Board, Square, Piece}
  alias ExChessCore.{State.BoardManager, MoveContext, PieceRules}

  @spec run(MoveContext.t()) :: MoveContext.t()
  def run(move_context)
  def run(move_context = %MoveContext{valid?: false}), do: move_context

  def run(move_context = %MoveContext{}) do
    move_context
    |> validate_square_coordinates()
    |> validate_promotion()
    |> evaluate_piece()
    |> evaluate_target_piece()
    |> PieceRules.evaluate()
    |> BoardManager.put_updated()
    |> evaluate_check_respected()
  end

  defp validate_square_coordinates(
         move_context = %MoveContext{square: square, target_square: target_square}
       ) do
    valid? =
      Square.valid?(square) and
        Square.valid?(target_square) and
        not Square.same_location?(square, target_square)

    if valid? do
      move_context
    else
      MoveContext.error(move_context, :out_of_bounds, %{
        square: square,
        target_square: target_square,
      })
    end
  end

  defp validate_promotion(move_context = %MoveContext{valid?: false}), do: move_context

  defp validate_promotion(move_context = %MoveContext{promotion: promotion})
       when promotion in [:q, :r, :b, :n],
       do: move_context

  defp validate_promotion(move_context = %MoveContext{promotion: promotion}),
    do: MoveContext.error(move_context, :promotion, %{promotion: promotion})

  defp evaluate_piece(move_context = %MoveContext{valid?: false}), do: move_context

  defp evaluate_piece(move_context = %MoveContext{color: color, board: board, square: square}) do
    case Board.get(board, square) do
      %Piece{color: ^color, type: piece_type} ->
        %MoveContext{
          move_context
          | piece: piece_type,
        }

      piece = %Piece{} ->
        MoveContext.error(move_context, :player_turn, %{
          active_color: color,
          square: square,
          board: board,
          piece: piece,
        })

      nil ->
        MoveContext.error(move_context, :no_piece, %{square: square, board: board})
    end
  end

  defp evaluate_target_piece(move_context = %MoveContext{valid?: false}),
    do: move_context

  defp evaluate_target_piece(
         move_context = %MoveContext{
           color: color,
           board: board,
           target_square: target_square,
         }
       ) do
    case Board.get(board, target_square) do
      %Piece{color: enemy_color, type: piece_type} when enemy_color != color ->
        %MoveContext{
          move_context
          | target_piece: piece_type,
        }

      nil ->
        move_context

      %Piece{color: piece_color} ->
        MoveContext.error(move_context, :self_take, %{
          piece_color: piece_color,
        })
    end
  end

  defp evaluate_check_respected(move_context = %MoveContext{valid?: false}), do: move_context

  defp evaluate_check_respected(
         move_context = %MoveContext{
           updated_board: updated_board,
           enemy_color: enemy_color,
         }
       ) do
    {king_square, _king} =
      Enum.find(updated_board, fn {_, curr_piece} ->
        curr_piece.type == :k and curr_piece.color != enemy_color
      end)

    king_threatened? =
      PieceRules.king_threatened?(
        updated_board,
        king_square,
        enemy_color
      )

    if king_threatened? do
      MoveContext.error(move_context, :king_checked_after_move)
    else
      move_context
    end
  end
end
