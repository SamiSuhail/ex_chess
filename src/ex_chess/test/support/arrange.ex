defmodule ExChessTest.Arrange do
  alias ExChess.{Game, Move, Square}

  def new_game(), do: Game.new()

  def game_move(game, move_text) do
    move = parse_move(move_text)
    Game.move(game, move)
  end

  defp parse_move(<<
         from_file::binary-size(1),
         from_rank::binary-size(1),
         to_file::binary-size(1),
         to_rank::binary-size(1)
       >>) do
    from_square = text_to_square(from_file, from_rank)
    to_square = text_to_square(to_file, to_rank)

    Move.new(from_square, to_square)
  end

  defp text_to_square(file, rank),
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
