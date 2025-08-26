defmodule ExChess.Move do
  alias ExChess.Square

  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
        }
  @enforce_keys [:from, :to]
  defstruct [:from, :to]

  @spec new(Square.t(), Square.t()) :: t()
  def new(from, to), do: %__MODULE__{from: from, to: to}
end
