defmodule ExChessCore.State.GameManager.GameStatusEvaluation do
  alias ExChessCore.{MoveGeneration, MoveEvaluation}
  alias ExChess.{Game, RepetitionTracker, SpecialRules, Board, Piece}

  @spec evaluate(Piece.color(), Board.t(), SpecialRules.t(), RepetitionTracker.count()) ::
          Game.status()
  def evaluate(_ally_color, _board, _special_rules, repetitions_count)
      when repetitions_count >= 3,
      do: {:tie, :threefold_repetition}

  def evaluate(ally_color, board, special_rules, _repetitions_count) do
    enemy_color = Piece.flip_color(ally_color)

    enemy_pieces = Board.get_pieces_by_color(board, enemy_color)

    enemy_stuck? = not has_moves?(enemy_pieces, board, special_rules)
    enemy_in_check? = MoveEvaluation.SquareUnderAttack.king?(board, enemy_color)

    cond do
      enemy_stuck? and enemy_in_check? ->
        {ally_color, :checkmate}

      enemy_stuck? ->
        {:tie, :stalemate}

      insufficient_material?(enemy_pieces) and
          insufficient_material?(Board.get_pieces_by_color(board, ally_color)) ->
        {:tie, :insufficient_material}

      true ->
        :continue
    end
  end

  defp has_moves?(enemy_pieces, board, special_rules) do
    Enum.any?(enemy_pieces, fn {square, piece} ->
      MoveGeneration.stream(piece.color, board, special_rules, piece, square)
      |> Enum.any?()
    end)
  end

  defp insufficient_material?(player_pieces) do
    case player_pieces do
      [_] ->
        true

      [_, _] ->
        Enum.sum_by(player_pieces, fn {_, %Piece{type: piece_type}} -> score(piece_type) end) <= 4

      _ ->
        false
    end
  end

  defp score(piece_type) when piece_type in [:n, :b], do: 3
  defp score(:k), do: 1
  defp score(_piece_type), do: 5
end
