defmodule ExChessTest.Assert do
  import ExUnit.Assertions
  alias ExChess.{Game, Board, Square, Piece}

  @rank_joiner "\n"
  @file_joiner ""
  def game_board(_game = %Game{board: board}, expected_board_string) do
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

  defp game_board_rank(rank, board = %{}) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file -> Board.get(board, Square.new(file, rank)) |> piece_label() end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
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

  def invalid_move(error), do: assert(error == {:error, :invalid_move})

  def legal_moves(actual, expected_text) do
    actual_text =
      actual
      |> Enum.map(&square_to_text/1)

    assert actual_text == expected_text
  end

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
end
