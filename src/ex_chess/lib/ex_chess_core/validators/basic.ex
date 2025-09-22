defmodule ExChessCore.Validators.Basic do
  alias ExChess.{Move, Square, Piece}
  alias ExChessCore.MoveContext

  def valid?(%MoveContext{pieces: {nil, _}}),
    do: false

  def valid?(%MoveContext{move: %Move{to: %Square{file: file, rank: rank}}})
      when file not in 0..7 or rank not in 0..7,
      do: false

  def valid?(%MoveContext{pieces: {%Piece{color: color}, %Piece{color: color}}}),
    do: false

  def valid?(%MoveContext{}),
    do: true
end
