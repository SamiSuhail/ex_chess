defmodule ExChessCore.PieceRules do
  alias ExChess.{Game, Board, Move, Square, Piece}
  alias ExChessCore.MoveContext
  alias ExChessCore.PieceRules.{KingRules, KnightRules, LinearPieceRules, PawnRules}

  @spec evaluate(MoveContext.t()) :: MoveContext.t()
  def evaluate(%MoveContext{valid?: false} = move_context), do: move_context

  def evaluate(move_context = %MoveContext{}) do
    evaluate_internal(move_context, false)
  end

  @spec evaluate_king_threats(Board.t(), Piece.color(), Piece.type(), Square.t(), Square.t()) ::
          MoveContext.t()
  def evaluate_king_threats(board, enemy_color, enemy_piece, enemy_square, king_square) do
    game = Game.new(enemy_color, board)
    move = Move.new(enemy_square, king_square)

    %MoveContext{MoveContext.new(game, move) | piece: enemy_piece, target_piece: :k}
    |> evaluate_internal(true)
  end

  defp evaluate_internal(move_context = %MoveContext{piece: piece_type}, king_threats_only?) do
    rules(piece_type).evaluate(move_context, king_threats_only?)
  end

  defp rules(:k), do: KingRules
  defp rules(:p), do: PawnRules
  defp rules(:n), do: KnightRules
  defp rules(piece_type) when piece_type in [:q, :b, :r], do: LinearPieceRules
end
