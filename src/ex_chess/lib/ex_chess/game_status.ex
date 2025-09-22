defmodule ExChess.GameStatus do
  alias ExChess.Piece
  @type continue() :: :continue
  @type checkmate() :: {Piece.color(), :checkmate}
  @type t() :: continue() | checkmate()
end
