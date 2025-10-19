defmodule ExChess do
  alias ExChessCore.{
    MoveContext,
    State.GameManager,
    MoveEvaluation,
    MoveGeneration,
    San
  }

  alias ExChess.{Fen, Game, Board, Move, Square, Piece}

  @spec start_game(Fen.t() | nil) :: Game.t()
  def start_game(fen \\ nil)
  def start_game(nil), do: Game.new()
  def start_game(fen), do: Fen.to_game(fen)

  @spec move(Game.t(), Move.t() | San.t()) :: Game.t() | :error
  def move(game, move) when is_binary(move), do: move(game, San.parse_move(game, move))
  def move(%Game{status: game_status}, _move) when game_status != :continue, do: :error

  def move(
        game = %Game{},
        move = %Move{}
      ) do
    MoveContext.new(game, move)
    |> MoveEvaluation.run()
    |> GameManager.updated()
  end

  @spec list_legal_moves(Game.t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %Game{
          active_color: active_color,
          board: board,
          en_passant_file: en_passant_file,
          castling_rights: castling_rights,
        },
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    MoveGeneration.stream(
      active_color,
      board,
      en_passant_file,
      castling_rights,
      piece,
      from_square
    )
    |> Enum.to_list()
  end

  @spec claim_draw(Game.t()) :: Game.t() | :error
  def claim_draw(%Game{status: status}) when status != :continue, do: :error

  def claim_draw(game = %Game{halfmove_clock: halfmove_clock}) when halfmove_clock >= 100,
    do: %Game{game | status: {:tie, :fifty_move_rule}}

  def claim_draw(game = %Game{max_repetitions: max_repetitions}) when max_repetitions >= 3,
    do: %Game{game | status: {:tie, :threefold_repetition}}

  def claim_draw(%Game{}), do: :error

  @spec resign(Game.t()) :: Game.t() | :error
  def resign(%Game{status: status}) when status != :continue, do: :error

  def resign(game = %Game{active_color: active_color}),
    do: %Game{game | status: {Piece.flip_color(active_color), :resignation}}
end
