defmodule ExChessCore.GameStatusEvaluation do
  alias ExChessCore.{MoveGeneration, MoveEvaluation}
  alias ExChess.{GameStatus, SpecialRules, Board, Piece}

  @spec evaluate(Piece.color(), Board.t(), SpecialRules.t()) :: GameStatus.t()
  def evaluate(ally_color, board, special_rules) do
    enemy_color = Piece.flip_color(ally_color)

    enemy_stuck? = not has_moves?(enemy_color, board, special_rules)
    enemy_in_check? = MoveEvaluation.SquareUnderAttack.king?(board, enemy_color)

    cond do
      enemy_stuck? and enemy_in_check? -> {ally_color, :checkmate}
      enemy_stuck? -> {:tie, :stalemate}
      true -> :continue
    end
  end

  defp has_moves?(enemy_color, board, special_rules) do
    Board.get_pieces_by_color(board, enemy_color)
    |> Enum.any?(fn {square, piece} ->
      MoveGeneration.stream(enemy_color, board, special_rules, piece, square)
      |> Enum.any?()
    end)
  end
end
