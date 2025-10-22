defmodule ExChess.Visualization do
  @moduledoc """
  This is used to prettify some of the game structures into a nice human readable format.
  """
  alias ExChess.{Fen, Game, Board, Square, Piece}

  @doc """
  Used to visualize a game into a one-line string.

  ## Examples

      iex> ExChess.start_game() |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  """
  @spec game(ExChess.Game.t()) :: binary()
  def game(game) do
    "STATUS: #{status(game)} | FEN: #{Fen.from_game(game)}"
  end

  @doc """
  Used to visualize a game into a multiline representation.
  """
  @spec game_full(Game.t()) :: binary()
  def game_full(game) do
    """
    STATUS: #{status(game)}
    FEN: #{Fen.from_game(game)}
    BOARD: \n#{board(game.board)}
    """
  end

  @rank_joiner "\n"
  @file_joiner ""

  @doc """
  Used to visualize a board into a multiline representation.
  """
  @spec board(Board.t()) :: binary()
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

  @doc """
  Used to visualize a piece into a 1-character string.

  ## Examples

      iex> ExChess.Piece.new(:k, :white) |> ExChess.Visualization.piece_label()
      "K"

      iex> ExChess.Piece.new(:n, :black) |> ExChess.Visualization.piece_label()
      "n"

      iex> ExChess.Visualization.piece_label(nil)
      " "
  """
  @spec piece_label(Piece.t() | nil) :: <<_::8>>
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

  @doc """
  Used to visualize a piece into a 1-character string.

  ## Examples

  ### In progress

      iex> ExChess.start_game() |> ExChess.Visualization.status()
      "*"

  ### White won

      iex> ExChess.start_game()
      ...> |> ExChess.move("Nc3")
      ...> |> ExChess.resign()
      ...> |> ExChess.Visualization.status()
      "1-0"

  ### Black won

      iex> ExChess.start_game()
      ...> |> ExChess.resign()
      ...> |> ExChess.Visualization.status()
      "0-1"

  ### Draw

      iex> ExChess.start_game("knn5/8/8/8/8/8/8/KNN5 w - - 101 70")
      ...> |> ExChess.claim_draw()
      ...> |> ExChess.Visualization.status()
      "1/2-1/2"
  """
  @spec status(Game.t()) :: binary()
  def status(%Game{status: :continue}), do: "*"
  def status(%Game{status: {:white, _reason}}), do: "1-0"
  def status(%Game{status: {:black, _reason}}), do: "0-1"
  def status(%Game{status: {:tie, _reason}}), do: "1/2-1/2"
end
