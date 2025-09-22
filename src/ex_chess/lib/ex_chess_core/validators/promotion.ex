defmodule ExChessCore.Validators.Promotion do
  alias ExChess.{Move, Piece}
  @valid_pawn_promotion_types [:q, :r, :b, :n]

  @spec valid?(Piece.t() | nil, Move.t()) :: boolean()
  def valid?(
        %Piece{type: piece_type},
        %Move{to: to, promotion: promotion}
      ) do
    if piece_type == :p and to.rank in [0, 7] do
      promotion in @valid_pawn_promotion_types
    else
      is_nil(promotion)
    end
  end

  def valid?(nil, _), do: false
end
