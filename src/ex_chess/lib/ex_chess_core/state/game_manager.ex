defmodule ExChessCore.State.GameManager do
  alias ExChess.{Game, Board, Square, Piece}
  alias ExChessCore.{MoveContext, MoveGeneration, PieceRules}

  @spec updated(MoveContext.t()) :: Game.t() | :error
  def updated(%MoveContext{valid?: false}), do: :error

  def updated(
        move_context = %MoveContext{
          color: color,
          enemy_color: enemy_color,
          updated_board: updated_board,
          piece: piece,
          target_piece: target_piece,
          halfmove_clock: halfmove_clock,
          fullmove_number: fullmove_number,
        }
      ) do
    reversible_move? = is_nil(target_piece) and piece != :p

    updated_en_passant_file = en_passant_file(move_context)
    updated_castling_rights = castling_rights(move_context)

    {updated_repetition_history, repetitions_count} =
      repetition_history(move_context, updated_castling_rights, reversible_move?)

    updated_fullmove_number =
      case color do
        :black -> fullmove_number + 1
        :white -> fullmove_number
      end

    %Game{
      active_color: enemy_color,
      status: game_status(move_context, repetitions_count),
      board: updated_board,
      en_passant_file: updated_en_passant_file,
      castling_rights: updated_castling_rights,
      repetition_history: updated_repetition_history,
      halfmove_clock: (reversible_move? && halfmove_clock + 1) || 0,
      fullmove_number: updated_fullmove_number,
    }
  end

  defp en_passant_file(%MoveContext{move_type: :advance_two, target_square: target_square}),
    do: target_square.file

  defp en_passant_file(%MoveContext{}), do: nil

  @white_queenside_rook Square.new(0, 0)
  @white_kingside_rook Square.new(7, 0)
  @white_king Square.new(4, 0)
  @black_queenside_rook Square.new(0, 7)
  @black_kingside_rook Square.new(7, 7)
  @black_king Square.new(4, 7)

  defp castling_rights(%MoveContext{square: square, castling_rights: castling_rights}) do
    case square do
      @white_queenside_rook -> [:white_queenside?]
      @white_kingside_rook -> [:white_kingside?]
      @white_king -> [:white_queenside?, :white_kingside?]
      @black_queenside_rook -> [:black_queenside?]
      @black_kingside_rook -> [:black_kingside?]
      @black_king -> [:black_queenside?, :black_kingside?]
      _ -> []
    end
    |> Enum.reduce(castling_rights, &Map.put(&2, &1, false))
  end

  defp repetition_history(
         %MoveContext{
           repetition_history: repetition_history,
           enemy_color: enemy_color,
           updated_board: updated_board,
           castling_rights: castling_rights,
         },
         updated_castling_rights,
         reversible_move?
       ) do
    reset_history? = not reversible_move? or castling_rights != updated_castling_rights

    repetition_history =
      if reset_history? do
        %{}
      else
        repetition_history
      end

    Game.increment_repetition_history(repetition_history, enemy_color, updated_board)
  end

  defp game_status(_, repetitions_count)
       when repetitions_count >= 3,
       do: {:tie, :threefold_repetition}

  defp game_status(
         %MoveContext{
           color: color,
           enemy_color: enemy_color,
           updated_board: updated_board,
           en_passant_file: en_passant_file,
           castling_rights: castling_rights,
         },
         _
       ) do
    enemy_pieces = Board.get_pieces_by_color(updated_board, enemy_color)

    enemy_stuck? = not has_moves?(enemy_pieces, updated_board, en_passant_file, castling_rights)

    {enemy_king_square, _} =
      Enum.find(enemy_pieces, fn {_square, %Piece{type: piece}} -> piece == :k end)

    enemy_in_check? =
      PieceRules.king_threatened?(
        updated_board,
        enemy_king_square,
        color
      )

    cond do
      enemy_stuck? and enemy_in_check? ->
        {color, :checkmate}

      enemy_stuck? ->
        {:tie, :stalemate}

      insufficient_material?(enemy_pieces) and
          insufficient_material?(Board.get_pieces_by_color(updated_board, color)) ->
        {:tie, :insufficient_material}

      true ->
        :continue
    end
  end

  defp has_moves?(enemy_pieces, updated_board, en_passant_file, castling_rights) do
    enemy_pieces
    |> Enum.map(fn {square, piece} ->
      MoveGeneration.stream(
        piece.color,
        updated_board,
        en_passant_file,
        castling_rights,
        piece,
        square
      )
      |> Enum.to_list()
      |> Enum.any?()
    end)
    |> Enum.any?()
  end

  defp insufficient_material?(player_pieces) do
    case player_pieces do
      [_] ->
        true

      [_, _] ->
        Enum.sum_by(player_pieces, fn {_, %Piece{type: piece_type}} -> score(piece_type) end) <= 4

      _ ->
        false
    end
  end

  defp score(piece_type) when piece_type in [:n, :b], do: 3
  defp score(:k), do: 1
  defp score(_piece_type), do: 5
end
