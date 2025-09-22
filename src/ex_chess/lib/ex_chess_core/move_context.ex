defmodule ExChessCore.MoveContext do
  alias ExChess.{Board, SpecialRules, Move, Piece}

  @type pieces() :: {Piece.t() | nil, Piece.t() | nil}
  @type t() :: %__MODULE__{
          board: Board.t(),
          special_rules: SpecialRules.t() | nil,
          move: Move.t(),
          pieces: pieces(),
        }

  @enforce_keys [:board, :special_rules, :move, :pieces]
  defstruct [:board, :special_rules, :move, :pieces]

  @spec new(
          Board.t(),
          Move.t(),
          Piece.t() | nil,
          SpecialRules.t() | nil
        ) :: t()
  def new(
        board,
        move = %Move{},
        piece,
        special_rules \\ nil
      ) do
    to_piece = Board.get(board, move.to)

    %__MODULE__{
      board: board,
      special_rules: special_rules,
      move: move,
      pieces: {piece, to_piece},
    }
  end
end
