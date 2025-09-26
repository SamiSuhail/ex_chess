defmodule ExChess do
  alias ExChessCore.{
    MoveContext,
    State.SpecialRulesManager,
    State.RepetitionTrackersManager,
    MoveEvaluation,
    MoveGeneration,
    GameStatusEvaluation
  }

  alias ExChess.{Game, Board, Move, Square, Piece}

  @spec start_game() :: Game.t()
  def start_game(), do: Game.new()

  @spec move(Game.t(), Move.t()) :: Game.t() | :error
  def move(%Game{status: game_status}, _move) when game_status != :continue, do: :error

  def move(
        game = %Game{
          board: board,
          color_at_play: color_at_play,
          _private: %{
            repetition_trackers: repetition_trackers,
            special_rules: special_rules,
            halfmove_clock: halfmove_clock,
          },
        },
        move = %Move{}
      ) do
    with piece = Board.get(board, move.from),
         true <- MoveEvaluation.Promotion.valid?(piece, move),
         {:ok, move_type, %MoveContext{pieces: {_, enemy_piece}}, updated_board} <-
           MoveEvaluation.run(color_at_play, board, special_rules, piece, move),
         updated_special_rules =
           SpecialRulesManager.update(special_rules, piece, move, move_type) do
      enemy_color = Piece.flip_color(color_at_play)

      reversible_move? = is_nil(enemy_piece) and piece.type != :p

      {updated_repetition_trackers, repetitions_count} =
        RepetitionTrackersManager.update(
          repetition_trackers,
          enemy_color,
          updated_board,
          reversible_move?,
          special_rules.castling_rights,
          updated_special_rules.castling_rights
        )

      game_status =
        GameStatusEvaluation.evaluate(
          piece.color,
          updated_board,
          updated_special_rules,
          repetitions_count
        )

      updated_halfmove_clock = (reversible_move? && halfmove_clock + 1) || 0

      %Game{
        game
        | board: updated_board,
          color_at_play: enemy_color,
          status: game_status,
          draw_claimable?: updated_halfmove_clock >= 100,
          _private: %{
            special_rules: updated_special_rules,
            repetition_trackers: updated_repetition_trackers,
            halfmove_clock: updated_halfmove_clock,
          },
      }
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
