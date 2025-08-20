defmodule ExChess.Board do
  alias ExChess.{Square, Piece}
  @type t() :: %{Square.t() => Piece.t()}
end
