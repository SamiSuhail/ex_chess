defmodule ExChess.Square do
  @type t() :: %__MODULE__{
          file: non_neg_integer(),
          rank: non_neg_integer(),
        }
  @enforce_keys [:file, :rank]
  defstruct [:file, :rank]

  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(file, rank), do: %__MODULE__{file: file, rank: rank}

  @spec shift(t(), integer(), integer()) :: t()
  def shift(square = %__MODULE__{}, file_shift, rank_shift),
    do: %__MODULE__{
      square
      | file: square.file + file_shift,
        rank: square.rank + rank_shift,
    }

  @spec same_location?(t(), t()) :: boolean()
  def same_location?(%__MODULE__{file: file, rank: rank}, %__MODULE__{file: file, rank: rank}),
    do: true

  def same_location?(_, _), do: false
end
