defmodule ExChess.SpecialRules do
  @type castles() :: {boolean(), boolean(), boolean(), boolean()}
  @type t() :: %__MODULE__{
          en_passant_file: non_neg_integer() | nil,
          castles: castles(),
        }
  defstruct en_passant_file: nil, castles: {true, true, true, true}

  def new(), do: %__MODULE__{}
end
