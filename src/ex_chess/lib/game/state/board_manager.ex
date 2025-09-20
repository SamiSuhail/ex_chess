defmodule ExChess.Game.State.BoardManager do
  alias ExChess.Game.MoveType
  alias ExChess.{Board, Move, Square, Piece}

  @spec update(Board.t(), Piece.t(), Move.t(), MoveType.t()) :: Board.t()
  def update(
        board,
        piece = %Piece{},
        move = %Move{},
        move_type
      ) do
    board
    |> maybe_unset_en_passant_target(piece, move, move_type)
    |> Board.set(move.to, piece)
    |> Board.unset(move.from)
    |> maybe_promote(move.to, move.promotion, piece.color)
    |> maybe_castle(piece, move, move_type)
  end

  defp maybe_unset_en_passant_target(
         board,
         %Piece{type: :p},
         %Move{from: from, to: to},
         :en_passant
       ) do
    Board.unset(board, Square.new(to.file, from.rank))
  end

  defp maybe_unset_en_passant_target(board, %Piece{}, %Move{}, _),
    do: board

  defp maybe_promote(board, to_square, promotion, piece_color) when not is_nil(promotion),
    do: Board.set(board, to_square, Piece.new(promotion, piece_color))

  defp maybe_promote(board, %Square{}, _, _), do: board

  defp maybe_castle(
         board,
         %Piece{type: :k, color: color},
         %Move{to: to},
         move_type
       )
       when move_type in [:castle_queenside, :castle_kingside] do
    {rook_from_file, rook_to_file} =
      case move_type do
        :castle_queenside -> {0, 3}
        :castle_kingside -> {7, 5}
      end

    Board.unset(board, Square.new(rook_from_file, to.rank))
    |> Board.set(Square.new(rook_to_file, to.rank), Piece.new(:r, color))
  end

  defp maybe_castle(board, %Piece{}, %Move{}, _), do: board
end
