defmodule ExChessCore.Validators.SpecialMoves do
  alias ExChessCore.{Validators, MoveContext, MoveType}
  alias ExChess.{Board, SpecialRules, Move, Square, Piece}

  @spec verify(MoveContext.t()) :: nil | {:ok, MoveType.special()}
  def verify(%MoveContext{
        special_rules: %SpecialRules{
          en_passant_file: en_passant_file,
        },
        pieces: {%Piece{type: :p, color: color}, _},
        move: %Move{from: from, to: to},
      }) do
    rank_direction =
      case color do
        :white -> 1
        :black -> -1
      end

    {file_shift, rank_shift} = Square.compare(from, to)

    valid_file? = to.file == en_passant_file
    valid_shift? = abs(file_shift) == 1 and rank_shift == rank_direction

    valid_to_rank? =
      to.rank ==
        case color do
          :white -> 5
          :black -> 2
        end

    (valid_file? && valid_shift? && valid_to_rank? && {:ok, :en_passant}) || nil
  end

  def verify(%MoveContext{
        pieces: {%Piece{type: :k, color: color}, _},
        move: move = %Move{from: from},
        board: board,
        special_rules: %SpecialRules{castling_rights: castling_rights},
      }) do
    with {:ok, castle_type} <- castle_type(move),
         true <-
           king_starting_position?(color, from) and
             rook_starting_position?(board, castle_type, color) and
             king_and_rook_not_moved?(castling_rights, castle_type, color) and
             castle_path_clear?(board, move, castle_type) and
             castle_path_safe?(board, move, castle_type, color) do
      {:ok, castle_type}
    else
      _ -> nil
    end
  end

  def verify(%MoveContext{}), do: nil

  defp castle_type(%Move{from: from, to: to}) do
    case Square.compare(from, to) do
      {2, 0} -> {:ok, :castle_kingside}
      {-2, 0} -> {:ok, :castle_queenside}
      _ -> :error
    end
  end

  defp king_starting_position?(:white, %Square{file: 4, rank: 0}), do: true
  defp king_starting_position?(:black, %Square{file: 4, rank: 7}), do: true
  defp king_starting_position?(_, _), do: false

  defp rook_starting_position?(board, side, color) do
    file =
      case side do
        :castle_queenside -> 0
        :castle_kingside -> 7
      end

    rank =
      case color do
        :white -> 0
        :black -> 7
      end

    case Board.get(board, Square.new(file, rank)) do
      %Piece{type: :r, color: ^color} -> true
      _ -> false
    end
  end

  defp king_and_rook_not_moved?(%{white_queenside: true}, :castle_queenside, :white), do: true
  defp king_and_rook_not_moved?(%{white_kingside: true}, :castle_kingside, :white), do: true
  defp king_and_rook_not_moved?(%{black_queenside: true}, :castle_queenside, :black), do: true
  defp king_and_rook_not_moved?(%{black_kingside: true}, :castle_kingside, :black), do: true
  defp king_and_rook_not_moved?(_, _, _), do: false

  defp castle_path_clear?(board, %Move{from: from}, side) do
    file_shifts =
      case side do
        :castle_kingside -> 1..2
        :castle_queenside -> -1..-3//-1
      end

    Enum.all?(
      file_shifts,
      &Board.square_empty?(board, Square.shift(from, &1, 0))
    )
  end

  defp castle_path_safe?(board, %Move{from: from}, side, ally_color) do
    direction =
      case side do
        :castle_kingside -> 1
        :castle_queenside -> -1
      end

    any_square_attacked? =
      0..(2 * direction)//direction
      |> Enum.map(&Square.shift(from, &1, 0))
      |> Enum.any?(&Validators.SquareUnderAttack.evaluate?(&1, board, ally_color))

    not any_square_attacked?
  end
end
