defmodule ExChess.Visualization.Board do
  alias ExChess.{Board, Square, Piece}

  @rank_joiner "\n"
  @file_joiner ""
  def inspect(board) do
    ranks_text =
      7..0//-1
      |> Enum.map(fn rank -> game_board_rank(rank, board) end)
      |> Enum.join(@rank_joiner)

    """
       abcdefgh
      ----------
    #{ranks_text}
      ----------
       abcdefgh
    """
  end

  defp game_board_rank(rank, board) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file -> Board.get(board, Square.new(file, rank)) |> piece_label() end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
  end

  def piece_label(nil), do: " "

  def piece_label(%Piece{type: :p, color: :white}), do: "P"
  def piece_label(%Piece{type: :p, color: :black}), do: "p"
  def piece_label(%Piece{type: :r, color: :white}), do: "R"
  def piece_label(%Piece{type: :r, color: :black}), do: "r"
  def piece_label(%Piece{type: :n, color: :white}), do: "N"
  def piece_label(%Piece{type: :n, color: :black}), do: "n"
  def piece_label(%Piece{type: :b, color: :white}), do: "B"
  def piece_label(%Piece{type: :b, color: :black}), do: "b"
  def piece_label(%Piece{type: :q, color: :white}), do: "Q"
  def piece_label(%Piece{type: :q, color: :black}), do: "q"
  def piece_label(%Piece{type: :k, color: :white}), do: "K"
  def piece_label(%Piece{type: :k, color: :black}), do: "k"
end
