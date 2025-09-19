defmodule ExChess.Game.Validators.NormalMoves do
  alias ExChess.Game.{MoveContext, MoveType}
  alias ExChess.{Board, Move, Square, Piece}
  @spec verify(MoveContext.t()) :: nil | {:ok, MoveType.basic()}
  def verify(%MoveContext{
        board: board,
        pieces: {%Piece{type: :p, color: color}, _},
        move: %Move{from: from, to: to},
      }) do
    rank_direction =
      case color do
        :white -> 1
        :black -> -1
      end

    {file_shift, rank_shift} = Square.compare(from, to)

    cond do
      file_shift in [-1, 1] and
        rank_shift == rank_direction and
          not Board.square_empty?(board, to) ->
        {:ok, :take}

      file_shift == 0 and
        rank_shift == rank_direction and
          Board.square_empty?(board, to) ->
        {:ok, :advance_one}

      file_shift == 0 and
        rank_shift == 2 * rank_direction and
        ({from.rank, color} == {1, :white} or {from.rank, color} == {6, :black}) and
        Board.square_empty?(board, to) and
          Board.square_empty?(board, from |> Square.shift(0, rank_direction)) ->
        {:ok, :advance_two}

      true ->
        nil
    end
  end

  def verify(%MoveContext{
        board: board,
        pieces: {%Piece{type: piece_type}, _},
        move: move = %Move{},
      })
      when piece_type in [:r, :b, :q] do
    {file_shift, rank_shift} = Square.compare(move.from, move.to)

    straight? = file_shift == 0 or rank_shift == 0
    diagonal? = abs(file_shift) == abs(rank_shift)

    valid_direction? =
      case piece_type do
        :r -> straight?
        :b -> diagonal?
        :q -> straight? or diagonal?
      end

    if valid_direction? and linear_path_free?(board, move) do
      {:ok, nil}
    else
      nil
    end
  end

  def verify(%MoveContext{pieces: {%Piece{type: :k}, _}, move: %Move{from: from, to: to}}) do
    if abs(to.file - from.file) <= 1 and abs(to.rank - from.rank) <= 1 do
      {:ok, nil}
    else
      nil
    end
  end

  def verify(%MoveContext{pieces: {%Piece{type: :n}, _}, move: %Move{from: from, to: to}}) do
    {file_shift, rank_shift} = Square.compare(from, to)

    case {abs(file_shift), abs(rank_shift)} do
      {1, 2} -> {:ok, nil}
      {2, 1} -> {:ok, nil}
      _ -> nil
    end
  end

  defp linear_path_free?(board, %Move{from: from, to: to}) do
    file_direction = linear_direction(from.file, to.file)
    rank_direction = linear_direction(from.rank, to.rank)

    first_square = Square.shift(from, file_direction, rank_direction)
    distance = 1

    linear_path_free?(board, first_square, to, file_direction, rank_direction, distance)
  end

  defp linear_direction(from, to) when to < from, do: -1
  defp linear_direction(from, to) when to > from, do: 1
  defp linear_direction(_, _), do: 0

  defp linear_path_free?(board, square, target_square, file_direction, rank_direction, distance) do
    cond do
      distance > 7 ->
        false

      Square.same_location?(square, target_square) ->
        true

      not Board.square_empty?(board, square) ->
        false

      true ->
        linear_path_free?(
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
