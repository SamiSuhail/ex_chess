defmodule ExChess.Move do
  @moduledoc """
  `ExChess.Move` is the struct used to represent a move's starting position (`:from_square`), destination (`:to_square`), and promotion type.
  """
  alias ExChess.Square

  @typedoc """
  The piece type that a pawn should be promoted to when it is being moved to the last rank.

  The values are similar to `ExChess.Piece`'s `color()` type, except it does not support `:p` and `:k` as values, as those are not valid promotions.
  """
  @type promotion() :: :q | :r | :b | :n

  @typedoc """
  `ExChess.Move` is the struct used to represent a move's starting position (`:from_square`), destination (`:to_square`), and promotion type.
  """
  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
          promotion: promotion(),
        }
  @enforce_keys [:from, :to, :promotion]
  defstruct [:from, :to, :promotion]

  @doc """
  Creates a new `ExChess.Move` struct.

  ## Examples

  ### With promotion

      iex> first_square = ExChess.Square.new(0, 1)
      iex> second_square = ExChess.Square.new(0, 2)
      iex> ExChess.Move.new(first_square, second_square, :n)
      %ExChess.Move{to: %ExChess.Square{file: 0, rank: 2}, from: %ExChess.Square{file: 0, rank: 1}, promotion: :n}

  ### With default promotion

      iex> first_square = ExChess.Square.new(0, 1)
      iex> second_square = ExChess.Square.new(0, 2)
      iex> ExChess.Move.new(first_square, second_square)
      %ExChess.Move{to: %ExChess.Square{file: 0, rank: 2}, from: %ExChess.Square{file: 0, rank: 1}, promotion: :q}
  """
  @spec new(Square.t(), Square.t(), promotion()) :: t()
  def new(from, to, promotion \\ :q),
    do: %__MODULE__{from: from, to: to, promotion: promotion}
end
