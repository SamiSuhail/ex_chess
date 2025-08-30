defmodule ExChessTest.Arrange do
  alias ExChess.{Game, Move, Square, Piece}

  def new_game(), do: Game.new()

  def game_board(game, board_text) do
    board = read_board(board_text)
    %Game{game | board: board}
  end

  defp read_board(board_text) when is_binary(board_text) do
    {board, _} =
      String.split(board_text, "\n", trim: true)
      |> Enum.slice(2, 8)
      |> Enum.map(&(String.split(&1, "|") |> Enum.at(1)))
      |> Enum.reduce(
        {%{}, 7},
        fn row, {board, rank} ->
          new_entries =
            String.split(row, "", trim: true)
            |> Enum.with_index()
            |> Enum.filter(fn {symbol, _} -> symbol != " " end)
            |> Map.new(fn {symbol, file} ->
              {Square.new(file, rank), symbol_to_piece(symbol)}
            end)

          updated_board = Map.merge(board, new_entries)
          {updated_board, rank - 1}
        end
      )

    board
  end

  defp symbol_to_piece("P"), do: Piece.new(:p, :white)
  defp symbol_to_piece("p"), do: Piece.new(:p, :black)
  defp symbol_to_piece("R"), do: Piece.new(:r, :white)
  defp symbol_to_piece("r"), do: Piece.new(:r, :black)
  defp symbol_to_piece("N"), do: Piece.new(:n, :white)
  defp symbol_to_piece("n"), do: Piece.new(:n, :black)
  defp symbol_to_piece("B"), do: Piece.new(:b, :white)
  defp symbol_to_piece("b"), do: Piece.new(:b, :black)
  defp symbol_to_piece("Q"), do: Piece.new(:q, :white)
  defp symbol_to_piece("q"), do: Piece.new(:q, :black)
  defp symbol_to_piece("K"), do: Piece.new(:k, :white)
  defp symbol_to_piece("k"), do: Piece.new(:k, :black)

  def game_move(game, move_text) do
    move = parse_move(move_text)
    Game.move(game, move)
  end

  defp parse_move(<<
         from::binary-size(2),
         to::binary-size(2)
       >>) do
    from_square = text_to_square(from)
    to_square = text_to_square(to)

    Move.new(from_square, to_square)
  end

  def game_list_legal_moves(game, square_text) do
    square = text_to_square(square_text)
    Game.list_legal_moves(game, square)
  end

  defp text_to_square(<<
         file::binary-size(1),
         rank::binary-size(1)
       >>),
       do: Square.new(file_to_index(file), rank_to_index(rank))

  defp file_to_index("a"), do: 0
  defp file_to_index("b"), do: 1
  defp file_to_index("c"), do: 2
  defp file_to_index("d"), do: 3
  defp file_to_index("e"), do: 4
  defp file_to_index("f"), do: 5
  defp file_to_index("g"), do: 6
  defp file_to_index("h"), do: 7

  defp rank_to_index(rank_text), do: String.to_integer(rank_text) - 1
end
