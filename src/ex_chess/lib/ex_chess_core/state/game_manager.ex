defmodule ExChessCore.State.GameManager do
  alias ExChess.{Game, Board, Move, Piece}
  alias ExChessCore.MoveType

  alias __MODULE__.{
    SpecialRulesManager,
    RepetitionTrackersManager,
    GameStatusEvaluation
  }

  @spec update(Game.t(), Board.t(), Move.t(), MoveType.t(), Piece.t(), Piece.t() | nil) ::
          ExChess.Game.t()
  def update(
        game = %Game{
          color_at_play: color_at_play,
          _private: %{
            repetition_trackers: repetition_trackers,
            special_rules: special_rules,
            halfmove_clock: halfmove_clock,
          },
        },
        updated_board,
        move,
        move_type,
        piece = %Piece{},
        enemy_piece
      ) do
    updated_special_rules =
      SpecialRulesManager.update(special_rules, piece, move, move_type)

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
  end
end
