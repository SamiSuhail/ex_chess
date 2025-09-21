defmodule ExChess do
  alias ExChessCore.{
    Validators,
    MoveContext,
    State.SpecialRulesManager,
    State.BoardManager,
    PieceTargets
  }

  alias ExChess.{Game, Board, Move, Square, Piece}

  @spec start_game() :: Game.t()
  def start_game(), do: Game.new()

  @spec move(Game.t(), Move.t()) :: Game.t() | :error
  def move(
        game = %Game{
          board: board,
          special_rules: special_rules,
          color_at_play: color_at_play,
        },
        move = %Move{}
      ) do
    with piece = Board.get(board, move.from),
         true <- Validators.Promotion.valid?(piece, move),
         {:ok, move_type, updated_board} <-
           evaluate_move(move, piece, board, special_rules, color_at_play),
         updated_special_rules = SpecialRulesManager.update(special_rules, piece, move, move_type) do
      %Game{
        game
        | board: updated_board,
          special_rules: updated_special_rules,
          color_at_play: Piece.flip_color(color_at_play),
      }
    else
      _ -> :error
    end
  end

  @spec list_legal_moves(Game.t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %Game{board: board, special_rules: special_rules, color_at_play: color_at_play},
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    PieceTargets.get(piece, from_square)
    |> Enum.filter(fn to_square ->
      move = Move.new(from_square, to_square)
      match?({:ok, _, _}, evaluate_move(move, piece, board, special_rules, color_at_play))
    end)
  end

  defp evaluate_move(move, piece, board, special_rules, color_at_play) do
    with move_context = MoveContext.new(color_at_play, board, move, piece, special_rules),
         true <- Validators.Basic.valid?(move_context),
         normal_moves_result = Validators.NormalMoves.verify(move_context),
         {:ok, move_type} <-
           normal_moves_result || Validators.SpecialMoves.verify(move_context),
         updated_board = BoardManager.update(board, piece, move, move_type),
         false <- Validators.SquareUnderAttack.king?(updated_board, piece.color) do
      {:ok, move_type, updated_board}
    else
      _ -> :error
    end
  end
end
