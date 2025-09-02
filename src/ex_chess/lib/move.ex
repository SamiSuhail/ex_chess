defmodule ExChess.Move do
  alias ExChess.Square

  @type promotion_detail() :: {:promotion, :q | :r | :b | :n}
  @type detail() :: nil | promotion_detail()
  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
          detail: detail(),
        }
  @enforce_keys [:from, :to, :detail]
  defstruct [:from, :to, :detail]

  @spec new(Square.t(), Square.t(), detail()) :: t()
  def new(from, to, detail \\ nil),
    do: %__MODULE__{from: from, to: to, detail: detail}
end
