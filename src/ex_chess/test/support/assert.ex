defmodule ExChessTest.Assert do
  import ExUnit.Assertions
  alias ExChess.{Game, Board, Square, Piece}

  @rank_joiner "\n"
  @file_joiner ""
  def game_board({:ok, %Game{board: board}, _game_status}, expected_board_string) do
    ranks_text =
      7..0//-1
      |> Enum.map(fn rank -> game_board_rank(rank, board) end)
      |> Enum.join(@rank_joiner)

    assert """
              abcdefgh
             ----------
           #{ranks_text}
             ----------
              abcdefgh
           """ == expected_board_string
  end

  defp game_board_rank(rank, board) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file -> Board.get(board, Square.new(file, rank)) |> piece_label() end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
  end

  def invalid_move(error), do: assert(error == :error)

  def legal_moves({%Game{board: board}, actual}, expected_text) when is_binary(expected_text) do
    assert Enum.all?(actual, fn %Square{file: file, rank: rank} ->
             file in 0..7 and rank in 0..7
           end)

    ranks_text =
      7..0//-1
      |> Enum.map(fn rank -> legal_moves_rank(actual, rank, board) end)
      |> Enum.join(@rank_joiner)

    assert """
               a  b  c  d  e  f  g  h
             --------------------------
           #{ranks_text}
             --------------------------
               a  b  c  d  e  f  g  h
           """ == expected_text
  end

  def legal_moves({_game, actual}, expected_text) when is_list(expected_text) do
    assert Enum.all?(actual, fn %Square{file: file, rank: rank} ->
             file in 0..7 and rank in 0..7
           end)

    actual_text =
      actual
      |> Enum.map(&square_to_text/1)

    assert actual_text == expected_text
  end

  defp legal_moves_rank(legal_moves, rank, board) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file ->
        square = Square.new(file, rank)
        Board.get(board, square) |> legal_moves_square_label(square, legal_moves)
      end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
  end

  defp legal_moves_square_label(piece, square, legal_moves) do
    if square in legal_moves,
      do: "[#{piece_label(piece)}]",
      else: " #{piece_label(piece)} "
  end

  defp piece_label(nil), do: " "

  defp piece_label(%Piece{type: :p, color: :white}), do: "P"
  defp piece_label(%Piece{type: :p, color: :black}), do: "p"
  defp piece_label(%Piece{type: :r, color: :white}), do: "R"
  defp piece_label(%Piece{type: :r, color: :black}), do: "r"
  defp piece_label(%Piece{type: :n, color: :white}), do: "N"
  defp piece_label(%Piece{type: :n, color: :black}), do: "n"
  defp piece_label(%Piece{type: :b, color: :white}), do: "B"
  defp piece_label(%Piece{type: :b, color: :black}), do: "b"
  defp piece_label(%Piece{type: :q, color: :white}), do: "Q"
  defp piece_label(%Piece{type: :q, color: :black}), do: "q"
  defp piece_label(%Piece{type: :k, color: :white}), do: "K"
  defp piece_label(%Piece{type: :k, color: :black}), do: "k"

  defp square_to_text(%Square{file: file, rank: rank}),
    do: "#{file_to_text(file)}#{rank_to_text(rank)}"

  defp file_to_text(0), do: "a"
  defp file_to_text(1), do: "b"
  defp file_to_text(2), do: "c"
  defp file_to_text(3), do: "d"
  defp file_to_text(4), do: "e"
  defp file_to_text(5), do: "f"
  defp file_to_text(6), do: "g"
  defp file_to_text(7), do: "h"

  defp rank_to_text(rank), do: "#{rank + 1}"

  def checkmate({:ok, _game, game_status}, color) do
    assert match?({^color, :checkmate}, game_status)
  end
end
