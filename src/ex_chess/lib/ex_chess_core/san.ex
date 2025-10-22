defmodule ExChessCore.San do
  alias ExChessCore.MoveEvaluation
  alias ExChessCore.MoveContext
  alias ExChess.{Game, Board, Move, Square, Piece}

  @type t() :: binary()

  @spec parse_move(Game.t(), t()) :: {:ok, Move.t()} | :error
  def parse_move(game, move_text)

  @white_king_square Square.new(4, 0)
  @black_king_square Square.new(4, 7)
  def parse_move(%Game{active_color: active_color}, <<?O, rest::binary>>) do
    type = parse_castle(rest)

    from =
      %Square{rank: rank} =
      case active_color do
        :white -> @white_king_square
        :black -> @black_king_square
      end

    to_file =
      case type do
        :queenside -> 2
        :kingside -> 6
      end

    {:ok, Move.new(from, Square.new(to_file, rank))}
  end

  def parse_move(game = %Game{board: board, active_color: active_color}, move_text) do
    {piece, first_file, first_rank, second_file, second_rank, promotion} =
      parse_non_castle(move_text)

    {parsed_from_file, parsed_from_rank, to_square} =
      case {second_file, second_rank} do
        {nil, nil} ->
          {nil, nil, Square.new(first_file, first_rank)}

        {second_file, nil} ->
          {first_file, nil, Square.new(second_file, first_rank)}

        {nil, second_rank} ->
          {nil, first_rank, Square.new(first_file, second_rank)}

        {second_file, second_rank} ->
          {first_file, first_rank, Square.new(second_file, second_rank)}
      end

    result =
      Board.get_pieces_by_color(board, active_color)
      |> Enum.find(fn {curr_square = %Square{file: curr_file, rank: curr_rank},
                       %Piece{type: curr_piece}} ->
        valid_piece? = piece == curr_piece
        valid_file? = is_nil(parsed_from_file) or curr_file == parsed_from_file
        valid_rank? = is_nil(parsed_from_rank) or curr_rank == parsed_from_rank

        valid_piece? and valid_file? and valid_rank? and
          match?(
            %MoveContext{valid?: true},
            MoveContext.new(game, Move.new(curr_square, to_square)) |> MoveEvaluation.run()
          )
      end)

    case result do
      {from_square, _piece} -> {:ok, Move.new(from_square, to_square, promotion)}
      nil -> :error
    end
  end

  defp parse_castle(<<?-, ?O, ?-, ?O, _rest::binary>>), do: :queenside
  defp parse_castle(<<?-, ?O, _rest::binary>>), do: :kingside

  defp parse_non_castle(move_text) do
    {piece, rest} = parse_piece(move_text)
    {first_file, rest} = parse_file(rest)
    {first_rank, rest} = parse_rank(rest)
    rest = skip_capture(rest)
    {second_file, rest} = parse_file(rest)
    {second_rank, rest} = parse_rank(rest)
    promotion = parse_promotion(rest)

    {piece, first_file, first_rank, second_file, second_rank, promotion}
  end

  defp parse_piece(<<?K, rest::binary>>), do: {:k, rest}
  defp parse_piece(<<?Q, rest::binary>>), do: {:q, rest}
  defp parse_piece(<<?R, rest::binary>>), do: {:r, rest}
  defp parse_piece(<<?B, rest::binary>>), do: {:b, rest}
  defp parse_piece(<<?N, rest::binary>>), do: {:n, rest}
  defp parse_piece(<<?P, rest::binary>>), do: {:p, rest}
  defp parse_piece(move_text), do: {:p, move_text}

  defp parse_file(<<>>), do: {nil, <<>>}
  defp parse_file(<<?a, rest::binary>>), do: {0, rest}
  defp parse_file(<<?b, rest::binary>>), do: {1, rest}
  defp parse_file(<<?c, rest::binary>>), do: {2, rest}
  defp parse_file(<<?d, rest::binary>>), do: {3, rest}
  defp parse_file(<<?e, rest::binary>>), do: {4, rest}
  defp parse_file(<<?f, rest::binary>>), do: {5, rest}
  defp parse_file(<<?g, rest::binary>>), do: {6, rest}
  defp parse_file(<<?h, rest::binary>>), do: {7, rest}
  defp parse_file(move_text), do: {nil, move_text}

  defp parse_rank(<<>>), do: {nil, <<>>}
  defp parse_rank(<<?1, rest::binary>>), do: {0, rest}
  defp parse_rank(<<?2, rest::binary>>), do: {1, rest}
  defp parse_rank(<<?3, rest::binary>>), do: {2, rest}
  defp parse_rank(<<?4, rest::binary>>), do: {3, rest}
  defp parse_rank(<<?5, rest::binary>>), do: {4, rest}
  defp parse_rank(<<?6, rest::binary>>), do: {5, rest}
  defp parse_rank(<<?7, rest::binary>>), do: {6, rest}
  defp parse_rank(<<?8, rest::binary>>), do: {7, rest}
  defp parse_rank(move_text), do: {nil, move_text}

  defp skip_capture(<<>>), do: <<>>
  defp skip_capture(<<?x, rest::binary>>), do: rest
  defp skip_capture(move_text), do: move_text

  defp parse_promotion(<<>>), do: :q
  defp parse_promotion(<<?=, ?Q, _rest::binary>>), do: :q
  defp parse_promotion(<<?=, ?R, _rest::binary>>), do: :r
  defp parse_promotion(<<?=, ?B, _rest::binary>>), do: :b
  defp parse_promotion(<<?=, ?N, _rest::binary>>), do: :n
  defp parse_promotion(_move_text), do: :q
end
