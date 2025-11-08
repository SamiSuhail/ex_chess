defmodule ExChess.Player do
  @moduledoc """
  Represents a player's view of the game state.

  The main use case for this module is in scenarios where each player has their own "state" in separate processes,
  yet we want to avoid sending the entire game state in each message.
  """

  alias ExChess.{Game, Board, Square, Piece}

  @typedoc """
  Represents the differences in the board's state after a move has been made.
  If the second element of a tuple is `nil`, it indicates that the piece at that square has been removed.
  """
  @type board_diff() :: [{Square.t(), Piece.t() | nil}]

  @typedoc """
  Represents the changes made to a player's state after a move has been made.
  It includes the differences in the board and the updated draw claimable status.
  """
  @type diff() :: %{
          :board => board_diff(),
          :draw_claimable? => boolean(),
        }

  @typedoc """
  This struct contains only the information that a player needs to know about the game state.
  """
  @type t() :: %__MODULE__{
          active_color: Piece.color(),
          fullmove_number: Game.fullmove_number(),
          board: Board.t(),
          draw_claimable?: boolean(),
        }
  @enforce_keys [
    :active_color,
    :fullmove_number,
    :board,
    :draw_claimable?,
  ]
  defstruct [
    :active_color,
    :fullmove_number,
    :board,
    :draw_claimable?,
  ]

  @doc """
  Creates a new `ExChess.Player` struct based on the state of an `ExChess.Game`.
  """
  @spec new(Game.t()) :: t()
  def new(%Game{
        active_color: active_color,
        fullmove_number: fullmove_number,
        board: board,
        halfmove_clock: halfmove_clock,
        max_repetitions: max_repetitions,
      }) do
    new(
      active_color,
      fullmove_number,
      board,
      draw_claimable?(halfmove_clock, max_repetitions)
    )
  end

  @doc """
  Creates a new `ExChess.Player` struct with the given parameters.
  """
  @spec new(Piece.color(), Game.fullmove_number(), Board.t(), boolean()) :: t()
  def new(
        active_color,
        fullmove_number,
        board,
        draw_claimable?
      ) do
    %__MODULE__{
      active_color: active_color,
      fullmove_number: fullmove_number,
      board: board,
      draw_claimable?: draw_claimable?,
    }
  end

  @doc """
  Verifies whether a draw can be claimed based on the 50 move/threefold repetition rules.
  """
  @spec draw_claimable?(Game.halfmove_clock(), Game.max_repetitions()) :: boolean()
  def draw_claimable?(halfmove_clock, max_repetitions) do
    halfmove_clock >= 100 or max_repetitions >= 3
  end

  @doc """
  Returns the updated `ExChess.Player` after applying the given `diff`.
  """
  @spec apply_diff(t(), diff()) :: t()
  def apply_diff(
        _player = %__MODULE__{
          board: board,
          active_color: active_color,
          fullmove_number: fullmove_number,
        },
        _diff = %{board: board_diff, draw_claimable?: draw_claimable?}
      ) do
    updated_board =
      Enum.reduce(board_diff, board, fn
        {square, nil}, acc_board ->
          Board.unset(acc_board, square)

        {square, piece}, acc_board ->
          Board.set(acc_board, square, piece)
      end)

    updated_fullmove_number =
      case active_color do
        :black -> fullmove_number + 1
        :white -> fullmove_number
      end

    updated_active_color = Piece.flip_color(active_color)

    new(
      updated_active_color,
      updated_fullmove_number,
      updated_board,
      draw_claimable?
    )
  end
end
