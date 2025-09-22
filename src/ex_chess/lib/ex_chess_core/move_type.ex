defmodule ExChessCore.MoveType do
  @type king_special() :: :castle_kingside | :castle_queenside
  @type pawn_special() :: :en_passant

  @type special() :: king_special() | pawn_special()

  @type pawn_basic() :: :take | :advance_one | :advance_two
  @type basic() :: pawn_basic() | nil

  @type t() :: basic() | special()
end
