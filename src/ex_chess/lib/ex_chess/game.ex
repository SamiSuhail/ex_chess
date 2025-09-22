defmodule ExChess.Game do
  alias ExChess.{SpecialRules, Board}

  @type t() :: %__MODULE__{
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
  @enforce_keys [:board]
  defstruct [:board, special_rules: SpecialRules.new()]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      board: Board.new(),
    }
end
