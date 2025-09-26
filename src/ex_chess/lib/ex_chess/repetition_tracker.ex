defmodule ExChess.RepetitionTracker do
  alias ExChess.{Board, Piece}

  @type hash() :: non_neg_integer()
  @type count() :: pos_integer()
  @type t() :: %{hash() => count()}

  @new_black %{}
  @new_white %{:erlang.phash2(Board.new()) => 1}

  @spec new(Piece.color()) :: t()
  def new(:black), do: @new_black
  def new(:white), do: @new_white

  @spec increment(t(), Board.t()) :: {t(), count()}
  def increment(repetition_tracker, board) do
    position_hash = :erlang.phash2(board)
    current_count = Map.get(repetition_tracker, position_hash, 0)
    updated_count = current_count + 1
    {Map.put(repetition_tracker, position_hash, updated_count), updated_count}
  end
end
