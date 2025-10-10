defmodule ExChessCore.Search do
  alias ExChessCore.{MoveContext, PiecePatterns, MoveEvaluation, State.GameManager}
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
    |> Enum.flat_map(fn {square, piece} ->
      enumerate_next_positions_for_square(game, square, piece)
    end)
  end

  defp enumerate_next_positions_for_square(game, square, piece) do
    PiecePatterns.targets(piece, square)
    |> Stream.map(fn target_square ->
      move = Move.new(square, target_square)

      MoveContext.new(game, move)
      |> MoveEvaluation.run()
      |> GameManager.updated()
    end)
    |> Stream.filter(fn result -> result != :error end)
  end
end
