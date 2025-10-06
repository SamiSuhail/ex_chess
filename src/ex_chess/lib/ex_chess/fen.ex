defmodule ExChess.Fen do
  alias ExChess.{Game, Board, Square, Piece}

  @spec from_game(Game.t()) :: binary()
  def from_game(%Game{
        board: board,
        active_color: active_color,
        castling_rights: castling_rights,
        en_passant_file: en_passant_file,
        halfmove_clock: halfmove_clock,
      }) do
    "#{from_board(board)} #{from_active_color(active_color)} #{from_castling_rights(castling_rights)} #{from_en_passant_file(en_passant_file, active_color)} #{halfmove_clock} #{1}"
  end

  defp from_board(board) do
    7..0//-1
    |> Enum.map(&from_rank(&1, board))
    |> Enum.join("/")
  end

  defp from_rank(rank, board) do
    {empty_squares_clock, rank_fen_result} =
      0..7
      |> Enum.reduce({0, ""}, fn file, {empty_squares_clock, rank_fen_result} ->
        piece = Board.get(board, Square.new(file, rank))

        if is_nil(piece) do
          {empty_squares_clock + 1, rank_fen_result}
        else
          updated_rank_fen_result =
            rank_fen_result <> from_empty_squares(empty_squares_clock) <> from_piece(piece)

          {0, updated_rank_fen_result}
        end
      end)

    rank_fen_result <> from_empty_squares(empty_squares_clock)
  end

  defp from_empty_squares(0), do: ""
  defp from_empty_squares(empty_squares_clock), do: "#{empty_squares_clock}"

  defp from_piece(%Piece{type: :p, color: :white}), do: "P"
  defp from_piece(%Piece{type: :p, color: :black}), do: "p"
  defp from_piece(%Piece{type: :r, color: :white}), do: "R"
  defp from_piece(%Piece{type: :r, color: :black}), do: "r"
  defp from_piece(%Piece{type: :n, color: :white}), do: "N"
  defp from_piece(%Piece{type: :n, color: :black}), do: "n"
  defp from_piece(%Piece{type: :b, color: :white}), do: "B"
  defp from_piece(%Piece{type: :b, color: :black}), do: "b"
  defp from_piece(%Piece{type: :q, color: :white}), do: "Q"
  defp from_piece(%Piece{type: :q, color: :black}), do: "q"
  defp from_piece(%Piece{type: :k, color: :white}), do: "K"
  defp from_piece(%Piece{type: :k, color: :black}), do: "k"

  defp from_active_color(:white), do: "w"
  defp from_active_color(:black), do: "b"

  @ordered_castling_rights_mapping [
    {:white_kingside?, "K"},
    {:white_queenside?, "Q"},
    {:black_kingside?, "k"},
    {:black_queenside?, "q"},
  ]
  defp from_castling_rights(castling_rights) do
    joined_castles =
      @ordered_castling_rights_mapping
      |> Enum.map(fn {key, symbol} -> if castling_rights[key], do: symbol, else: "" end)
      |> Enum.join()

    if joined_castles == "" do
      "-"
    else
      joined_castles
    end
  end

  defp from_en_passant_file(nil, _), do: "-"

  defp from_en_passant_file(en_passant_file, active_color) do
    rank =
      case active_color do
        :white -> "4"
        :black -> "3"
      end

    "#{from_file(en_passant_file)}#{rank}"
  end

  defp from_file(0), do: "a"
  defp from_file(1), do: "b"
  defp from_file(2), do: "c"
  defp from_file(3), do: "d"
  defp from_file(4), do: "e"
  defp from_file(5), do: "f"
  defp from_file(6), do: "g"
  defp from_file(7), do: "h"

  @spec to_game(binary()) :: Game.t()
  def to_game(fen) do
    [
      board_fen,
      active_color_fen,
      castling_rights_fen,
      en_passant_square_fen,
      halfmove_clock_fen,
      _fullmove_number_fen,
    ] = String.split(fen, " ")

    {halfmove_clock, _rest} = Integer.parse(halfmove_clock_fen)

    Game.new(
      to_active_color(active_color_fen),
      to_board(board_fen),
      to_castling_rights(castling_rights_fen),
      to_en_passant_file(en_passant_square_fen),
      halfmove_clock
    )
  end

  defp to_active_color("w"), do: :white
  defp to_active_color("b"), do: :black

  defp to_board(board_fen) do
    ranks = board_fen |> String.split("/")

    ranks
    |> Enum.reduce({Board.empty(), 7}, fn rank_fen, {board, rank} ->
      updated_board = put_pieces(board, rank_fen, rank)
      {updated_board, rank - 1}
    end)
    |> elem(0)
  end

  defp put_pieces(board, rank_fen, rank) do
    rank_fen
    |> String.split("", trim: true)
    |> Enum.reduce({board, 0}, fn symbol, {curr_board, file} ->
      case parse_symbol(symbol) do
        {:piece, piece} ->
          square = Square.new(file, rank)
          updated_board = Board.set(curr_board, square, piece)
          {updated_board, file + 1}

        {:empty_squares, count} ->
          {curr_board, file + count}
      end
    end)
    |> elem(0)
  end

  defp parse_symbol("P"), do: {:piece, Piece.new(:p, :white)}
  defp parse_symbol("p"), do: {:piece, Piece.new(:p, :black)}
  defp parse_symbol("R"), do: {:piece, Piece.new(:r, :white)}
  defp parse_symbol("r"), do: {:piece, Piece.new(:r, :black)}
  defp parse_symbol("N"), do: {:piece, Piece.new(:n, :white)}
  defp parse_symbol("n"), do: {:piece, Piece.new(:n, :black)}
  defp parse_symbol("B"), do: {:piece, Piece.new(:b, :white)}
  defp parse_symbol("b"), do: {:piece, Piece.new(:b, :black)}
  defp parse_symbol("Q"), do: {:piece, Piece.new(:q, :white)}
  defp parse_symbol("q"), do: {:piece, Piece.new(:q, :black)}
  defp parse_symbol("K"), do: {:piece, Piece.new(:k, :white)}
  defp parse_symbol("k"), do: {:piece, Piece.new(:k, :black)}

  defp parse_symbol(empty_squares_count) do
    # {count, _rest} = Integer.parse(empty_squares_count)
    case Integer.parse(empty_squares_count) do
      {count, _rest} -> {:empty_squares, count}
      :error -> raise "Cannot parse symbol #{empty_squares_count}"
    end
  end

  defp to_castling_rights("-"), do: Game.empty_castling_rights()

  defp to_castling_rights(castling_rights_fen) do
    String.split(castling_rights_fen, "", trim: true)
    |> Enum.reduce(Game.empty_castling_rights(), fn symbol, castling_rights ->
      key =
        case symbol do
          "K" -> :white_kingside?
          "Q" -> :white_queenside?
          "k" -> :black_kingside?
          "q" -> :black_queenside?
        end

      Map.put(castling_rights, key, true)
    end)
  end

  defp to_en_passant_file("-"), do: nil
  defp to_en_passant_file("a" <> _rank), do: 0
  defp to_en_passant_file("b" <> _rank), do: 1
  defp to_en_passant_file("c" <> _rank), do: 2
  defp to_en_passant_file("d" <> _rank), do: 3
  defp to_en_passant_file("e" <> _rank), do: 4
  defp to_en_passant_file("f" <> _rank), do: 5
  defp to_en_passant_file("g" <> _rank), do: 6
  defp to_en_passant_file("h" <> _rank), do: 7
end
