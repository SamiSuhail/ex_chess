defmodule ExChess.SpecialRules do
  @type t() :: %__MODULE__{
          en_passant_file: non_neg_integer() | nil,
        }
  defstruct en_passant_file: nil

  def new(), do: %__MODULE__{}
end
