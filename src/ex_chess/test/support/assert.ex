defmodule ExChessTest.Assert do
  import ExUnit.Assertions
  alias ExChess.{Visualization, Game, Board, Square}

  @rank_joiner "\n"
  @file_joiner ""
  def game_board(%Game{board: board}, expected_board_string) do
    assert Visualization.board(board) == expected_board_string
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
      do: "[#{Visualization.piece_label(piece)}]",
      else: " #{Visualization.piece_label(piece)} "
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

  def checkmate(%Game{status: game_status}, color) do
    assert match?({^color, :checkmate}, game_status)
  end

  def resignation(%Game{status: game_status}, color) do
    assert match?({^color, :resignation}, game_status)
  end

  def stalemate(%Game{status: game_status}) do
    assert game_status == {:tie, :stalemate}
  end

  def insufficient_material(%Game{status: game_status}) do
    assert game_status == {:tie, :insufficient_material}
  end

  def threefold_repetition(%Game{status: game_status}) do
    assert game_status == {:tie, :threefold_repetition}
  end

  def fivefold_repetition(%Game{status: game_status}) do
    assert game_status == {:tie, :fivefold_repetition}
  end

  def fifty_move_rule(%Game{status: game_status}) do
    assert game_status == {:tie, :fifty_move_rule}
  end

  def seventy_five_move_rule(%Game{status: game_status}) do
    assert game_status == {:tie, :seventy_five_move_rule}
  end

  def fullmove_number(game = %Game{fullmove_number: fullmove_number}, expected_fullmove_number) do
    assert fullmove_number == expected_fullmove_number
    game
  end
end
