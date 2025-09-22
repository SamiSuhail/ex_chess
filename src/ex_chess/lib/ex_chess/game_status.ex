defmodule ExChess.GameStatus do
  alias ExChess.Piece
  @type continue() :: :continue
  @type checkmate() :: {Piece.color(), :checkmate}
  @type stalemate() :: {:tie, :stalemate}
  @type t() :: continue() | checkmate()
end
