defmodule ExChessCore.MoveContext do
  alias ExChess.{Board, SpecialRules, Move, Piece}

  @type pieces() :: {Piece.t() | nil, Piece.t() | nil}
  @type t() :: %__MODULE__{
          color_at_play: Piece.color(),
          board: Board.t(),
          special_rules: SpecialRules.t() | nil,
          move: Move.t(),
          pieces: pieces(),
        }

  @enforce_keys [:color_at_play, :board, :special_rules, :move, :pieces]
  defstruct [:color_at_play, :board, :special_rules, :move, :pieces]

  @spec new(
          Piece.color(),
          Board.t(),
          Move.t(),
          Piece.t() | nil,
          SpecialRules.t() | nil
        ) :: t()
  def new(
        color_at_play,
        board,
        move = %Move{},
        piece,
        special_rules \\ nil
      ) do
    to_piece = Board.get(board, move.to)

    %__MODULE__{
      color_at_play: color_at_play,
      board: board,
      special_rules: special_rules,
      move: move,
      pieces: {piece, to_piece},
    }
  end
end
