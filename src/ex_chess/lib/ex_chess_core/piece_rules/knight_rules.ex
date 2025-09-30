defmodule ExChessCore.PieceRules.KnightRules do
  alias ExChessCore.MoveContext

  @spec evaluate(MoveContext.t(), boolean()) :: MoveContext.t()
  def evaluate(
        move_context = %MoveContext{piece: :n, square_shift: {file_shift, rank_shift}},
        _
      ) do
    case {abs(file_shift), abs(rank_shift)} do
      {1, 2} -> move_context
      {2, 1} -> move_context
      _ -> MoveContext.error(move_context, :pattern)
    end
  end
end
