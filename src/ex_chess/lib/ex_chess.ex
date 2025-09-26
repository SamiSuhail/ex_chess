defmodule ExChess do
  alias ExChessCore.{
    MoveContext,
    State.GameManager,
    MoveEvaluation,
    MoveGeneration
  }

  alias ExChess.{Game, Board, Move, Square}

  @spec start_game() :: Game.t()
  def start_game(), do: Game.new()

  @spec move(Game.t(), Move.t()) :: Game.t() | :error
  def move(%Game{status: game_status}, _move) when game_status != :continue, do: :error

  def move(
        game = %Game{
          board: board,
          color_at_play: color_at_play,
          _private: %{
            special_rules: special_rules,
          },
        },
        move = %Move{}
      ) do
    with piece = Board.get(board, move.from),
         true <- MoveEvaluation.Promotion.valid?(piece, move),
         {:ok, move_type, %MoveContext{pieces: {_, enemy_piece}}, updated_board} <-
           MoveEvaluation.run(color_at_play, board, special_rules, piece, move) do
      GameManager.update(game, updated_board, move, move_type, piece, enemy_piece)
    else
      _ -> :error
    end
  end

  @spec list_legal_moves(Game.t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %Game{
          board: board,
          _private: %{special_rules: special_rules},
          color_at_play: color_at_play,
        },
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    MoveGeneration.stream(color_at_play, board, special_rules, piece, from_square)
    |> Enum.to_list()
  end

  @spec claim_draw(Game.t()) :: Game.t() | :error
  def claim_draw(%Game{status: status}) when status != :continue, do: :error
  def claim_draw(%Game{draw_claimable?: false}), do: :error
  def claim_draw(game = %Game{}), do: %Game{game | status: {:tie, :fifty_move_rule}}
end
