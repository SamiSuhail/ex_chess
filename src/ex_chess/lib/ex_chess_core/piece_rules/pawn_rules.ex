defmodule ExChessCore.PieceRules.PawnRules do
  alias ExChess.{Board, Square}
  alias ExChessCore.MoveContext
  import MoveContext

  @spec evaluate(MoveContext.t(), boolean()) :: MoveContext.t()
  def evaluate(
        move_context = %MoveContext{
          piece: :p,
          color: color,
          board: board,
          square: square,
          target_square: target_square,
          en_passant_file: en_passant_file,
          square_shift: {file_shift, rank_shift},
          target_piece: target_piece,
        },
        king_threats_only?
      ) do
    rank_direction =
      case color do
        :white -> 1
        :black -> -1
      end

    abs_rank_shift = rank_shift * rank_direction

    take? = file_shift in [-1, 1] and abs_rank_shift == 1
    advance? = file_shift == 0 and abs_rank_shift in 1..2

    cond do
      not (take? or advance?) ->
        error(move_context, :pawn_movement_pattern)

      take? ->
        cond do
          not is_nil(target_piece) ->
            put_move_type(move_context, :take)

          king_threats_only? ->
            error(move_context, :no_king_threats)

          target_square.file == en_passant_file and target_square.rank == en_passant_rank(color) ->
            put_move_type(move_context, :en_passant)

          true ->
            error(move_context, :cannot_take, %{
              en_passant_file: en_passant_file,
              target_piece: target_piece
            })
        end

      king_threats_only? ->
        error(move_context, :no_king_threats)

      not is_nil(target_piece) ->
        error(move_context, :path_not_clear)

      abs_rank_shift == 1 ->
        put_move_type(move_context, :advance_one)

      abs_rank_shift == 2 ->
        cond do
          not Board.square_empty?(board, square |> Square.shift(0, rank_direction)) ->
            error(move_context, :path_not_clear)

          square.rank != starting_rank(color) ->
            error(move_context, :not_on_starting_rank)

          true ->
            put_move_type(move_context, :advance_two)
        end
    end
  end

  defp en_passant_rank(:white), do: 5
  defp en_passant_rank(:black), do: 2

  defp starting_rank(:white), do: 1
  defp starting_rank(:black), do: 6
end
