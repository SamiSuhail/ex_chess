defmodule ExChess.Game do
  alias ExChess.{SpecialRules, Board, Piece}

  @type t() :: %__MODULE__{
          color_at_play: Piece.color(),
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
  @enforce_keys [:color_at_play, :board, :special_rules]
  defstruct [:color_at_play, :board, :special_rules]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      color_at_play: :white,
      board: Board.new(),
      special_rules: SpecialRules.new(),
    }
end
