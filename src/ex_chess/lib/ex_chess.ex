defmodule ExChess do
  alias ExChessCore.GameStatusEvaluation

  alias ExChessCore.{
    State.SpecialRulesManager,
    MoveEvaluation,
    MoveGeneration
  }

  alias ExChess.{Game, GameStatus, Board, Move, Square, Piece}

  @spec start_game() :: {:ok, Game.t(), GameStatus.continue()}
  def start_game(), do: {:ok, Game.new(), :continue}

  @spec move(Game.t(), Move.t()) :: {:ok, Game.t(), GameStatus.t()} | :error
  def move(
        game = %Game{
          board: board,
          special_rules: special_rules,
          color_at_play: color_at_play,
        },
        move = %Move{}
      ) do
    with piece = Board.get(board, move.from),
         true <- MoveEvaluation.Promotion.valid?(piece, move),
         {:ok, move_type, updated_board} <-
           MoveEvaluation.run(color_at_play, board, special_rules, piece, move),
         updated_special_rules = SpecialRulesManager.update(special_rules, piece, move, move_type) do
      game = %Game{
        game
        | board: updated_board,
          special_rules: updated_special_rules,
          color_at_play: Piece.flip_color(color_at_play),
      }

      game_status =
        GameStatusEvaluation.evaluate(piece.color, updated_board, updated_special_rules)

      {:ok, game, game_status}
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

    MoveGeneration.stream(color_at_play, board, special_rules, piece, from_square)
    |> Enum.to_list()
  end
end
