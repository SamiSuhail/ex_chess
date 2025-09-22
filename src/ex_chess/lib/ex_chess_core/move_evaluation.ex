defmodule ExChessCore.MoveEvaluation do
  alias ExChess.{Board, SpecialRules, Move, Piece}
  alias ExChessCore.{MoveContext, MoveType, State.BoardManager}
  alias ExChessCore.MoveEvaluation.{Basic, NormalMoves, SpecialMoves, SquareUnderAttack}

  @spec run(
          Piece.color(),
          Board.t(),
          SpecialRules.t() | nil,
          Piece.t() | nil,
          Move.t()
        ) :: :error | {:ok, MoveType.t(), Board.t()}
  def run(color_at_play, board, special_rules, piece, move) do
    with move_context = MoveContext.new(color_at_play, board, move, piece, special_rules),
         true <- Basic.valid?(move_context),
         normal_moves_result = NormalMoves.verify(move_context),
         {:ok, move_type} <-
           normal_moves_result || SpecialMoves.verify(move_context),
         updated_board = BoardManager.update(board, piece, move, move_type),
         false <- SquareUnderAttack.king?(updated_board, piece.color) do
      {:ok, move_type, updated_board}
    else
      _ -> :error
    end
  end
end
