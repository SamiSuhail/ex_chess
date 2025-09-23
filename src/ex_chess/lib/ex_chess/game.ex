defmodule ExChess.Game do
  alias ExChess.{SpecialRules, RepetitionTracker, Board, Piece}

  @type status() ::
          :continue
          | {Piece.color(), :checkmate}
          | {:tie, :stalemate | :insufficient_material | :threefold_repetition}

  @type repetition_trackers() :: %{black: RepetitionTracker.t(), white: RepetitionTracker.t()}
  @type t() :: %__MODULE__{
          _private: %{
            special_rules: SpecialRules.t(),
            repetition_trackers: repetition_trackers(),
          },
          color_at_play: Piece.color(),
          board: Board.t(),
          status: status(),
        }
  @enforce_keys [
    :color_at_play,
    :board,
    :status,
    :_private,
  ]
  defstruct [:color_at_play, :board, :status, :_private]

  @initial_repetition_trackers %{
    white: RepetitionTracker.new(:white),
    black: RepetitionTracker.new(:black),
  }

  @spec new() :: t()
  def new() do
    %__MODULE__{
      color_at_play: :white,
      board: Board.new(),
      _private: %{
        special_rules: SpecialRules.new(),
        repetition_trackers: @initial_repetition_trackers,
      },
      status: :continue,
    }
  end

  @spec empty_repetition_trackers() :: %{white: %{}, black: %{}}
  def empty_repetition_trackers(), do: %{white: %{}, black: %{}}
end
