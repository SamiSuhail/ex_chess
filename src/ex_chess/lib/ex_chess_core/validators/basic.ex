defmodule ExChessCore.Validators.Basic do
  alias ExChess.{Move, Square, Piece}
  alias ExChessCore.MoveContext

  def valid?(%MoveContext{pieces: {nil, _}}),
    do: false

  def valid?(%MoveContext{move: %Move{to: %Square{file: file, rank: rank}}})
      when file not in 0..7 or rank not in 0..7,
      do: false

  def valid?(%MoveContext{pieces: {%Piece{color: piece_color}, %Piece{color: piece_color}}}),
    do: false

  def valid?(%MoveContext{pieces: {%Piece{color: piece_color}, _}, color_at_play: color_at_play})
      when piece_color != color_at_play,
      do: false

  def valid?(%MoveContext{}),
    do: true
end
