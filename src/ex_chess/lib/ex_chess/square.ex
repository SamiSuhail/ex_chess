defmodule ExChess.Square do
  @moduledoc """
  The `ExChess.Square` module encapsulates the struct and functions used to create and work with squares.

  The functions in this module do not interact with the `ExChess.Board` module at all and are instead focused entirely on the square struct.
  """

  @typedoc """
  A square with it's `:file` (x) and `:rank` (y) coordinates.

  The file is in range `0..7`, mapping to files `a` through `h` in order.
  The rank is in range `0..7`, mapping to ranks `1..8` on a chess board.
  """
  @type t() :: %__MODULE__{
          file: non_neg_integer(),
          rank: non_neg_integer(),
        }
  @enforce_keys [:file, :rank]
  defstruct [:file, :rank]

  @doc """
  Creates a new `ExChess.Square` with the specified `file` and `rank`.

  ## Examples

      iex> ExChess.Square.new(0, 7)
      %ExChess.Square{file: 0, rank: 7}
  """
  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(file, rank), do: %__MODULE__{file: file, rank: rank}

  @doc """
  Returns a new `ExChess.Square` with the updated coordinates by adding the `file_shift` and `rank_shift` to the current file and rank.

  ## Examples

  ### Shifting from the bottom-left to the top-right corners

      iex> square = ExChess.Square.new(0, 0)
      iex> ExChess.Square.shift(square, 7, 7)
      %ExChess.Square{file: 7, rank: 7}

  ### Shifting from the top-right to the bottom-left corners

      iex> square = ExChess.Square.new(7, 7)
      iex> ExChess.Square.shift(square, -7, -7)
      %ExChess.Square{file: 0, rank: 0}
  """
  @spec shift(t(), integer(), integer()) :: t()
  def shift(square = %__MODULE__{}, file_shift, rank_shift),
    do: %__MODULE__{
      square
      | file: square.file + file_shift,
        rank: square.rank + rank_shift,
    }

  @doc """
  Evaluates whether both the coordinates of a `ExChess.Square` are in the `0..7` range.

  ## Examples

  ### Valid

      iex> ExChess.Square.new(0, 7) |> ExChess.Square.valid?()
      true

  ### Too high

      iex> ExChess.Square.new(0, 8) |> ExChess.Square.valid?()
      false

  ### Negative

      iex> ExChess.Square.new(-1, 7) |> ExChess.Square.valid?()
      false
  """
  @spec valid?(t()) :: boolean()
  def valid?(_square = %__MODULE__{file: file, rank: rank}), do: file in 0..7 and rank in 0..7

  @doc """
  Evaluates whether both squares are on the same location.

  This is currently equivalent to checking whether both arguments are of type `ExChess.Square` and equal.

  ## Examples

  ### Equal squares

      iex> first_square = ExChess.Square.new(3, 4)
      iex> second_square = ExChess.Square.new(3, 4)
      iex> ExChess.Square.same_location?(first_square, second_square)
      true

  ### Unequal squares

      iex> first_square = ExChess.Square.new(3, 4)
      iex> second_square = ExChess.Square.new(4, 3)
      iex> ExChess.Square.same_location?(first_square, second_square)
      false

  ### Non-squares

      iex> square = ExChess.Square.new(3, 4)
      iex> ExChess.Square.same_location?(square, nil)
      false
      iex> ExChess.Square.same_location?(nil, square)
      false

      iex> ExChess.Square.same_location?(nil, nil)
      false
  """
  @spec same_location?(t(), t()) :: boolean()
  def same_location?(%__MODULE__{file: file, rank: rank}, %__MODULE__{file: file, rank: rank}),
    do: true

  def same_location?(_, _), do: false

  @doc """
  Returns the `file_shift` and `rank_shift` needed to `ExChess.Square.shift/3` a square from it's current position to that of another square.

  ## Examples

  ### Equal squares

      iex> first_square = ExChess.Square.new(3, 4)
      iex> second_square = ExChess.Square.new(3, 4)
      iex> ExChess.Square.compare(first_square, second_square)
      {0, 0}

  ### Unequal squares

      iex> first_square = ExChess.Square.new(3, 4)
      iex> second_square = ExChess.Square.new(4, 3)
      iex> ExChess.Square.compare(first_square, second_square)
      {1, -1}
  """
  @spec compare(t(), t()) :: {integer(), integer()}
  def compare(from = %__MODULE__{}, to = %__MODULE__{}) do
    file_shift = to.file - from.file
    rank_shift = to.rank - from.rank
    {file_shift, rank_shift}
  end
end
