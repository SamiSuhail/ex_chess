defmodule ExChess.Piece do
  @moduledoc """
  This module contains the types used to represent a piece on the chess board, as well as some utility functions to create and work with those types.
  """

  @typedoc """
  The piece type (pawn, rook, knight, bishop, queen, king).
  """
  @type type() :: :p | :r | :n | :b | :q | :k

  @typedoc """
  The piece color.
  """
  @type color() :: :white | :black

  @typedoc """
  A struct representing a chess piece. Each piece abides to a different set of rules when moving.
  """
  @type t() :: %__MODULE__{
          type: type(),
          color: color(),
        }
  @enforce_keys [:type, :color]
  defstruct [:type, :color]

  @doc """
  Creates a new chess piece.

  ## Examples
      iex>ExChess.Piece.new(:p, :white)
      %ExChess.Piece{type: :p, color: :white}
  """
  @spec new(type(), color()) :: ExChess.Piece.t()
  def new(type, color), do: %__MODULE__{type: type, color: color}

  @doc """
  Returns `true` when both parameters are a `ExChess.Piece` struct with the same `:color`, otherwise returns `false`.

  ## Examples

  ### Two pieces of same color

      iex> first_piece = ExChess.Piece.new(:p, :white)
      iex> second_piece = ExChess.Piece.new(:n, :white)
      iex> ExChess.Piece.same_color?(first_piece, second_piece)
      true

  ### Two pieces of different color

      iex> first_piece = ExChess.Piece.new(:p, :white)
      iex> second_piece = ExChess.Piece.new(:p, :black)
      iex> ExChess.Piece.same_color?(first_piece, second_piece)
      false

  ### Non-piece

      iex> piece = ExChess.Piece.new(:n, :white)
      iex> ExChess.Piece.same_color?(piece, nil)
      false
      iex> ExChess.Piece.same_color?(nil, piece)
      false

      iex> ExChess.Piece.same_color?(nil, nil)
      false
  """
  @spec same_color?(t() | nil, t() | nil) :: boolean()
  def same_color?(%__MODULE__{color: color}, %__MODULE__{color: color}), do: true
  def same_color?(_, _), do: false

  @doc """
  Returns the opposing color of the passed in `color`.

  ## Examples

  ### Flip white to black

      iex> ExChess.Piece.flip_color(:white)
      :black

  ### Flip black to white
      iex> ExChess.Piece.flip_color(:black)
      :white
  """
  @spec flip_color(color()) :: color()
  def flip_color(color)
  def flip_color(:white), do: :black
  def flip_color(:black), do: :white
end
