defmodule ExChess.Visualization do
  alias ExChess.{Fen, Board, Square, Piece}

  def game(game) do
    "STATUS: #{status(game.status)} | FEN: #{Fen.from_game(game)}"
  end

  def game_full(game) do
    """
    STATUS: #{status(game.status)}
    FEN: #{Fen.from_game(game)}
    BOARD: \n#{board(game.board)}
    """
  end

  @rank_joiner "\n"
  @file_joiner ""
  def board(board) do
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

  defp game_board_rank(rank, board) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file -> Board.get(board, Square.new(file, rank)) |> piece_label() end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
  end

  defp status(:continue), do: "*"
  defp status({:white, _reason}), do: "1-0"
  defp status({:black, _reason}), do: "0-1"
  defp status(_), do: "1/2-1/2"
end
