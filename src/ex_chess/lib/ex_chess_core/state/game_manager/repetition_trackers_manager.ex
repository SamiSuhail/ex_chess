defmodule ExChessCore.State.GameManager.RepetitionTrackersManager do
  alias ExChess.RepetitionTracker
  alias ExChess.{Game, SpecialRules, Board, Piece}

  @spec update(
          Game.repetition_trackers(),
          Piece.color(),
          Board.t(),
          boolean(),
          SpecialRules.castling_rights(),
          SpecialRules.castling_rights()
        ) ::
          {Game.repetition_trackers(), RepetitionTracker.count()}
  def update(
        repetition_trackers,
        enemy_color,
        updated_board,
        reversible_move?,
        castling_rights,
        updated_castling_rights
      ) do
    reset_trackers? = not reversible_move? or castling_rights != updated_castling_rights

    repetition_trackers =
      if reset_trackers? do
        Game.empty_repetition_trackers()
      else
        repetition_trackers
      end

    {updated_repetition_tracker, updated_count} =
      RepetitionTracker.increment(repetition_trackers[enemy_color], updated_board)

    updated_repetition_trackers = %{
      repetition_trackers
      | enemy_color => updated_repetition_tracker,
    }

    {updated_repetition_trackers, updated_count}
  end
end
