defmodule ExChessCore.PieceRules do
  alias ExChess.{Game, Board, Move, Square, Piece}
  alias ExChessCore.{MoveContext, PiecePatterns}
  alias ExChessCore.PieceRules.{KingRules, KnightRules, LinearPieceRules, PawnRules}

  @spec evaluate(MoveContext.t()) :: MoveContext.t()
  def evaluate(%MoveContext{valid?: false} = move_context), do: move_context

  def evaluate(move_context = %MoveContext{}) do
    evaluate_internal(move_context, false)
  end

  @piece_types [:n, :q, :r, :b, :p, :k]
  @spec king_threatened?(Board.t(), Square.t(), Piece.color()) :: boolean()
  def king_threatened?(board, king_square, enemy_color) do
    game = Game.new(enemy_color, board)

    @piece_types
    |> Enum.any?(fn piece -> threatening_king?(piece, game, king_square) end)
  end

  defp threatening_king?(
         piece,
         game = %Game{active_color: active_color, board: board},
         king_square
       ) do
    king_color = Piece.flip_color(active_color)

    PiecePatterns.targets(board, Piece.new(piece, king_color), king_square)
    |> Stream.filter(fn enemy_square ->
      case Board.get(board, enemy_square) do
        %Piece{type: ^piece, color: ^active_color} -> true
        _ -> false
      end
    end)
    |> Enum.any?(fn enemy_square ->
      move = Move.new(enemy_square, king_square)

      result =
        %MoveContext{MoveContext.new(game, move) | piece: piece, target_piece: :k}
        |> evaluate_internal(true)

      match?(%MoveContext{valid?: true}, result)
    end)
  end

  defp evaluate_internal(move_context = %MoveContext{piece: piece_type}, king_threats_only?) do
    rules(piece_type).evaluate(move_context, king_threats_only?)
  end

  defp rules(:k), do: KingRules
  defp rules(:p), do: PawnRules
  defp rules(:n), do: KnightRules
  defp rules(piece_type) when piece_type in [:q, :b, :r], do: LinearPieceRules
end
