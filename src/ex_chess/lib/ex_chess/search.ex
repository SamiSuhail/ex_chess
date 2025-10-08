defmodule ExChess.Search do
  alias ExChess.{Game, Board, Move}

  def run(game, layers_count) do
    0..layers_count
    |> Enum.reduce([game], fn layer, curr_games ->
      IO.puts(layer)
      next_layer(curr_games)
    end)
  end

  defp next_layer(games) do
    games
    |> Task.async_stream(
      fn game ->
        enumerate_next_positions(game)
      end,
      max_concurrency: System.schedulers_online(),
      timeout: :infinity
    )
    |> Enum.flat_map(fn {:ok, next_games} -> next_games end)
  end

  defp enumerate_next_positions(game = %Game{active_color: color, board: board}) do
    Board.get_pieces_by_color(board, color)
    |> Enum.flat_map(fn {square, _piece} -> enumerate_next_positions_for_square(game, square) end)
  end

  defp enumerate_next_positions_for_square(game, square) do
    ExChess.list_legal_moves(game, square)
    |> Enum.map(fn target_square ->
      move = Move.new(square, target_square)
      next_game = ExChess.move(game, move)

      if next_game == :error do
        %{move: move, game: game} |> dbg()
        raise "Unexpected error!"
      end

      next_game
    end)
  end
end
