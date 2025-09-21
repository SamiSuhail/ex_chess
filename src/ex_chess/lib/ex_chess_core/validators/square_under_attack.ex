defmodule ExChessCore.Validators.SquareUnderAttack do
  alias ExChess.{Board, Move, Square, Piece}
  alias ExChessCore.{Validators, MoveContext}

  @spec evaluate?(Square.t(), Board.t(), Piece.color()) :: boolean()
  def evaluate?(square, board, ally_color) do
    enemy_color = Piece.flip_color(ally_color)

    board
    |> Enum.filter(fn {_, curr_piece} -> curr_piece.color == enemy_color end)
    |> Enum.any?(fn {enemy_square, enemy_piece} ->
      move = Move.new(enemy_square, square)
      move_context = MoveContext.new(enemy_color, board, move, enemy_piece)

      case Validators.Basic.valid?(move_context) && Validators.NormalMoves.verify(move_context) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end

  @spec king?(Board.t(), Piece.color()) :: boolean()
  def king?(
        board,
        color
      ) do
    {king_square, _king} =
      Enum.find(board, fn {_, curr_piece} ->
        curr_piece.type == :k and curr_piece.color == color
      end)

    evaluate?(king_square, board, color)
  end
end
