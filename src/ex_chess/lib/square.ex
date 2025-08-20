defmodule ExChess.Square do
  @type t() :: %__MODULE__{
          file: non_neg_integer(),
          rank: non_neg_integer(),
        }
  @enforce_keys [:file, :rank]
  defstruct [:file, :rank]

  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(file, rank), do: %__MODULE__{file: file, rank: rank}
end
