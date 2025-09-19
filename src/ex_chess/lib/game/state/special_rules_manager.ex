defmodule ExChess.Game.State.SpecialRulesManager do
  alias ExChess.{SpecialRules, Move, Square, Piece}
  alias ExChess.Game.MoveType

  @spec update(SpecialRules.t(), Piece.t(), Move.t(), MoveType.t()) :: SpecialRules.t()
  def update(special_rules, piece, move, move_type) do
    special_rules
    |> put_en_passant_file(piece, move, move_type)
    |> maybe_put_castles(move.from)
  end

  defp put_en_passant_file(
         special_rules = %SpecialRules{},
         %Piece{type: :p},
         %Move{
           to: to,
         },
         :advance_two
       ),
       do: %SpecialRules{special_rules | en_passant_file: to.file}

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{}, %Move{}, _),
    do: %SpecialRules{special_rules | en_passant_file: nil}

  @white_queenside_rook Square.new(0, 0)
  @white_kingside_rook Square.new(7, 0)
  @white_king Square.new(4, 0)
  @black_queenside_rook Square.new(0, 7)
  @black_kingside_rook Square.new(7, 7)
  @black_king Square.new(4, 7)

  defp maybe_put_castles(
         special_rules = %SpecialRules{castling_rights: castling_rights},
         from_square = %Square{}
       ) do
    updated_castling_rights =
      case from_square do
        @white_queenside_rook -> [:white_queenside]
        @white_kingside_rook -> [:white_kingside]
        @white_king -> [:white_queenside, :white_kingside]
        @black_queenside_rook -> [:black_queenside]
        @black_kingside_rook -> [:black_kingside]
        @black_king -> [:black_queenside, :black_kingside]
        _ -> []
      end
      |> Enum.reduce(castling_rights, &Map.put(&2, &1, false))

    %SpecialRules{special_rules | castling_rights: updated_castling_rights}
  end
end
