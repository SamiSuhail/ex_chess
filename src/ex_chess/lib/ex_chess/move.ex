defmodule ExChess.Move do
  alias ExChess.Square

  @type promotion() :: nil | :q | :r | :b | :n
  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
          promotion: promotion(),
        }
  @enforce_keys [:from, :to, :promotion]
  defstruct [:from, :to, :promotion]

  @spec new(Square.t(), Square.t(), promotion()) :: t()
  def new(from, to, promotion \\ nil),
    do: %__MODULE__{from: from, to: to, promotion: promotion}
end
