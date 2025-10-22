defmodule ExChessTest.PerftTest do
  # https://www.chessprogramming.org/Perft_Results
  use ExUnit.Case
  alias ExChessTest.Arrange
  alias ExChess.{Game, Board, Move, Square}

  test "initial position" do
    Arrange.new_game("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    |> assert_perft(20)
    |> assert_perft(400)
    |> assert_perft(8902)

    # |> assert_perft(197_281)
  end

  test "Kiwipete position" do
    Arrange.new_game("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
    |> assert_perft(48)
    |> assert_perft(2039)

    # |> assert_perft(97862)
  end

  defp assert_perft(game = %Game{}, expected_count), do: assert_perft([game], expected_count)

  defp assert_perft(games, expected_count) do
    {next_games, actual_count} =
      games
      |> Task.async_stream(
        fn game ->
          enumerate_next_positions(game)
        end,
        max_concurrency: System.schedulers_online(),
        timeout: :infinity
      )
      |> Enum.reduce({[], 0}, fn {:ok, {next_games, next_games_count}},
                                 {curr_games, curr_count} ->
        {Enum.concat(next_games, curr_games), next_games_count + curr_count}
      end)

    assert actual_count == expected_count
    next_games
  end

  @spec enumerate_next_positions(Game.t()) :: {[Game.t()], pos_integer()}
  defp enumerate_next_positions(game = %Game{active_color: color, board: board}) do
    Board.get_pieces_by_color(board, color)
    |> Enum.reduce({[], 0}, fn {square, _}, {curr_games, curr_count} ->
      {next_games, count} = enumerate_next_positions_for_square(game, square)
      {Enum.concat(next_games, curr_games), count + curr_count}
    end)
  end

  @spec enumerate_next_positions_for_square(Game.t(), Square.t()) :: {[Game.t()], pos_integer()}
  defp enumerate_next_positions_for_square(game, square) do
    ExChess.list_legal_moves(game, square)
    |> Enum.reduce({[], 0}, fn target_square, {curr_games, curr_count} ->
      move = Move.new(square, target_square)
      next_game = ExChess.move(game, move)

      if next_game == :error do
        %{move: move, game: game} |> dbg()
        raise "Unexpected error!"
      end

      {[next_game | curr_games], curr_count + 1}
    end)
  end
end
