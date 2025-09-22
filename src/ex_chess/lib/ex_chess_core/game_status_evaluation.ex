defmodule ExChessCore.GameStatusEvaluation do
  alias ExChessCore.MoveGeneration
  alias ExChess.{GameStatus, SpecialRules, Board, Piece}

  @spec evaluate(Piece.color(), Board.t(), SpecialRules.t()) :: GameStatus.t()
  def evaluate(ally_color, board, special_rules) do
    evaluate_checkmate(ally_color, board, special_rules) || :continue
  end

  defp evaluate_checkmate(ally_color, board, special_rules) do
    enemy_color = Piece.flip_color(ally_color)

    enemy_has_moves? =
      Board.get_pieces_by_color(board, enemy_color)
      |> Enum.any?(fn {square, piece} ->
        MoveGeneration.stream(enemy_color, board, special_rules, piece, square)
        |> Enum.any?()
      end)

    (not enemy_has_moves? && {ally_color, :checkmate}) || nil
  end
end
