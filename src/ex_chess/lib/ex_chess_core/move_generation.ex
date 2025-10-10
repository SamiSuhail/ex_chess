defmodule ExChessCore.MoveGeneration do
  alias ExChess.{Game, Board, Move, Square, Piece}
  alias ExChessCore.{MoveContext, MoveEvaluation, PiecePatterns}

  @spec stream(
          Piece.color(),
          Board.t(),
          Game.en_passant_file(),
          Game.castling_rights(),
          Piece.t(),
          Square.t()
        ) ::
          Enumerable.t(Square.t())
  def stream(color, board, en_passant_file, castling_rights, piece, square) do
    game = Game.new(color, board, castling_rights, en_passant_file)

    PiecePatterns.targets(piece, square)
    |> Stream.filter(fn target_square ->
      move = Move.new(square, target_square)
      move_context = MoveContext.new(game, move)

      match?(
        %MoveContext{valid?: true},
        MoveEvaluation.run(move_context)
      )
    end)
  end
end
