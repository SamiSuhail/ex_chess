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

  @spec same_color?(t() | nil, t() | nil) :: boolean()
  def same_color?(%__MODULE__{color: color}, %__MODULE__{color: color}), do: true
  def same_color?(_, _), do: false

  @spec flip_color(color()) :: color()
  def flip_color(:white), do: :black
  def flip_color(:black), do: :white
end
