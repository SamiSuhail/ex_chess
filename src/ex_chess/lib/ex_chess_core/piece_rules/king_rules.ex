defmodule ExChessCore.PieceRules.KingRules do
  alias ExChess.{Board, Square, Piece}
  alias ExChessCore.{MoveContext, PieceRules}
  import MoveContext

  @spec evaluate(MoveContext.t(), boolean()) :: MoveContext.t()
  def evaluate(
        move_context = %MoveContext{
          color: color,
          enemy_color: enemy_color,
          board: board,
          castling_rights: castling_rights,
          square: square,
          square_shift: {file_shift, rank_shift},
        },
        king_threats_only?
      ) do
    abs_file_shift = abs(file_shift)

    cond do
      max(abs_file_shift, abs(rank_shift)) == 1 ->
        move_context

      king_threats_only? ->
        error(move_context, :king_threats_only, %{})

      abs_file_shift == 2 and rank_shift == 0 ->
        castle_type = (file_shift == 2 && :castle_kingside) || :castle_queenside

        cond do
          not castling_rights_available?(castling_rights, castle_type, color) ->
            error(move_context, :castling_rights, %{castling_rights: castling_rights})

          not castle_path_clear?(board, square, castle_type) ->
            error(move_context, :castle_path_not_clear)

          not castle_path_safe?(board, square, castle_type, enemy_color) ->
            error(move_context, :castle_path_not_safe)

          true ->
            put_move_type(move_context, castle_type)
        end

      true ->
        error(move_context, :pattern)
    end
  end

  defp castling_rights_available?(%{white_queenside?: true}, :castle_queenside, :white), do: true
  defp castling_rights_available?(%{white_kingside?: true}, :castle_kingside, :white), do: true
  defp castling_rights_available?(%{black_queenside?: true}, :castle_queenside, :black), do: true
  defp castling_rights_available?(%{black_kingside?: true}, :castle_kingside, :black), do: true
  defp castling_rights_available?(_, _, _), do: false

  defp castle_path_clear?(board, square, side) do
    file_shifts =
      case side do
        :castle_kingside -> 1..2
        :castle_queenside -> -1..-3//-1
      end

    Enum.all?(
      file_shifts,
      &Board.square_empty?(board, Square.shift(square, &1, 0))
    )
  end

  defp castle_path_safe?(board, square, side, enemy_color) do
    direction =
      case side do
        :castle_kingside -> 1
        :castle_queenside -> -1
      end

    vulnerable_squares =
      0..(2 * direction)//direction
      |> Enum.map(&Square.shift(square, &1, 0))

    any_square_attacked? =
      Board.get_pieces_by_color(board, enemy_color)
      |> Enum.any?(fn {enemy_square, %Piece{type: enemy_piece}} ->
        vulnerable_squares
        |> Enum.any?(fn vulnerable_square ->
          %MoveContext{valid?: valid?} =
            PieceRules.evaluate_king_threats(
              board,
              enemy_color,
              enemy_piece,
              enemy_square,
              vulnerable_square
            )

          valid?
        end)
      end)

    not any_square_attacked?
  end
end
