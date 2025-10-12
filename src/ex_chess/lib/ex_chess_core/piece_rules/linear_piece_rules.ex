defmodule ExChessCore.PieceRules.LinearPieceRules do
  alias ExChess.Square
  alias ExChessCore.MoveContext
  import MoveContext

  @spec evaluate(MoveContext.t(), boolean()) :: MoveContext.t()
  def evaluate(
        move_context = %MoveContext{
          board: board,
          piece: piece_type,
          square: square,
          target_square: target_square,
          square_shift: {file_shift, rank_shift},
        },
        _
      )
      when piece_type in [:r, :b, :q] do
    straight? = file_shift == 0 or rank_shift == 0
    diagonal? = abs(file_shift) == abs(rank_shift)

    valid_direction? =
      case piece_type do
        :r -> straight?
        :b -> diagonal?
        :q -> straight? or diagonal?
      end

    case valid_direction? && verify_path(board, square, target_square) do
      false -> error(move_context, :direction)
      {:error, code, payload} -> error(move_context, code, payload)
      :ok -> move_context
    end
  end

  defp verify_path(board, square, target_square) do
    file_direction = direction(square.file, target_square.file)
    rank_direction = direction(square.rank, target_square.rank)

    first_square = Square.shift(square, file_direction, rank_direction)
    distance = 1

    verify_path(
      board,
      first_square,
      target_square,
      file_direction,
      rank_direction,
      distance
    )
  end

  defp direction(from, to) when to < from, do: -1
  defp direction(from, to) when to > from, do: 1
  defp direction(_, _), do: 0

  defp verify_path(board, square, target_square, file_direction, rank_direction, distance) do
    cond do
      distance > 7 ->
        {:error, :distance, %{}}

      Square.same_location?(square, target_square) ->
        :ok

      true ->
        verify_path(
          board,
          Square.shift(square, file_direction, rank_direction),
          target_square,
          file_direction,
          rank_direction,
          distance + 1
        )
    end
  end
end
