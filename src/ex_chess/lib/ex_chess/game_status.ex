defmodule ExChess.GameStatus do
  alias ExChess.Piece
  @type continue() :: :continue
  @type checkmate() :: {Piece.color(), :checkmate}
  @type stalemate() :: :stalemate
  @type insufficient_material() :: :insufficient_material

  @type t() ::
          continue()
          | checkmate()
          | {:tie, stalemate() | insufficient_material()}
end
