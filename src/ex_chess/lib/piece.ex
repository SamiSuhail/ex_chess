defmodule ExChess.Piece do
  @type type() :: :p | :r | :n | :b | :q | :k
  @type color() :: :white | :black
  @type t() :: %__MODULE__{
          type: type(),
          color: color(),
        }
  @enforce_keys [:type, :color]
  defstruct [:type, :color]

  @spec new(type(), color()) :: ExChess.Piece.t()
  def new(type, color), do: %__MODULE__{type: type, color: color}
end
